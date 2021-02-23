/*
 * Purpose: views on Sales and Marketing of Aragon Pharmacy Database
 * Script Date: FEB 15, 2021
 * Developed by: Team ZAYC (Zhiwei Li, Ali Alaghbandrad, Yaowu Huang, Carlo Nosliw Naude)
 */

USE AragonPharmacy_ZAYC;
GO

/* SORT TOP 5 ITEMS FROM RECENT 30 DAYS' SELLING QUANTITY */
DROP VIEW IF EXISTS Marketing.vwInventorySellingTrends;
GO

CREATE VIEW Marketing.vwInventorySellingTrends AS
	SELECT TOP(5) S.DIN, sum(S.Quantity) AS [Selling Quantity]
		FROM (SELECT RI.DIN, RI.Quantity, RF.RefillDate
					FROM Pharmacy.tblRxItem AS RI				
					INNER JOIN Pharmacy.tblRefill AS RF ON RI.PrescriptionID = RF.PrescriptionID
					WHERE RF.RefillDate BETWEEN DATEADD(day, -30, GETDATE()) AND GETDATE()
				) S
		GROUP BY S.DIN
		ORDER BY [Selling Quantity] DESC
;
GO

SELECT * FROM Marketing.vwInventorySellingTrends;
GO

/* THIS YEAR'S REPORT OF PRESCRIPTION 'SPENDS' PER HOUSEHOLD */
DROP VIEW IF EXISTS Marketing.vwAnnualSpends;
GO

CREATE VIEW Marketing.vwAnnualSpends AS
	SELECT FSA.HouseID, cast(sum(FSA.Cost) AS DECIMAL(7,2)) AS [Annual Cost]
		FROM (SELECT H.HouseID, C.CustID, R.PrescriptionID, RI.DIN, round((RI.Quantity * D.Price + D.DispensingFee), 2) AS Cost
				FROM Customers.tblHousehold AS H
				INNER JOIN Customers.tblCustomer AS C ON H.HouseID = C.HouseID
				INNER JOIN Pharmacy.tblRx AS R ON C.CustID = R.CustID
				INNER JOIN Pharmacy.tblRxItem AS RI ON R.PrescriptionID = RI.PrescriptionID
				INNER JOIN Pharmacy.tblRefill AS RF ON RI.PrescriptionID = RF.PrescriptionID
				INNER JOIN Operations.tblDrug AS D ON D.DIN = RI.DIN
				WHERE RF.RefillDate BETWEEN CONVERT(date, '01/01/'+CONVERT(NVARCHAR,YEAR(GETDATE()))) AND GETDATE()
				) FSA
		GROUP BY FSA.HouseID
;
GO

SELECT * FROM Marketing.vwAnnualSpends;
GO

/* Bi-Month Profit Report on sales volume */
DROP VIEW IF EXISTS Marketing.vwBimonthlyProfit;
GO

CREATE VIEW Marketing.vwBimonthlyProfit AS
	SELECT FSA.DIN, cast(sum(FSA.Profit) AS DECIMAL(7,2)) AS [Bimonthly Profit]
		FROM (SELECT H.HouseID, C.CustID, R.PrescriptionID, RI.DIN, round((RI.Quantity * (D.Price-D.Cost)), 2) AS Profit
				FROM Customers.tblHousehold AS H
				INNER JOIN Customers.tblCustomer AS C ON H.HouseID = C.HouseID
				INNER JOIN Pharmacy.tblRx AS R ON C.CustID = R.CustID
				INNER JOIN Pharmacy.tblRxItem AS RI ON R.PrescriptionID = RI.PrescriptionID
				INNER JOIN Pharmacy.tblRefill AS RF ON RI.PrescriptionID = RF.PrescriptionID
				INNER JOIN Operations.tblDrug AS D ON D.DIN = RI.DIN
				WHERE RF.RefillDate BETWEEN DATEADD(day,-60, GETDATE()) AND GETDATE()
				) FSA
		GROUP BY ROLLUP(FSA.DIN)
;
GO

SELECT * FROM Marketing.vwBimonthlyProfit;
GO