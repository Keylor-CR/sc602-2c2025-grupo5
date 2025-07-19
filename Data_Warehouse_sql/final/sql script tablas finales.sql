CREATE DATABASE DataWarehouseDB;
GO

USE DataWarehouseDB;
GO

-- Customer 
CREATE TABLE dim_customer (
    Customer_ID INT PRIMARY KEY,
    Full_Name NVARCHAR(100),
    Email NVARCHAR(100),
    Telephone NVARCHAR(50),
    Gender CHAR(1),
    Date_Of_Birth DATE,
    Job_Title NVARCHAR(100),
    City NVARCHAR(100),
    Country NVARCHAR(100)
);

-- Product 
CREATE TABLE dim_product (
    Product_ID INT PRIMARY KEY,
    Category NVARCHAR(50),
    Sub_Category NVARCHAR(100),
    Description_PT NVARCHAR(MAX),
    Description_DE NVARCHAR(MAX),
    Description_FR NVARCHAR(MAX),
    Description_ES NVARCHAR(MAX),
    Description_EN NVARCHAR(MAX),
    Color NVARCHAR(50),
    Sizes NVARCHAR(50),
    Production_Cost DECIMAL(10,2)
);

-- Store 
CREATE TABLE dim_store (
    Store_ID INT PRIMARY KEY,
    Store_Name NVARCHAR(100),
    City NVARCHAR(100),
    Country NVARCHAR(100),
    Zip_Code NVARCHAR(20),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    Number_Of_Employees INT
);

-- Employee 
CREATE TABLE dim_employee (
    Employee_ID INT PRIMARY KEY,
    Store_ID INT,
    Name NVARCHAR(100),
    Position NVARCHAR(50)
);

-- Discount
CREATE TABLE dim_discount (
    Discount_ID INT IDENTITY(1,1) PRIMARY KEY,
    Start_Date DATE,
    End_Date DATE,
    Discount DECIMAL(5,2),
    Description NVARCHAR(255),
    Category NVARCHAR(50),
    Sub_Category NVARCHAR(100)
);

-- Date 
CREATE TABLE dim_date (
    Date_ID NVARCHAR(50) PRIMARY KEY,
    Year INT,
    Month INT,
    Day INT,
    Weekday NVARCHAR(20),
    Hour INT
);

-- Fact Table
CREATE TABLE fact_transactions (
    Invoice_ID NVARCHAR(50),
    Line INT,
    Customer_ID INT,
    Product_ID INT,
    Store_ID INT,
    Employee_ID INT,
    Unit_Price DECIMAL(10,2),
    Quantity INT,
    Discount DECIMAL(5,2),
    Line_Total DECIMAL(12,2),
    Size NVARCHAR(10),
    Color NVARCHAR(50),
    SKU NVARCHAR(100),
    Transaction_Type NVARCHAR(20),
    Payment_Method NVARCHAR(50),
    Currency NVARCHAR(3),
    Currency_Symbol NVARCHAR(5),
    Date_ID NVARCHAR(50),
    Datetime DATE,
    CONSTRAINT PK_fact_transactions PRIMARY KEY (Invoice_ID, Line),
    CONSTRAINT FK_fact_customer FOREIGN KEY (Customer_ID) REFERENCES dim_customer(Customer_ID),
    CONSTRAINT PK_fact_product FOREIGN KEY (Product_ID) REFERENCES dim_product(Product_ID),
    CONSTRAINT FK_fact_store FOREIGN KEY (Store_ID) REFERENCES dim_store(Store_ID),
    CONSTRAINT FK_fact_employee FOREIGN KEY (Employee_ID) REFERENCES dim_employee(Employee_ID),
    CONSTRAINT FK_fact_date FOREIGN KEY (Date_ID) REFERENCES dim_date(Date_ID)
);

