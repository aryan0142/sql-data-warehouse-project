# SQL Data Warehouse Project | Medallion Architecture (Bronze, Silver, Gold)

## Overview

This project demonstrates the design and implementation of a modern SQL-based Data Warehouse using the **Medallion Architecture** approach (Bronze → Silver → Gold).

The solution integrates data from multiple business systems (**CRM** and **ERP**), applies data cleansing and transformation rules, and delivers a business-ready dimensional model using a **Star Schema** for analytics and reporting.

The project showcases core Data Engineering concepts including:

- Data Warehouse Design
- ETL Development using T-SQL
- Data Quality Management
- Data Transformation & Standardization
- Dimensional Modeling
- Star Schema Design
- Data Integration
- Data Governance
- Performance-Oriented Data Loading

---

# Architecture

## High-Level Architecture

[![Architecture](docs/Architecture.png)](https://github.com/aryan0142/sql-data-warehouse-project/blob/main/docs/Architecture.drawio%20(4).png)

The solution follows a layered architecture:

1. Source Systems (CRM & ERP)
2. Bronze Layer (Raw Data)
3. Silver Layer (Cleaned & Standardized Data)
4. Gold Layer (Business-Ready Star Schema)
5. Analytics & Reporting

---

## Data Flow

[![Data Flow Diagram](docs/data_flow_diagram.png)](https://github.com/aryan0142/sql-data-warehouse-project/blob/main/docs/data_flow_diagram.drawio%20(1).png)

```text
Source CSV Files
        │
        ▼
Bronze Layer
(Raw Data Storage)
        │
        ▼
Silver Layer
(Data Cleansing & Standardization)
        │
        ▼
Gold Layer
(Star Schema)
        │
        ▼
Analytics & Reporting
```

---

## Integration Model

[![Integration Model](docs/IntegrationModel.png)](https://github.com/aryan0142/sql-data-warehouse-project/blob/main/docs/IntegrationModel.drawio%20(1).png)

The warehouse integrates information from:

### CRM System

- Customer Information
- Product Information
- Sales Transactions

### ERP System

- Customer Demographics
- Customer Location Data
- Product Categories

---

## Star Schema

[![Data Model](docs/data_model.png)](https://github.com/aryan0142/sql-data-warehouse-project/blob/main/docs/data_model.drawio%20(2).png)

The Gold layer exposes a dimensional model consisting of:

### Dimension Tables

- `gold.dim_customers`
- `gold.dim_products`

### Fact Table

- `gold.fact_sales`

---

# Project Structure

```text
sql-data-warehouse-project
│
├── datasets
│   ├── source_crm
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   │
│   └── source_erp
│       ├── cust_az12.csv
│       ├── loc_a101.csv
│       └── px_cat_g1v2.csv
│
├── scripts
│   ├── bronze
│   │   ├── ddl_bronze.sql
│   │   └── load_bronze.sql
│   │
│   ├── silver
│   │   ├── ddl_silver.sql
│   │   └── load_silver.sql
│   │
│   └── gold
│       └── ddl_gold.sql
│
└── docs
    ├── Architecture.png
    ├── data_flow_diagram.png
    ├── IntegrationModel.png
    └── data_model.png
```

---

# Source Systems

## CRM Source

Contains transactional and master data.

### Tables

| Table | Description |
|---------|-------------|
| crm_cust_info | Customer master data |
| crm_prd_info | Product master data |
| crm_sales_details | Sales transaction data |

---

## ERP Source

Contains supplementary reference data.

### Tables

| Table | Description |
|---------|-------------|
| erp_cust_az12 | Customer demographic data |
| erp_loc_a101 | Customer location information |
| erp_px_cat_g1v2 | Product category hierarchy |

---

# Medallion Architecture

## Bronze Layer

### Purpose

The Bronze layer stores raw source data exactly as received from external systems.

No business rules or transformations are applied at this stage.

### Characteristics

- Raw ingestion
- Full-load processing
- Source preservation
- Historical snapshot storage
- Minimal processing

### Bronze Tables

#### CRM

- bronze.crm_cust_info
- bronze.crm_prd_info
- bronze.crm_sales_details

#### ERP

- bronze.erp_cust_az12
- bronze.erp_loc_a101
- bronze.erp_px_cat_g1v2

---

## Bronze ETL Process

The Bronze layer is populated through a stored procedure:

```sql
EXEC bronze.load_bronze;
```

### Loading Strategy

Each load performs:

1. Table truncation
2. Bulk CSV ingestion
3. Load duration tracking
4. Error handling

### Bulk Load Example

```sql
BULK INSERT bronze.crm_cust_info
FROM 'cust_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
```

### Features

- High-performance bulk loading
- Execution logging
- Batch duration monitoring
- TRY-CATCH error handling

---

## Silver Layer

### Purpose

The Silver layer transforms raw Bronze data into clean, validated, and standardized datasets.

This layer enforces business rules and improves data quality before dimensional modeling.

### Silver Tables

#### CRM

- silver.crm_cust_info
- silver.crm_prd_info
- silver.crm_sales_details

#### ERP

- silver.erp_cust_az12
- silver.erp_loc_a101
- silver.erp_px_cat_g1v2

### Audit Tracking

Every Silver table contains:

```sql
dwh_create_date DATETIME2 DEFAULT GETDATE()
```

This provides data lineage and warehouse load auditing.

---

## Silver ETL Process

The Silver layer is populated using:

```sql
EXEC silver.load_silver;
```

The process:

1. Truncates Silver tables
2. Applies cleansing logic
3. Standardizes business attributes
4. Validates records
5. Loads transformed datasets

---

# Data Quality Rules

## Customer Cleansing

### Duplicate Removal

Duplicate customer records are removed using:

```sql
ROW_NUMBER()
```

The most recent customer record is retained.

### Name Standardization

```sql
TRIM()
```

removes leading and trailing spaces.

### Marital Status Mapping

| Source | Standardized |
|----------|----------|
| S | Single |
| M | Married |
| Other | n/a |

### Gender Mapping

| Source | Standardized |
|----------|----------|
| F | Female |
| M | Male |
| Other | n/a |

---

## Product Cleansing

### Product Category Extraction

Category IDs are extracted from product keys.

### Product Line Mapping

| Source Code | Product Line |
|------------|--------------|
| M | Mountain |
| R | Road |
| T | Touring |
| S | Other Sales |
| Other | n/a |

### Cost Validation

```sql
ISNULL(prd_cost,0)
```

replaces missing product costs.

### Date Standardization

- Converts text dates to SQL DATE
- Corrects malformed product dates
- Repairs invalid end dates
- Preserves product history integrity

---

## Sales Cleansing

### Date Validation

Converts integer dates stored as:

```text
20240115
```

into SQL DATE values using:

```sql
TRY_CONVERT()
```

Invalid dates are converted to NULL.

### Sales Validation

Sales amount is recalculated when:

```sql
sales <> quantity * price
```

to maintain consistency.

### Price Validation

Invalid prices are recalculated using sales and quantity values.

---

## ERP Customer Cleansing

### Customer ID Standardization

Removes `NAS` prefixes from customer IDs.

### Birth Date Validation

Future birth dates are automatically rejected.

### Gender Standardization

| Source | Standardized |
|----------|----------|
| F/FEMALE | Female |
| M/MALE | Male |
| Other | n/a |

---

## ERP Location Standardization

| Source | Standardized |
|----------|----------|
| DE | Germany |
| US | United States |
| USA | United States |
| Blank | n/a |

Customer IDs are standardized by removing hyphens.

---

# Gold Layer

## Purpose

The Gold layer provides business-ready analytical datasets organized using a Star Schema.

The Gold layer is implemented through SQL views built on top of cleansed Silver tables.

### Objects

#### Dimensions

- gold.dim_customers
- gold.dim_products

#### Fact

- gold.fact_sales

---

## Dimension: Customers

### gold.dim_customers

Provides a unified customer dimension by integrating CRM and ERP customer information.

Attributes:

- Customer Key
- Customer ID
- Customer Number
- First Name
- Last Name
- Country
- Marital Status
- Gender
- Birth Date
- Create Date

Features:

- Surrogate key generation
- CRM and ERP integration
- Customer enrichment
- Demographic standardization

---

## Dimension: Products

### gold.dim_products

Provides enriched product information with category hierarchy.

Attributes:

- Product Key
- Product ID
- Product Number
- Product Name
- Category
- Subcategory
- Maintenance Type
- Product Cost
- Product Line
- Start Date

Features:

- Category integration
- Product hierarchy enrichment
- Active product filtering
- Surrogate key generation

Only active products are exposed:

```sql
WHERE prd_end_dt IS NULL
```

---

## Fact Table

### gold.fact_sales

Stores business transaction measures.

Measures:

- Sales Amount
- Quantity
- Price

Foreign Keys:

- customer_key
- product_key

Date Columns:

- order_date
- shipping_date
- due_date

---

# Star Schema Design

```text
                 dim_customers
                        │
                        │
                        ▼
                 fact_sales
                        ▲
                        │
                        │
                  dim_products
```

---

# ETL Workflow

### Step 1

Load raw source files into Bronze tables.

```sql
EXEC bronze.load_bronze;
```

### Step 2

Clean and standardize Bronze data into Silver tables.

```sql
EXEC silver.load_silver;
```

### Step 3

Query business-ready analytical views.

```sql
SELECT * FROM gold.dim_customers;
SELECT * FROM gold.dim_products;
SELECT * FROM gold.fact_sales;
```

---

# Technologies Used

- SQL Server
- T-SQL
- SQL Server Management Studio (SSMS)
- Data Warehousing
- ETL Development
- Star Schema Modeling
- Dimensional Modeling
- Draw.io
- Git
- GitHub

---

# Skills Demonstrated

### Data Engineering

- ETL Pipeline Development
- Data Warehouse Design
- Data Integration
- Data Transformation
- Data Validation
- Data Cleansing

### SQL Development

- Stored Procedures
- Views
- Window Functions
- Common Table Expressions (CTEs)
- Data Type Conversion
- Error Handling
- Bulk Loading

### Data Modeling

- Star Schema Design
- Fact and Dimension Modeling
- Surrogate Keys
- Historical Data Management
- Business Entity Integration

---

# Reporting Use Cases

The warehouse supports:

- Sales Analysis
- Revenue Reporting
- Customer Segmentation
- Product Performance Tracking
- Category Analysis
- Geographic Analysis
- Customer Demographic Analysis
- Executive Dashboards

---

# Future Enhancements

- Incremental Loading
- Change Data Capture (CDC)
- Automated Scheduling
- Metadata Management
- Data Quality Monitoring
- Power BI Dashboard Integration
- Data Lineage Framework
- Audit & Logging Tables

---

# Author

**Aryan Mesharam**

Data Engineering Portfolio Project

---

⭐ If you found this project useful, consider giving it a star on GitHub.
