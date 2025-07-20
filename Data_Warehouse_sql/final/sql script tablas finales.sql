CREATE DATABASE DataWarehouseDB;
GO

USE DataWarehouseDB;
GO

-- Customer 
CREATE TABLE dbo.dim_customer (
    Customer_ID INT PRIMARY KEY,
    Full_Name NVARCHAR(100),
    Email NVARCHAR(100),
    Telephone NVARCHAR(50),
    Job_Title NVARCHAR(100),
    Gender CHAR(1),
    Date_Of_Birth DATE,
    Country NVARCHAR(50),
	City NVARCHAR(50)
);

-- Product 
CREATE TABLE dbo.dim_product (
    Product_ID INT PRIMARY KEY,
    Category NVARCHAR(50),
    Sub_Category NVARCHAR(100),
    Description_PT NVARCHAR(MAX),
    Description_DE NVARCHAR(MAX),
    Description_FR NVARCHAR(MAX),
    Description_ES NVARCHAR(MAX),
    Description_EN NVARCHAR(MAX),
	Description_ZH NVARCHAR(MAX),
    Color NVARCHAR(50),
    Sizes NVARCHAR(50),
    Production_Cost DECIMAL(10,2)
);

select count (*) from dbo.dim_product
select DISTINCT SUB_CATEGORY from dbo.dim_product WHERE Category = 'N/A'

-- Store 
CREATE TABLE dbo.dim_store (
    Store_ID INT PRIMARY KEY,
    Store_Name NVARCHAR(100),
    Country NVARCHAR(100),
	City NVARCHAR(100),
    Zip_Code NVARCHAR(20),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    Number_Of_Employees INT
);

-- Employee 
CREATE TABLE dbo.dim_employee (
    Employee_ID INT PRIMARY KEY,
    Store_ID INT,
    Name NVARCHAR(100),
    Position NVARCHAR(50)
);

-- Discount
CREATE TABLE dbo.dim_discount (
    Discount_ID INT IDENTITY(1,1) PRIMARY KEY,
    Start_Date DATE,
    End_Date DATE,
    Discount DECIMAL(5,2),
    Description NVARCHAR(255),
    Category NVARCHAR(50),
    Sub_Category NVARCHAR(100)
);

CREATE TABLE dim_date (
    Date_ID INT PRIMARY KEY,
    Date DATE,
    Year INT,
    Quarter INT,
    Month INT,
    Day INT,
    Week INT,
    DayOfWeek INT,
    DayName NVARCHAR(20),
    MonthName NVARCHAR(20),
    IsWeekend BIT,
    IsLeapYear BIT,
    FirstDayOfMonth DATE,
    LastDayOfMonth DATE,
    ISO_Week INT
)

CREATE TABLE dbo.fact_exchange_rate (
    Exchange_Rate_ID INT IDENTITY(1,1) PRIMARY KEY,
    Date_ID INT NOT NULL,
	Date DATE NOT NULL,
	Day_Of_Month INT NOT NULL,
    Currency_Code NVARCHAR(3) NOT NULL,
    Exchange_Rate DECIMAL(18,6) NOT NULL,
);

-- Staging for fact_transactions
CREATE TABLE dbo.staging_fact_transactions (
    Invoice_ID NVARCHAR(50),
    Line INT,
    Customer_ID INT,
    Product_ID INT,
    Store_ID INT,
    Employee_ID INT,
    Date_ID INT,
    Datetime DATETIME2,
    Size NVARCHAR(10),
    Color NVARCHAR(50),
    Unit_Price DECIMAL(10,2),
    Quantity INT,
    Discount DECIMAL(5,2),
    Line_Total DECIMAL(12,2),
    SKU NVARCHAR(100),
    Currency NVARCHAR(3),
    Currency_Symbol NVARCHAR(5),
    Transaction_Type NVARCHAR(20),
    Payment_Method NVARCHAR(50)
);

-- Fact Table
CREATE TABLE dbo.fact_transactions (
    Invoice_ID NVARCHAR(50),
    Line INT,
    Customer_ID INT,
    Product_ID INT,
    Store_ID INT,
    Employee_ID INT,
    Date_ID INT,
	Datetime DATETIME2,
    Size NVARCHAR(10),
    Color NVARCHAR(50),
    Unit_Price DECIMAL(10,2),
    Quantity INT,
    Discount DECIMAL(5,2),
    Line_Total DECIMAL(12,2),
    SKU NVARCHAR(100),
    Currency NVARCHAR(3),
    Currency_Symbol NVARCHAR(5),
    Transaction_Type NVARCHAR(20),
    Payment_Method NVARCHAR(50),
    CONSTRAINT PK_fact_transactions PRIMARY KEY (Invoice_ID, Line, Product_ID),
    CONSTRAINT FK_fact_customer FOREIGN KEY (Customer_ID) REFERENCES dim_customer(Customer_ID),
    CONSTRAINT PK_fact_product FOREIGN KEY (Product_ID) REFERENCES dim_product(Product_ID),
    CONSTRAINT FK_fact_store FOREIGN KEY (Store_ID) REFERENCES dim_store(Store_ID),
    CONSTRAINT FK_fact_employee FOREIGN KEY (Employee_ID) REFERENCES dim_employee(Employee_ID),
    CONSTRAINT FK_fact_date FOREIGN KEY (Date_ID) REFERENCES dim_date(Date_ID)
);
GO

CREATE PROCEDURE sp_merge_fact_transactions
AS
BEGIN
MERGE INTO dbo.fact_transactions AS target
USING dbo.staging_fact_transactions AS source
ON target.Invoice_ID = source.Invoice_ID
   AND target.Line = source.Line
   AND target.Product_ID = source.Product_ID
WHEN MATCHED THEN
    UPDATE SET
        target.Customer_ID = source.Customer_ID,
        target.Store_ID = source.Store_ID,
        target.Employee_ID = source.Employee_ID,
        target.Date_ID = source.Date_ID,
        target.Datetime = source.Datetime,
        target.Size = source.Size,
        target.Color = source.Color,
        target.Unit_Price = source.Unit_Price,
        target.Quantity = source.Quantity,
        target.Discount = source.Discount,
        target.Line_Total = source.Line_Total,
        target.SKU = source.SKU,
        target.Currency = source.Currency,
        target.Currency_Symbol = source.Currency_Symbol,
        target.Transaction_Type = source.Transaction_Type,
        target.Payment_Method = source.Payment_Method
WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        Invoice_ID, Line, Customer_ID, Product_ID, Store_ID, Employee_ID, Date_ID,
        Datetime, Size, Color, Unit_Price, Quantity, Discount, Line_Total,
        SKU, Currency, Currency_Symbol, Transaction_Type, Payment_Method
    )
    VALUES (
        source.Invoice_ID, source.Line, source.Customer_ID, source.Product_ID,
        source.Store_ID, source.Employee_ID, source.Date_ID, source.Datetime,
        source.Size, source.Color, source.Unit_Price, source.Quantity, source.Discount,
        source.Line_Total, source.SKU, source.Currency, source.Currency_Symbol,
        source.Transaction_Type, source.Payment_Method
    );
END
GO

GO
CREATE PROCEDURE sp_insert_dim_date
AS
BEGIN
    ;WITH DateRange AS (
        SELECT CAST('2023-01-01' AS DATE) AS DateValue
        UNION ALL
        SELECT DATEADD(DAY, 1, DateValue)
        FROM DateRange
        WHERE DateValue < '2025-12-31'
    )
    INSERT INTO DataWarehouseDB.dbo.dim_date (
        Date_ID, Date, Year, Quarter, Month, Day, Week, DayOfWeek,
        DayName, MonthName, IsWeekend, IsLeapYear, FirstDayOfMonth, LastDayOfMonth, ISO_Week
    )
    SELECT
        YEAR(DateValue) * 10000 + MONTH(DateValue) * 100 + DAY(DateValue) AS Date_ID,
        DateValue AS Date,
        YEAR(DateValue) AS Year,
        DATEPART(QUARTER, DateValue) AS Quarter,
        MONTH(DateValue) AS Month,
        DAY(DateValue) AS Day,
        DATEPART(WEEK, DateValue) AS Week,
        DATEPART(WEEKDAY, DateValue) AS DayOfWeek,
        DATENAME(WEEKDAY, DateValue) AS DayName,
        DATENAME(MONTH, DateValue) AS MonthName,
        CASE WHEN DATEPART(WEEKDAY, DateValue) IN (1,7) THEN 1 ELSE 0 END AS IsWeekend,
        CASE WHEN YEAR(DateValue) % 4 = 0 AND (YEAR(DateValue) % 100 != 0 OR YEAR(DateValue) % 400 = 0) THEN 1 ELSE 0 END AS IsLeapYear,
        DATEADD(DAY, 1 - DAY(DateValue), DateValue) AS FirstDayOfMonth,
        EOMONTH(DateValue) AS LastDayOfMonth,
        DATEPART(ISO_WEEK, DateValue) AS ISO_Week
    FROM DateRange
    WHERE NOT EXISTS (
        SELECT 1 FROM DataWarehouseDB.dbo.dim_date d
        WHERE d.Date_ID = YEAR(DateValue) * 10000 + MONTH(DateValue) * 100 + DAY(DateValue)
    )
    OPTION (MAXRECURSION 1100)
END
GO

execute sp_insert_dim_date;

