/*
 * Purpose: Calculating Statistical Information for Aragon Pharmacy
 * Script Date: FEB 16, 2021
 * Developed by: Team ZAYC (Zhiwei Li, Ali Alaghbandrad, Yaowu Huang, Carlo Nosliw Naude)
 */

USE AragonPharmacy_ZAYC;
GO


/*Business requirement
needs to calculate the minimum, maximum, and average hourly rates for each job ID. setting criteria to display only records for technicians and cashiers, so she adds the criteria 3 or 4 in the JobID field
*/

-- max, min, average of hourly rate of technician (3) and cashier (4)
-- CREATE VIEW HumanResource.vwMaxMinAvgHourlyRate
CREATE VIEW HumanResource.vwMaxMinAvgHourlyRate
AS
select JT.JobID, JT.Title, MAX(E.HourlyRate) AS 'Maximal Hourly Rate', MIN(E.HourlyRate) AS 'Minimal Hourly Rate', CAST(AVG(E.HourlyRate) AS decimal(7,2)) AS 'Average Hourly Rate'
FROM HumanResource.tblEmployee AS E INNER JOIN HumanResource.tblJobTitle AS JT
ON E.JobID = JT.JobID
WHERE E.JobID IN (3,4)
GROUP BY JT.JobID , JT.Title
;
GO


SELECT *
FROM HumanResource.vwMaxMinAvgHourlyRate AS MMA
ORDER BY MMA.JobID
;
GO



/*Business requirement
needs to calculate the years of service each employee has provided 4Corners and decides to create a function with parameter. 
*/
-- CREATE FUNCTION HumanResource.funcYearsOfService

CREATE FUNCTION HumanResource.funcYearsOfService(@EmployeeID int)
RETURNS INT
AS 

	BEGIN
		DECLARE @yos INT;
		SELECT @yos = YEAR(ISNULL(E.EndDate,GETDATE())) - YEAR(E.StartDate)
		FROM HumanResource.tblEmployee AS E
		WHERE E.EmpID = @EmployeeID
		IF(@yos IS NULL)
			SET @yos = 0
		RETURN @yos

	END
;
GO

SELECT E.EmpID, CONCAT_WS(' ',E.EmpFirst, ISNULL(E.EmpMid,''),E.EmpLast) AS 'Employee Name', HumanResource.funcYearsOfService(E.EmpID) AS 'Year of Service', E.StartDate, E.EndDate
FROM HumanResource.tblEmployee AS E
