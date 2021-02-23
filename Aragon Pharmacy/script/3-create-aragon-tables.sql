/*
 * Purpose: create database for Aragon Pharmacy
 * Script Date: FEB 12, 2021
 * Developed by: Team ZAYC (Zhiwei Li, Ali Alaghbandrad, Yaowu Huang, Carlo Nosliw Naude)
 */

USE AragonPharmacy_ZAYC;
GO

DROP TABLE IF EXISTS HumanResource.tblJobTitle;
GO

CREATE TABLE HumanResource.tblJobTitle
(
	JobID INT IDENTITY(1,1) NOT NULL,
	Title NVARCHAR(30) NOT NULL,
	CONSTRAINT PK_JOB PRIMARY KEY (JobID)
);
GO

DROP TABLE IF EXISTS HumanResource.tblEmployee;
GO

CREATE TABLE HumanResource.tblEmployee
(
	EmpID INT IDENTITY(1,1) NOT NULL,
	EmpFirst NVARCHAR(30) NOT NULL,
	EmpMid NVARCHAR(30) NULL,
	EmpLast NVARCHAR(30) NOT NULL,
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
	Review DATE NULL,
	LanguageSecond NVARCHAR(30) NOT NULL DEFAULT 'N/A',
	LanguageProficiency TINYINT NOT NULL DEFAULT 0,
	-- SENSITIVE DATA TO BE PROTECTED
	EmpSIN NCHAR(9) MASKED WITH (FUNCTION = 'DEFAULT()') NOT NULL,
	Salary MONEY MASKED WITH (FUNCTION = 'DEFAULT()') NULL,
	HourlyRate MONEY MASKED WITH (FUNCTION = 'DEFAULT()') NULL,
	CONSTRAINT PK_EMP PRIMARY KEY (EmpID),
	CONSTRAINT UQ_EMP_SIN UNIQUE (EmpSIN),
	CONSTRAINT CK_EMP_PROV CHECK 
		(Province IN ('QC', 'ON', 'BC', 'NL', 'PE', 'NS', 'NB', 'MB', 'SK', 'AB', 'YT', 'NT', 'NU')),
	CONSTRAINT CK_EMP_SIN CHECK (EmpSIN LIKE REPLICATE('[0-9]', 9)),
	CONSTRAINT CK_EMP_PHONE CHECK (Phone LIKE REPLICATE('[0-9]', 10)),
	CONSTRAINT CK_EMP_CELL CHECK (Cell LIKE REPLICATE('[0-9]', 10)),
	CONSTRAINT CK_EMP_POST CHECK (PostCode LIKE '[A-Z][0-9][A-Z][0-9][A-Z][0-9]'),
	CONSTRAINT CK_EMP_LANG CHECK (LanguageProficiency BETWEEN 0 AND 5) -- 0(LOW) -> 5(HIGH)
);
GO

DROP TABLE IF EXISTS HumanResource.tblAbsentCategory;
GO

CREATE TABLE HumanResource.tblAbsentCategory
(
	AbsCategory INT IDENTITY(1,1) NOT NULL,
	AbsDescription NVARCHAR(50) NOT NULL,
	CONSTRAINT PK_ABSCAT PRIMARY KEY (AbsCategory)
);
GO

DROP TABLE IF EXISTS HumanResource.tblAbsent;
GO

CREATE TABLE HumanResource.tblAbsent
(
	AbsID INT IDENTITY(1,1) NOT NULL,
	EmpID INT NOT NULL,
	AbsCategory INT NOT NULL,
	AbsStartDate DATE NOT NULL,
	AbsEndDate DATE NOT NULL,
	CONSTRAINT PK_ABS PRIMARY KEY (AbsID)
);
GO

DROP TABLE IF EXISTS HumanResource.tblClass;
GO

CREATE TABLE HumanResource.tblClass
(
	ClassID INT IDENTITY(1,1) NOT NULL,
	ClassDesc NVARCHAR(50) NOT NULL,
	Cost MONEY NOT NULL DEFAULT 0,
	Renewal TINYINT NOT NULL DEFAULT 0,
	IsRequired BIT NOT NULL DEFAULT 0,
	ProviderName NVARCHAR(50) NOT NULL,
	CONSTRAINT PK_CLS PRIMARY KEY (ClassID)
);
GO

DROP TABLE IF EXISTS HumanResource.tblEmployeeTraining;
GO

CREATE TABLE HumanResource.tblEmployeeTraining
(
	EmpID INT NOT NULL,
	ClassDate DATE NOT NULL, --  FORMAT(ClassDate, 'd', 'en-US') AS 'Class Date' 
	ClassID INT NOT NULL,
	CONSTRAINT PK_EMPTRN PRIMARY KEY (EmpID, ClassID, ClassDate)
);
GO

DROP TABLE IF EXISTS Operations.tblUnit;
GO

CREATE TABLE Operations.tblUnit
(
	UnitID INT IDENTITY(1,1) NOT NULL,
	UnitDescription NVARCHAR(10) NOT NULL,
	CONSTRAINT PK_UNIT PRIMARY KEY (UnitID)
);
GO

DROP TABLE IF EXISTS Operations.tblDosageForm;
GO

CREATE TABLE Operations.tblDosageForm
(
	DosageFormID INT IDENTITY(1,1) NOT NULL,
	DosageFormDescription NVARCHAR(20) NOT NULL,
	CONSTRAINT PK_DFORM PRIMARY KEY (DosageFormID)
)
;
GO

DROP TABLE IF EXISTS Operations.tblSupplier;
GO

CREATE TABLE Operations.tblSupplier
(
	SupplierID INT IDENTITY(1,1) NOT NULL,
	SupplierName NVARCHAR(50) NOT NULL,
	CONSTRAINT PK_SUP PRIMARY KEY (SupplierID) 
);
GO

DROP TABLE IF EXISTS Operations.tblDrug;
GO

CREATE TABLE Operations.tblDrug
(
	DIN NCHAR(8) NOT NULL,
	DrugName NVARCHAR(30) NOT NULL,
	IsGeneric BIT NOT NULL,
	DrugDescription NVARCHAR(100) NOT NULL,
	UnitID INT NOT NULL,
	Dosage INT NOT NULL,
	DosageFormID INT NOT NULL,
	Cost SMALLMONEY NOT NULL,
	Price SMALLMONEY NOT NULL,
	DispensingFee SMALLMONEY NOT NULL,
	Interactions NVARCHAR(20) NULL,
	StockQuantity INT NOT NULL DEFAULT 0,
	SupplierID INT NOT NULL,
	CONSTRAINT PK_DRUG PRIMARY KEY (DIN),
	CONSTRAINT CK_DRUG_DIN CHECK (DIN LIKE REPLICATE('[0-9]', 8))
)
ON Aragon_FG;
GO

DROP TABLE IF EXISTS Customers.tblHealthPlan;
GO

CREATE TABLE Customers.tblHealthPlan
(
	PlanID NVARCHAR(16) NOT NULL,
	PlanName NVARCHAR(30) NOT NULL,
	Address NVARCHAR(30) NOT NULL,
	City NVARCHAR(30) NOT NULL,
	Province NCHAR(2) NOT NULL, -- UPPER(Province) AS Province
	PostCode NCHAR(6) NOT NULL,
	Phone NCHAR(10) NOT NULL,
	Days INT NOT NULL,
	Website NVARCHAR(50) NULL,
	CONSTRAINT PK_HPLAN PRIMARY KEY (PlanID),
	CONSTRAINT CK_HPLAN_PROV CHECK 
		(Province IN ('QC', 'ON', 'BC', 'NL', 'PE', 'NS', 'NB', 'MB', 'SK', 'AB', 'YT', 'NT', 'NU')),
	CONSTRAINT CK_HPLAN_PHONE CHECK (Phone LIKE REPLICATE('[0-9]', 10)),
	CONSTRAINT CK_HPLAN_POST CHECK (PostCode LIKE '[A-Z][0-9][A-Z][0-9][A-Z][0-9]')
);
GO

DROP TABLE IF EXISTS Customers.tblHousehold;
GO

CREATE TABLE Customers.tblHousehold
(
	HouseID INT IDENTITY(1,1) NOT NULL,
	Address NVARCHAR(30) NOT NULL,
	City NVARCHAR(30) NOT NULL,
	Province NCHAR(2) NOT NULL, -- UPPER(Province) AS Province
	PostCode NCHAR(6) NOT NULL,
	CONSTRAINT PK_HOUSE PRIMARY KEY (HouseID),
	CONSTRAINT CK_HOUSE_PROV CHECK 
		(Province IN ('QC', 'ON', 'BC', 'NL', 'PE', 'NS', 'NB', 'MB', 'SK', 'AB', 'YT', 'NT', 'NU')),
	CONSTRAINT CK_HOUSE_POST CHECK (PostCode LIKE '[A-Z][0-9][A-Z][0-9][A-Z][0-9]')
);
GO

DROP TABLE IF EXISTS Customers.tblCustomer;
GO

CREATE TABLE Customers.tblCustomer
(
	CustID INT IDENTITY(1,1) NOT NULL,
	CustFirst NVARCHAR(30) NOT NULL,
	CustMid NVARCHAR(30) NULL,
	CustLast NVARCHAR(30) NOT NULL,
	Phone NCHAR(10) NULL,
	BirthDate DATE NOT NULL,
	Gender NCHAR(1)	NOT NULL,
	Balance MONEY NOT NULL DEFAULT 0,
	ChildProofCap BIT NOT NULL DEFAULT 1,
	PlanID NVARCHAR(16) NULL,
	HouseID INT NOT NULL,
	Allergies NVARCHAR(50) NOT NULL DEFAULT 'N/A',
	-- RAMQ NCHAR(12) NULL,
	-- CommercialInsurance NVARCHAR(20) NULL,
	CONSTRAINT PK_CUST PRIMARY KEY (CustID),
	CONSTRAINT CK_CUST_PHONE CHECK (Phone LIKE REPLICATE('[0-9]', 10))
);
GO

CREATE NONCLUSTERED INDEX INDEX_CUST_LN ON Customers.tblCustomer(CustLast);
GO

DROP TABLE IF EXISTS Pharmacy.tblClinic;
GO

CREATE TABLE Pharmacy.tblClinic
(
	ClinicID INT IDENTITY(1,1) NOT NULL,
	ClinicName NVARCHAR(50) NOT NULL,
	Address1 NVARCHAR(40) NOT NULL,
	Address2 NVARCHAR(40) NOT NULL,
	City NVARCHAR(40) NOT NULL,
	Province NCHAR(2) NOT NULL DEFAULT 'QC', -- UPPER(Province) AS Province
	PostCode NCHAR(6) NOT NULL,
	Phone NCHAR(10) NOT NULL,
	CONSTRAINT PK_CLINIC PRIMARY KEY (ClinicID),
	CONSTRAINT CK_CLINIC_PROV CHECK 
		(Province IN ('QC', 'ON', 'BC', 'NL', 'PE', 'NS', 'NB', 'MB', 'SK', 'AB', 'YT', 'NT', 'NU')),
	CONSTRAINT CK_CLINIC_PHONE CHECK (Phone LIKE REPLICATE('[0-9]', 10)),
	CONSTRAINT CK_CLINIC_POST CHECK (PostCode LIKE '[A-Z][0-9][A-Z][0-9][A-Z][0-9]')
);
GO

DROP TABLE IF EXISTS Pharmacy.tblDoctor;
GO

CREATE TABLE Pharmacy.tblDoctor
(
	DoctorID INT IDENTITY(1,1) NOT NULL,
	ClinicID INT NOT NULL,
	MINC NCHAR(12) NOT NULL, -- MEDICAL IDENTIFICATION NUMBER FOR CANADA 
	DocFirst NVARCHAR(30) NOT NULL,
	DocMid NVARCHAR(30) NULL,
	DocLast NVARCHAR(30) NOT NULL,
	Phone NCHAR(10) NULL, -- STUFF(STUFF(STUFF(Phone, 7, 0, '-'), 4, 0, ') '), 1, 0, '(') AS Phone
	Cell NCHAR(10) NOT NULL,
	CONSTRAINT PK_DOC PRIMARY KEY (DoctorID),
	CONSTRAINT UQ_DOC UNIQUE (MINC),
	CONSTRAINT CK_DOC_PHONE CHECK (Phone LIKE REPLICATE('[0-9]', 10))
);
GO

DROP TABLE IF EXISTS Pharmacy.tblRx;
GO

CREATE TABLE Pharmacy.tblRx
(
	PrescriptionID INT IDENTITY(1,1) NOT NULL,
	CustID INT NOT NULL,
	DoctorID INT NOT NULL,
	IssueDate DATE NOT NULL, --  FORMAT(IssueDate, 'd', 'en-US') AS 'Issue Date' 
	ExpireDate DATE NOT NULL,
	Refills TINYINT NOT NULL DEFAULT 0,
	AutoRefill BIT NOT NULL DEFAULT 0,
	RefillsUsed TINYINT NOT NULL DEFAULT 0,
	CONSTRAINT PK_RX PRIMARY KEY (PrescriptionID)
)
ON Aragon_FG;
GO

/* THERE MIGHT BE MORE THAN ONE DRUG ON ONE Rx */

DROP TABLE IF EXISTS Pharmacy.tblRxItem;
GO

CREATE TABLE Pharmacy.tblRxItem
(
	PrescriptionID INT NOT NULL,
	DIN NCHAR(8) NOT NULL,
	Quantity DECIMAL(5,2) NOT NULL,
	UnitID INT NOT NULL,
	Instructions NVARCHAR(50) NULL,
	CONSTRAINT PK_RXI PRIMARY KEY (PrescriptionID, DIN)
)
ON Aragon_FG;
GO

DROP TABLE IF EXISTS Pharmacy.tblRefill;
GO

CREATE TABLE Pharmacy.tblRefill
(
	EmpID INT NOT NULL,
	PrescriptionID INT NOT NULL,
	RefillDate DATE NOT NULL, --  FORMAT(RefillDate, 'd', 'en-US') AS 'Refill Date' 
	CONSTRAINT PK_REF PRIMARY KEY (RefillDate, PrescriptionID)
)
ON Aragon_FG;
GO