/*
 * Purpose: create the SpeakSpanishView as task#2 in page 28  for Aragon Pharmacy
 * Script Date: FEB 15, 2021abase II\Team_Project_Aragon_Pharmacy
 * Developed by: Team ZAYC (Zhiwei Li, Ali Alaghbandrad, Yaowu Huang, Carlo Nosliw Naude)
 */

USE AragonPharmacy_ZAYC;
GO

CREATE VIEW HumanResource.SpeakSpanishView
AS
SELECT E.EmpID, CONCAT_WS(' ',E.EmpFirst,ISNULL(EmpMid,''),EmpLast) AS 'Employee Name',e.LanguageProficiency as 'Fluence in Spanish'
FROM HumanResource.tblEmployee AS E
WHERE E.LanguageSecond LIKE '%Spanish%'
;
GO

SELECT *
FROM HumanResource.SpeakSpanishView AS SSV
ORDER BY SSV.[Fluence in Spanish] DESC
;
GO