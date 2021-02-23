/*
 * Purpose: Evaluatinng Data for Aragon Pharmacy
 * Script Date: FEB 12, 2021
 * Developed by: Team ZAYC (Zhiwei Li, Ali Alaghbandrad, Yaowu Huang, Carlo Nosliw Naude)
 */

USE AragonPharmacy_ZAYC;
GO

/* Find Duplicates values in the fields you select */

-- VIEW OF EMPLOYEES IN THE SAME CITY
DROP VIEW IF EXISTS HumanResource.vwEmployeesInSameCity;
GO

CREATE VIEW HumanResource.vwEmployeesInSameCity AS
	SELECT City, STRING_AGG(CONCAT_WS(' ', EmpFirst, EmpMid, EmpLast), ', ') AS Employees
		FROM HumanResource.tblEmployee
		GROUP BY CITY;
GO

SELECT * FROM HumanResource.vwEmployeesInSameCity;
GO

-- COMPARE COST OF SAME CLASS WITH DIFFERENT VENDORS
DROP PROCEDURE IF EXISTS HumanResource.spFindClassCost;
GO

CREATE PROCEDURE HumanResource.spFindClassCost
	@ClassNameFilter NVARCHAR(30)
AS
	DECLARE @LikeString NVARCHAR(32);
	SET @LikeString = '%'+@ClassNameFilter+'%';
	SELECT ClassDesc AS [Class Description], Cost AS [Cost], ProviderName AS [Provider]
		FROM HumanResource.tblClass
		WHERE ClassDesc LIKE @LikeString;
GO

EXEC HumanResource.spFindClassCost 'CPR'; -- usage example
GO

-- VIEW OF TRAININGS TAKEN FOR EMPLOYEES 
DROP PROCEDURE IF EXISTS HumanResource.spTrainingByEmployeeLastName;
GO

CREATE PROCEDURE HumanResource.spTrainingByEmployeeLastName
	@EmployeeNameFilter NVARCHAR(30)
AS
	DECLARE @LikeString NVARCHAR(32);
	SET @LikeString = '%'+@EmployeeNameFilter+'%';
	SELECT CONCAT_WS(' ', E.EmpFirst, E.EmpMid, E.EmpLast) AS Employee, JT.Title AS Title, 
			FORMAT(ET.ClassDate, 'd', 'en-US') AS [Class Date], C.ClassDesc AS [Class Description], C.Cost AS [Cost]
		FROM HumanResource.tblEmployeeTraining AS ET
		INNER JOIN HumanResource.tblClass AS C ON ET.ClassID = C.ClassID
		INNER JOIN HumanResource.tblEmployee AS E ON ET.EmpID = E.EmpID AND E.EmpLast LIKE @LikeString
		INNER JOIN HumanResource.tblJobTitle AS JT ON E.JobID = JT.JobID
		WHERE E.EndDate IS NULL;
GO

EXEC HumanResource.spTrainingByEmployeeLastName 'Campbell'; -- usage example
GO

/* Using Queries to Find Unmatched Records */
DROP FUNCTION IF EXISTS dbo.funcNAPhoneFormat;
GO

CREATE FUNCTION funcNAPhoneFormat (@phone NCHAR(10))
RETURNS NCHAR(14)
AS 
BEGIN
	RETURN '('+LEFT(@phone, 3)+')' + '-' + SUBSTRING(@phone, 4, 3) + '-' + SUBSTRING(@phone, 7, 4);
END
;
GO

-- SELECT dbo.funcNAPhoneFormat('1234567890');

-- CUSTOMERS WHO HAVE NOT ORDERED ANY PRODUCTS
DROP VIEW IF EXISTS Customers.vwCustomersWithoutProducts;
GO

CREATE VIEW Customers.vwCustomersWithoutProducts AS
	SELECT CONCAT_WS(' ', CustFirst, IIF(CustMid IS NULL,'',CustMid), CustLast) AS Customer, 
			dbo.funcNAPhoneFormat(Phone) AS Phone
		FROM Customers.tblCustomer AS C
		LEFT JOIN Pharmacy.tblRx AS R ON R.CustID = C.CustID
		WHERE R.CustID IS NULL;
GO

SELECT * FROM Customers.vwCustomersWithoutProducts;
GO

-- VENDORS NO LONGER USED
DROP VIEW IF EXISTS Operations.vwVendorsNotUsed;
GO

CREATE VIEW Operations.vwVendorsNotUsed AS
	SELECT SupplierName 
		FROM Operations.tblSupplier AS S
		LEFT JOIN Operations.tblDrug AS D ON D.SupplierID = S.SupplierID
		WHERE D.SupplierID IS NULL;
GO

SELECT * FROM Operations.vwVendorsNotUsed;
GO

/* Using Parameter Values */

-- SUBSTITUTE LIST ORDERED BY LAST NAME - getSubstituteListFn
DROP FUNCTION IF EXISTS HumanResource.getSubstituteListFn;
GO

CREATE FUNCTION HumanResource.getSubstituteListFn (@JobID INT)
RETURNS TABLE
AS 
RETURN
(
	SELECT TOP(SELECT COUNT(*) FROM HumanResource.tblEmployee WHERE JobID = @JobID  AND EndDate IS NULL) 
		EmpLast, EmpFirst,dbo.funcNAPhoneFormat(Phone) AS Phone, dbo.funcNAPhoneFormat(Cell) AS Cell, JobID, FORMAT(EndDate, 'd', 'en-US') AS EndDate
		FROM HumanResource.tblEmployee
		WHERE JobID = @JobID AND EndDate IS NULL
		ORDER BY EmpLast ASC
);
GO

SELECT * FROM HumanResource.getSubstituteListFn(2);
GO

/* Analyzing Data from More Than One Table */

-- LIST EMPLOYEES TAKING CERTIFICATION CLASSES
DROP VIEW IF EXISTS HumanResource.vwEmployeeClasses;
GO

CREATE VIEW HumanResource.vwEmployeeClasses AS
	SELECT E.EmpFirst AS [FIRST NAME], E.EmpMid AS [MID NAME], E.EmpLast AS [LAST NAME],  
			FORMAT(ET.ClassDate, 'd', 'en-US') AS [Class Date], C.ClassDesc AS [Class Description]
		FROM HumanResource.tblEmployeeTraining AS ET
		INNER JOIN HumanResource.tblClass AS C ON ET.ClassID = C.ClassID AND C.IsRequired = 1
		INNER JOIN HumanResource.tblEmployee AS E ON ET.EmpID = E.EmpID
		WHERE E.EndDate IS NULL;
GO

SELECT * FROM HumanResource.vwEmployeeClasses;
GO

--  LIST EMPLOYEES TAKING CERTIFICATION CLASSES SORTED BY EmpLast
DROP VIEW IF EXISTS HumanResource.vwEmployeeClassesDescription;
GO

CREATE VIEW HumanResource.vwEmployeeClassesDescription AS
	SELECT TOP(SELECT COUNT(*) FROM HumanResource.vwEmployeeClasses) * 
		FROM HumanResource.vwEmployeeClasses 
		ORDER BY [LAST NAME];
GO

SELECT * FROM HumanResource.vwEmployeeClassesDescription;
GO

-- LIST EMPLOYESS WHO ATTENDED TRAINING AND WHO NOT
DROP VIEW IF EXISTS HumanResource.vwEmployeeTraining;
GO

CREATE VIEW HumanResource.vwEmployeeTraining AS
	SELECT CONCAT_WS(' ', E.EmpFirst, E.EmpMid, E.EmpLast) AS Employee, FORMAT(ET.ClassDate, 'd', 'en-US') AS [Class Date], 
			ET.ClassID AS [Class ID], C.ClassDesc AS [Class Description]
		FROM HumanResource.tblEmployee AS E 
		FULL OUTER JOIN HumanResource.tblEmployeeTraining AS ET ON ET.EmpID = E.EmpID
		FULL OUTER JOIN HumanResource.tblClass AS C ON ET.ClassID = C.ClassID
		WHERE E.EndDate IS NULL;
GO

SELECT * FROM HumanResource.vwEmployeeTraining;
GO

-- LIST EMPLOYESS CERTIFICATION DATE
DROP VIEW IF EXISTS HumanResource.vwEmployeeCertificationUptoDate;
GO

CREATE VIEW HumanResource.vwEmployeeCertificationUptoDate AS
	SELECT TOP(SELECT COUNT(*) FROM HumanResource.vwEmployeeTraining WHERE [Class ID] IS NOT NULL) * 
		FROM HumanResource.vwEmployeeTraining 
		WHERE [Class ID] IS NOT NULL		
		ORDER BY [Employee], [Class ID]
	UNION ALL
	SELECT TOP(SELECT COUNT(*) FROM HumanResource.vwEmployeeTraining WHERE [Class ID] IS NULL) * 
		FROM HumanResource.vwEmployeeTraining 
		WHERE [Class ID] IS NULL		
		ORDER BY [Employee], [Class ID]
;
GO

SELECT * FROM HumanResource.vwEmployeeCertificationUptoDate;
GO

-- LIST REQUIRED TAININGS
DROP VIEW IF EXISTS HumanResource.vwEmployeeClassesRequired;
GO

CREATE VIEW HumanResource.vwEmployeeClassesRequired AS
	SELECT E.EmpFirst AS [FIRST NAME], E.EmpMid AS [MID NAME], E.EmpLast AS [LAST NAME],  
			FORMAT(ET.ClassDate, 'd', 'en-US') AS [Class Date], IIF(C.IsRequired=1, 'YES', 'NO') AS [Is Required], C.ClassID AS [Class ID]
		FROM HumanResource.tblEmployeeTraining AS ET
		INNER JOIN HumanResource.tblClass AS C ON ET.ClassID = C.ClassID
		INNER JOIN HumanResource.tblEmployee AS E ON ET.EmpID = E.EmpID
		WHERE E.EndDate IS NULL;
GO

SELECT * FROM HumanResource.vwEmployeeClassesRequired;
GO

-- LIST 5 MANDATORY TRAINING FOR PHARMACY EMPLOYEES
DROP VIEW IF EXISTS HumanResource.vwPharmacyEmployeeClassesRequired;
GO

CREATE VIEW HumanResource.vwPharmacyEmployeeClassesRequired AS
	SELECT [FIRST NAME], [MID NAME], [LAST NAME], [Class Date], [Class ID]
		FROM HumanResource.vwEmployeeClassesRequired
		WHERE [Class ID] IN (1, 2, 3, 5, 6);
GO

SELECT * FROM HumanResource.vwPharmacyEmployeeClassesRequired;
GO

-- RENEW CERTIFICATION LIST
DROP PROCEDURE IF EXISTS HumanResource.spCertificationRenewDate;
GO

CREATE PROCEDURE HumanResource.spCertificationRenewDate
AS
BEGIN
	DECLARE @AdultCPR INT, @ChildCPR INT, @RenewAdultCPR INT, @RenewChildCPR INT, @Defibrillator INT;
	DECLARE @Reminder TABLE (RECORDID INT IDENTITY(1,1) NOT NULL, EMPID INT, CLASSID INT, CLASSDATE DATE, RENEWDATE DATE);
	DECLARE @Cursor INT, @ROWAMOUNT INT, @MORELATERCOUNT INT;
	DECLARE @EMPID INT, @CLASSID INT, @CLASSDATE DATE;
	SET @AdultCPR = 1;
	SET @RenewAdultCPR = 3;
	SET @ChildCPR = 2;
	SET @RenewChildCPR = 6;
	SET @Defibrillator = 5;

	INSERT INTO @Reminder(EMPID, CLASSID, CLASSDATE, RENEWDATE) 
		SELECT E.EmpID, C.ClassID, ET.ClassDate, DATEADD(YEAR, 1, ET.ClassDate)
			FROM HumanResource.tblEmployee AS E 
			INNER JOIN HumanResource.tblEmployeeTraining AS ET ON ET.EmpID = E.EmpID
			INNER JOIN HumanResource.tblClass AS C ON ET.ClassID = C.ClassID
			WHERE E.EndDate IS NULL 
				AND C.ClassID IN (@AdultCPR, @ChildCPR, @RenewAdultCPR, @Defibrillator, @RenewChildCPR);
	-- SELECT * FROM @Reminder;

	-- REMOVE HISTORICAL REMINDER ROW FROM TABLE @REMINDER
	SELECT @ROWAMOUNT = COUNT(*) FROM @Reminder;
	SET @Cursor = 1;
	-- SELECT @Cursor, @ROWAMOUNT;
	SELECT @EMPID = EMPID, @CLASSID = CLASSID, @CLASSDATE = CLASSDATE
		FROM @Reminder
		WHERE RECORDID = @Cursor;
	WHILE @Cursor <= @ROWAMOUNT
	BEGIN
		IF (@CLASSID = @AdultCPR)
		BEGIN
			SELECT @MORELATERCOUNT = COUNT(*) FROM @Reminder
				WHERE EMPID = @EMPID AND CLASSID = @RenewAdultCPR AND CLASSDATE > @CLASSDATE;
			IF(@MORELATERCOUNT > 0) UPDATE @Reminder SET CLASSID = -1 WHERE RECORDID = @Cursor;
		END
		ELSE
		BEGIN
			IF (@CLASSID = @RenewAdultCPR)
			BEGIN
				SELECT @MORELATERCOUNT = COUNT(*) FROM @Reminder
					WHERE EMPID = @EMPID AND CLASSID = @RenewAdultCPR AND CLASSDATE > @CLASSDATE;
				IF(@MORELATERCOUNT > 0) UPDATE @Reminder SET CLASSID = -1 WHERE RECORDID = @Cursor;
				SELECT @MORELATERCOUNT = COUNT(*) FROM @Reminder
					WHERE EMPID = @EMPID AND CLASSID = @AdultCPR AND CLASSDATE > @CLASSDATE;
				IF(@MORELATERCOUNT > 0) UPDATE @Reminder SET CLASSID = -1 WHERE RECORDID = @Cursor;
			END
			ELSE
			BEGIN
				IF (@CLASSID = @ChildCPR)
				BEGIN
					SELECT @MORELATERCOUNT = COUNT(*) FROM @Reminder
						WHERE EMPID = @EMPID AND CLASSID = @RenewChildCPR AND CLASSDATE > @CLASSDATE;
					IF(@MORELATERCOUNT > 0) UPDATE @Reminder SET CLASSID = -1 WHERE RECORDID = @Cursor;
				END
				ELSE
				BEGIN
					IF (@CLASSID = @RenewChildCPR)
					BEGIN
						SELECT @MORELATERCOUNT = COUNT(*) FROM @Reminder
							WHERE EMPID = @EMPID AND CLASSID = @RenewChildCPR AND CLASSDATE > @CLASSDATE;
						IF(@MORELATERCOUNT > 0) UPDATE @Reminder SET CLASSID = -1 WHERE RECORDID = @Cursor;
						SELECT @MORELATERCOUNT = COUNT(*) FROM @Reminder
							WHERE EMPID = @EMPID AND CLASSID = @ChildCPR AND CLASSDATE > @CLASSDATE;
						IF(@MORELATERCOUNT > 0) UPDATE @Reminder SET CLASSID = -1 WHERE RECORDID = @Cursor;
					END
					ELSE
					BEGIN
						IF (@CLASSID = @Defibrillator)
						BEGIN
							SELECT @MORELATERCOUNT = COUNT(*) FROM @Reminder
								WHERE EMPID = @EMPID AND CLASSID = @Defibrillator AND CLASSDATE > @CLASSDATE;
							IF(@MORELATERCOUNT > 0) UPDATE @Reminder SET CLASSID = -1 WHERE RECORDID = @Cursor;
						END
					END
				END
			END
		END
		SET @Cursor = @Cursor + 1;
		SELECT @EMPID = EMPID, @CLASSID = CLASSID, @CLASSDATE = CLASSDATE
			FROM @Reminder
			WHERE RECORDID = @Cursor;
	END
	DELETE @Reminder WHERE CLASSID = -1;
	SELECT EMPID AS [Employee ID], CLASSID AS [Class ID], FORMAT(CLASSDATE, 'd', 'en-US') AS [Last Date], FORMAT(RENEWDATE, 'd', 'en-US') AS [Next Date] FROM @Reminder;
END
GO

EXEC HumanResource.spCertificationRenewDate;
GO