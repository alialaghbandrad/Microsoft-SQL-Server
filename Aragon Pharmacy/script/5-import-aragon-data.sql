/*
 * Purpose: create database for Aragon Pharmacy
 * Script Date: FEB 12, 2021
 * Developed by: Team ZAYC (Zhiwei Li, Ali Alaghbandrad, Yaowu Huang, Carlo Nosliw Naude)
 */

USE AragonPharmacy_ZAYC;
GO

SELECT * FROM SYSOBJECTS WHERE xtype = 'U'; -- LIST ALL DEFINED TABLES
GO

/* Importing Data */

-- Class
BULK INSERT HumanResource.tblClass
	FROM 'F:\12.PROJECTS\DATABASE\sqlserver\Aragon\data\Class.txt'
	WITH 
	(
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
	);
GO

SELECT * FROM HumanResource.tblClass;
GO

-- Training
BULK INSERT HumanResource.tblEmployeeTraining
	FROM 'F:\12.PROJECTS\DATABASE\sqlserver\Aragon\data\EmployeeTraining.txt'
	WITH 
	(
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
	);
GO

SELECT * FROM HumanResource.tblEmployeeTraining;
GO

-- Job title
INSERT INTO HumanResource.tblJobTitle (Title)
	VALUES ('Owner'),('Pharmacist'),('Technician'),('Cashier'),('Manager');
GO

SELECT * FROM HumanResource.tblJobTitle;
GO

-- Employee
DROP TABLE IF EXISTS #tblEmp;
CREATE TABLE #tblEmp
(
	EmpID INT IDENTITY(1,1) NOT NULL,
	EmpFirst NVARCHAR(30) NOT NULL,
	EmpMid NVARCHAR(30) NULL,
	EmpLast NVARCHAR(30) NOT NULL,
	EmpSIN NCHAR(9) MASKED WITH (FUNCTION = 'DEFAULT()') NOT NULL,
	BirthDate DATE NOT NULL, --  FORMAT(BirthDate, 'd', 'en-US') AS 'Birth Date' 
	StartDate DATE NOT NULL,
	EndDate DATE NULL,
	Address NVARCHAR(30) NOT NULL,
	City NVARCHAR(30) NOT NULL,
	Province NCHAR(2) NOT NULL, -- UPPER(Province) AS Province
	PostCode NCHAR(6) NOT NULL, 
	JobID INT NOT NULL,
	Memo NVARCHAR(255) NOT NULL,
	Phone NCHAR(10) NULL,
	Cell NCHAR(10) NOT NULL,
	Salary MONEY MASKED WITH (FUNCTION = 'DEFAULT()') NULL,
	HourlyRate MONEY MASKED WITH (FUNCTION = 'DEFAULT()') NULL,
	Review DATE NULL
);
GO

BULK INSERT #tblEmp
	FROM 'F:\12.PROJECTS\DATABASE\sqlserver\Aragon\data\Employee.txt'
	WITH 
	(
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		KEEPNULLS,
		FIRSTROW = 2
	);
GO

SELECT * FROM #tblEmp;
GO

INSERT INTO HumanResource.tblEmployee (EmpFirst,EmpMid,EmpLast,EmpSIN,BirthDate,StartDate,EndDate,Address,City,Province,PostCode,JobID,Memo,Phone,Cell,Salary,HourlyRate,Review)
	SELECT EmpFirst,EmpMid,EmpLast,EmpSIN,BirthDate,StartDate,EndDate,Address,City,Province,PostCode,JobID,Memo,Phone,Cell,Salary,HourlyRate,Review
		FROM #tblEmp;
GO

SELECT * FROM HumanResource.tblEmployee order by EmpID, EmpLast;
GO

-- Absence
INSERT INTO HumanResource.tblAbsentCategory (AbsDescription)
	VALUES ('Illness'),('Work-related Illness'),('Medical Appointment'),
			('Paid Maternity'),('Unpaid Maternity'),('Dependent Care'),
			('Personal Business');
GO

SELECT * FROM HumanResource.tblAbsentCategory;
GO

DROP PROCEDURE IF EXISTS #Absence;
GO

CREATE PROCEDURE #Absence
AS
	DECLARE @EMP INT, @StartDate DATE, @AbsStart DATE, @AbsEnd DATE, @RANDEMPID INT, @RANDABS INT;
	SELECT @EMP = MIN(EmpID) FROM HumanResource.tblEmployee WHERE EndDate IS NULL;
	WHILE @EMP IS NOT NULL
	BEGIN
		SELECT @StartDate = StartDate FROM HumanResource.tblEmployee WHERE EmpID = @EMP;
		SET @RANDEMPID = ROUND(1+RAND()*(@EMP-1),0);
		SET @RANDABS = ROUND(1+RAND()*(6),0);
		SET @AbsStart = DATEADD(day, ROUND(30+RAND()*(DATEDIFF(day, @StartDate, GETDATE())-35),0), @StartDate);
		SET @AbsEnd = DATEADD(day, ROUND(RAND()*(5),0), @AbsStart);
		-- SELECT @RANDEMPID, @RANDABS, @AbsStart, @AbsEnd;
		INSERT HumanResource.tblAbsent ( EmpID, AbsCategory, AbsStartDate, AbsEndDate)
			VALUES (@RANDEMPID, @RANDABS, @AbsStart, @AbsEnd);
		SELECT @EMP = MIN(EmpID) FROM HumanResource.tblEmployee WHERE EmpID > @EMP AND EndDate IS NULL;
	END
GO

EXEC #Absence;
GO

SELECT * FROM HumanResource.tblAbsent;
GO

-- Health Plan
BULK INSERT Customers.tblHealthPlan
	FROM 'F:\12.PROJECTS\DATABASE\sqlserver\Aragon\data\HealthPlan.txt'
	WITH 
	(
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		KEEPNULLS,
		FIRSTROW = 2
	);
GO

SELECT * FROM Customers.tblHealthPlan;
GO

-- Household
BULK INSERT Customers.tblHousehold
	FROM 'F:\12.PROJECTS\DATABASE\sqlserver\Aragon\data\Household.txt'
	WITH 
	(
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		KEEPNULLS,
		FIRSTROW = 2
	);
GO

SELECT * FROM Customers.tblHousehold;
GO

INSERT INTO Customers.tblHousehold (Address,City,Province,PostCode)
	VALUES ('21 Lakeshore Street','Sainte-Anne', 'QC', 'H5Q2E6');
SELECT * FROM Customers.tblHousehold;
GO

-- Customer
DROP TABLE IF EXISTS #Cust;
GO

CREATE TABLE #Cust
(
	CustID INT IDENTITY(1,1) NOT NULL,
	CustFirst NVARCHAR(30) NOT NULL,
	CustLast NVARCHAR(30) NOT NULL,
	Phone NCHAR(10) NULL,
	BirthDate DATE NOT NULL,
	Gender NCHAR(1)	NOT NULL,
	Balance MONEY NOT NULL DEFAULT 0,
	ChildProofCap BIT NOT NULL DEFAULT 1,
	PlanID NVARCHAR(16) NULL,
	HouseID INT NOT NULL,
	HeadHH bit null,
	Allergies NVARCHAR(50) NOT NULL DEFAULT 'N/A'
);
GO

BULK INSERT #Cust
	FROM 'F:\12.PROJECTS\DATABASE\sqlserver\Aragon\data\Customer.txt'
	WITH 
	(
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		KEEPNULLS,
		FIRSTROW = 2
	);
GO

INSERT INTO Customers.tblCustomer (CustFirst,CustLast,Phone,BirthDate,Gender,Balance,ChildProofCap,PlanID,HouseID,Allergies)
	SELECT CustFirst,CustLast,Phone,BirthDate,Gender,Balance,ChildProofCap,PlanID,HouseID,Allergies FROM #Cust;
GO

SELECT * FROM Customers.tblCustomer;
GO

-- UPDATE IMPORTED ALLERGIES, WHICH IS BLANK, WITH 'N/A'
UPDATE Customers.tblCustomer 
	SET Allergies = 'N/A'
	WHERE Allergies = ' ';
GO

SELECT * FROM Customers.tblCustomer;
GO

-- ADD A CUSTOMER WHITHOUT RX
INSERT INTO Customers.tblCustomer (CustFirst,CustLast,Phone,BirthDate,Gender,ChildProofCap,PlanID,HouseID)
	VALUES('James', 'Lu', '4385628965', '1986-02-28', 'M', 0, '00087-98A', 28);
SELECT * FROM Customers.tblCustomer;
GO

--Clinic
BULK INSERT Pharmacy.tblClinic
	FROM 'F:\12.PROJECTS\DATABASE\sqlserver\Aragon\data\Clinic.txt'
	WITH 
	(
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		KEEPNULLS,
		FIRSTROW = 2
	);
GO

SELECT * FROM Pharmacy.tblClinic;
GO

-- Doctor
DROP TABLE IF EXISTS #Doc;
GO

CREATE TABLE #Doc
(
	DoctorID INT IDENTITY(1,1) NOT NULL,
	DocFirst NVARCHAR(30) NOT NULL,
	DocLast NVARCHAR(30) NOT NULL,
	Phone NCHAR(10) NULL, -- STUFF(STUFF(STUFF(Phone, 7, 0, '-'), 4, 0, ') '), 1, 0, '(') AS Phone
	Cell NCHAR(10) NOT NULL,
	ClinicID INT NOT NULL,
	MINC NCHAR(12) NOT NULL, -- MEDICAL IDENTIFICATION NUMBER FOR CANADA 
	CONSTRAINT PK_TDOC PRIMARY KEY (DoctorID),
	CONSTRAINT CK_TDOC_PHONE CHECK (Phone LIKE REPLICATE('[0-9]', 10))
);
GO

BULK INSERT #Doc
	FROM 'F:\12.PROJECTS\DATABASE\sqlserver\Aragon\data\Doctor.txt'
	WITH 
	(
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		KEEPNULLS,
		FIRSTROW = 2
	);
GO

INSERT INTO Pharmacy.tblDoctor (DocFirst,DocLast,Phone,Cell,ClinicID,MINC)
	SELECT DocFirst,DocLast,Phone,Cell,ClinicID,MINC FROM #Doc;
GO

SELECT * FROM Pharmacy.tblDoctor;
GO

-- Unit
INSERT INTO Operations.tblUnit( UnitDescription ) VALUES ('mg'), ('ml'), ('tsp');
GO

SELECT * FROM Operations.tblUnit;
GO

-- Dosage Form
INSERT INTO Operations.tblDosageForm (DosageFormDescription) VALUES ('pill'),('bottle');
GO

SELECT * FROM Operations.tblDosageForm;
GO

-- Drug
DROP TABLE IF EXISTS #DRUG;
CREATE TABLE #DRUG
(
	DIN NCHAR(8) NOT NULL,
	DrugName NVARCHAR(30) NOT NULL,
	IsGeneric BIT NOT NULL,
	DrugDescription NVARCHAR(100) NOT NULL,
	DosageForm NVARCHAR(10) NOT NULL,
	Dosage INT NOT NULL,
	Unit NVARCHAR(10) NOT NULL,
	Cost NVARCHAR(10) NOT NULL,
	Price NVARCHAR(10) NOT NULL,
	DispensingFee NVARCHAR(10) NOT NULL,
	Interactions NVARCHAR(20) NOT NULL,
	Supplier NVARCHAR(50) NOT NULL
);
GO

BULK INSERT #DRUG
	FROM 'F:\12.PROJECTS\DATABASE\sqlserver\Aragon\data\Drug.txt'
	WITH 
	(
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		KEEPNULLS,
		FIRSTROW = 2
	);
GO

-- Supplier
INSERT INTO Operations.tblSupplier (SupplierName) 
	SELECT Supplier FROM #DRUG GROUP BY Supplier;
GO

SELECT * FROM Operations.tblSupplier;
GO

-- ADD SUPPLIERS WHITHOUT DRUGS PROVIDED
INSERT INTO Operations.tblSupplier (SupplierName)
	VALUES ('Johnson & Johnson Inc.'),('Pfizer Canada');
SELECT * FROM Operations.tblSupplier;
GO

INSERT INTO Operations.tblDrug (DIN,DrugName,IsGeneric,DrugDescription,Dosage,
								UnitID,DosageFormID,Cost,Price,DispensingFee,Interactions,SupplierID)
	SELECT DIN,DrugName,IsGeneric,DrugDescription,Dosage,
			IIF(Unit='mg',1,IIF(Unit='ml', 2, 3)) AS UnitID, IIF(DosageForm='Pill', 1, 2) AS DosageFormID,
			PARSE(Cost AS SMALLMONEY) AS Cost,PARSE(Price AS SMALLMONEY) AS Price,PARSE(DispensingFee AS SMALLMONEY) as DispensingFee,
			Interactions, SupplierID 
			FROM #DRUG
			INNER JOIN Operations.tblSupplier AS TBLSUPPLIER ON #DRUG.Supplier = TBLSUPPLIER.SupplierName;
GO

SELECT * FROM Operations.tblDrug;
GO

-- UPDATE IMPORTED INTERACTIONS, WHICH IS BLANK, AS NULL
UPDATE Operations.tblDrug 
	SET Interactions = NULL
	WHERE Interactions = ' ';
GO

SELECT * FROM Operations.tblDrug;
GO

-- INSERT STOCKQUANTITY WITH RANDOM NUMBER
DROP PROCEDURE IF EXISTS #Quantity;
GO

CREATE PROCEDURE #Quantity
AS
	DECLARE @DIN NCHAR(8);
	SELECT @DIN = MIN(DIN) FROM Operations.tblDrug;
	WHILE @DIN IS NOT NULL
	BEGIN
		UPDATE Operations.tblDrug 
			SET StockQuantity = ROUND(RAND()*100,0)
			WHERE DIN = @DIN;
		SELECT @DIN = MIN(DIN) FROM Operations.tblDrug WHERE DIN > @DIN;
	END
GO

EXEC #Quantity;
GO

SELECT * FROM Operations.tblDrug;
GO

-- Prescription
DROP TABLE IF EXISTS #RX;
CREATE TABLE #RX
(
	PrescriptionID INT NOT NULL,
	DIN NCHAR(8) NOT NULL,
	Quantity DECIMAL(5,2) NOT NULL,
	Unit NCHAR(2) NOT NULL,
	IssueDate DATE NOT NULL,
	ExpireDate DATE NOT NULL,
	Refills TINYINT NOT NULL DEFAULT 0,
	AutoRefill BIT NOT NULL DEFAULT 0,
	RefillsUsed TINYINT NOT NULL DEFAULT 0,
	Instructions NVARCHAR(50) NULL,
	CustID INT NOT NULL,
	DoctorID INT NOT NULL
);
GO

BULK INSERT #RX
	FROM 'F:\12.PROJECTS\DATABASE\sqlserver\Aragon\data\Rx.txt'
	WITH 
	(
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		KEEPNULLS,
		FIRSTROW = 2
	);
GO

INSERT INTO Pharmacy.tblRx (CustID,DoctorID,IssueDate,ExpireDate,Refills,AutoRefill,RefillsUsed)
	SELECT CustID,DoctorID,IssueDate,ExpireDate,Refills,AutoRefill,RefillsUsed 
		FROM #RX;
GO

SELECT * FROM Pharmacy.tblRx;
GO

-- Prescription Items
INSERT INTO Pharmacy.tblRxItem(PrescriptionID,DIN,Quantity,UnitID, Instructions)
	SELECT PrescriptionID,DIN,Quantity,IIF(Unit='mg',1,IIF(Unit='ml', 2, 3)) AS UnitID, Instructions FROM #RX;
GO

-- INSERT STOCKQUANTITY WITH RANDOM NUMBER
DROP PROCEDURE IF EXISTS #RxQuantity;
GO

CREATE PROCEDURE #RxQuantity
AS
	DECLARE @DIN NCHAR(8);
	SELECT @DIN = MIN(DIN) FROM Pharmacy.tblRxItem;
	WHILE @DIN IS NOT NULL
	BEGIN
		UPDATE Pharmacy.tblRxItem 
			SET Quantity = ROUND(5+RAND()*5,0)
			WHERE DIN = @DIN;
		SELECT @DIN = MIN(DIN) FROM Pharmacy.tblRxItem WHERE DIN > @DIN;
	END
GO

EXEC #RxQuantity;
GO

SELECT * FROM Pharmacy.tblRxItem;
GO

-- Refill
DROP TABLE IF EXISTS #FILL;
CREATE TABLE #FILL
(
	PrescriptionID INT NOT NULL,
	RefillDate DATE NOT NULL, 
	EmpID INT NOT NULL
);
GO

BULK INSERT #FILL
	FROM 'F:\12.PROJECTS\DATABASE\sqlserver\Aragon\data\Refill.txt'
	WITH 
	(
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		KEEPNULLS,
		FIRSTROW = 2
	);
GO

INSERT INTO Pharmacy.tblRefill(PrescriptionID,RefillDate,EmpID)
	SELECT PrescriptionID,RefillDate,EmpID FROM #FILL;
GO

SELECT * FROM Pharmacy.tblRefill;
GO

-- UPDATE LanguangeSecond, LanguangeProficiency ON Emplyee
CREATE TABLE #TemptblEmployee
(
	EmpID int,
	LanguageSecond nvarchar(30),
	LanguageProficiency tinyint
)
;
GO

BULK INSERT #TemptblEmployee
FROM 'F:\12.PROJECTS\DATABASE\sqlserver\Aragon\data\EmployeeLanguange.csv'
WITH
(
	FIRSTROW=2,
	ROWTERMINATOR='\n',
	FIELDTERMINATOR = ','
)
;
GO


Update E
SET 
E.LanguageSecond = TE.LanguageSecond, 
E.LanguageProficiency = TE.LanguageProficiency
FROM HumanResource.tblEmployee AS E 
INNER JOIN #TemptblEmployee AS TE
	ON E.EmpID = TE.EmpID
;
GO

select * from HumanResource.tblEmployee 
;
GO