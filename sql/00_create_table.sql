-- ============================================================
-- CSV to SQL Server Loader - database & destination table
-- Run this once in SQL Server Management Studio (SSMS) before
-- running the notebook.
-- ============================================================

-- 1. Create the database (skip if you already have one to use).
IF DB_ID('CSV_Loader_Demo') IS NULL
    CREATE DATABASE CSV_Loader_Demo;
GO

USE CSV_Loader_Demo;
GO

-- 2. Create the destination table that matches the sample CSV.
--    The notebook inserts into [dbo].[customer_age] (name, age).
IF OBJECT_ID('dbo.customer_age', 'U') IS NOT NULL
    DROP TABLE dbo.customer_age;
GO

CREATE TABLE dbo.customer_age (
    name NVARCHAR(255),
    age  INT
);
GO

-- 3. (optional) Confirm it loaded after running the notebook.
-- SELECT TOP (10) * FROM dbo.customer_age;
-- SELECT COUNT(*) AS total_rows FROM dbo.customer_age;
