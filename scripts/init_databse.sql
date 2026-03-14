/*
=================================================================
Create database and Schemas
=================================================================

This Script creates a new database named "DataWarehouse". If the database exists its drops it and creates it from scratch.
Finally this scripts creates the schemas needed for the medallion strucutre to be implemented in this warehouse


*/



--Create Database "DataWarehouse"
USE master

DROP DATABASE IF EXISTS DataWarehouse;
CREATE DATABASE DataWarehouse;

--Creating Schemas for the Medallion Structure
USE DataWarehouse

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;