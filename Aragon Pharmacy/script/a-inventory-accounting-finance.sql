/*
 * Purpose: views on Inventory, Accounting and Finance of Aragon Pharmacy Database
 * Script Date: FEB 15, 2021
 * Developed by: Team ZAYC (Zhiwei Li, Ali Alaghbandrad, Yaowu Huang, Carlo Nosliw Naude)
 */

USE AragonPharmacy_ZAYC;
GO

/* Reporting the details about how much inventory remains for each prescription and nonprescription item in the store. The value of the existing inventory */
DROP VIEW IF EXISTS AccountingFinance.vwInventoryItemsValue;
GO

CREATE VIEW AccountingFinance.vwInventoryItemsValue AS
select D.DIN, sum(D.Price*D.StockQuantity) as 'Value of Existing Drug'
from Operations.tblDrug AS D
group by D.DIN
with rollup
;
go

select * from AccountingFinance.vwInventoryItemsValue
order by 'Value of Existing Drug'
;
go



/* Reporting the details about the pharmacy’s sales figures */
DROP VIEW IF EXISTS AccountingFinance.vwSales;
GO
create view AccountingFinance.vwSales as
	SELECT S.DIN, sum(S.Quantity) AS [Selling Quantity], cast(sum(S.Price*S.Quantity) as decimal(6,2)) AS [Selling Value]
		FROM (SELECT RI.DIN, RI.Quantity, RF.RefillDate, D.Price
					FROM Pharmacy.tblRxItem AS RI				
					INNER JOIN Pharmacy.tblRefill AS RF ON RI.PrescriptionID = RF.PrescriptionID
					INNER JOIN Operations.tblDrug AS D ON RI.DIN = D.DIN
				) S
		GROUP BY ROLLUP(S.DIN)
;
go

select * from AccountingFinance.vwSales
ORDER BY [Selling Quantity] DESC, [Selling Value] DESC
;
go

/* Reporting the details about the pharmacy’s salary commitments */
drop view if exists AccountingFinance.vwSalary;
go

create view AccountingFinance.vwSalary as
SELECT S.EmpID, SUM(S.[Monthly Salary]) AS [Monthly Salary]
	FROM (select E.EmpID, cast(iif(E.Salary is not null, round(E.Salary/12, 2), 22*8*E.HourlyRate) as decimal(6,2))  as [Monthly Salary]
		from HumanResource.tblEmployee AS E
	) S
GROUP BY ROLLUP(S.EmpID)
;
go

SELECT * FROM AccountingFinance.vwSalary;
GO