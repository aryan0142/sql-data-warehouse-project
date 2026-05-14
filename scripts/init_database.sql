/* 

=================================================================================
Create Database and Schemas 
=================================================================================
Script purpose:
  Dropping the existing DataWarehouse database (if it exists)
  Recreating a clean DataWarehouse database
  Initializing a medallion architecture with three schemas:
    bronze → Raw data ingestion layer
    silver → Cleaned and transformed data
    gold → Business-ready, aggregated data

⚠️ **Warning**

Running this script will permanently delete the existing `DataWarehouse` database along with all its data.

Make sure to:
- Backup any important data before executing
- Confirm you are running it in the correct environment

This action cannot be undone.
*/


USE master;
GO


-- Drop and Recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

-- Create the DataWarehouse database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas 
CREATE SCHEMA bronze;
GO
  
CREATE SCHEMA silver;
GO
  
CREATE SCHEMA gold;
GO
