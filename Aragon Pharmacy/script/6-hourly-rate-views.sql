/*
 * Purpose: create the HourlyRateAnalysisView as task#1 in page 28  for Aragon Pharmacy
 * Script Date: FEB 15, 2021abase II\Team_Project_Aragon_Pharmacy
 * Developed by: Team ZAYC (Zhiwei Li, Ali Alaghbandrad, Yaowu Huang, Carlo Nosliw Naude)
 */

USE AragonPharmacy_ZAYC;
GO

-- View HourlyRateAnalysisView

create view HumanResource.HourlyRateAnalysisView as
select E.EmpID, CONCAT_WS(' ', E.EmpFirst, E.EmpMid, E.EmpLast) AS 'Employee Full Name',
JT.Title, E.Salary, E.HourlyRate
from HumanResource.tblEmployee as E
INNER JOIN HumanResource.tblJobTitle as JT on E.JobID = JT.JobID
where Title in ('Technician', 'Cashier')
;
go

select * from HumanResource.HourlyRateAnalysisView
order by EmpID
;
go

-- View HourlyRateSummaryView

create view HumanResource.HourlyRateSummaryView as
select 
JT.Title, max(E.HourlyRate) as 'Maximum hourly rate', min(E.HourlyRate) as 'Minimum hourly rate'
from HumanResource.tblEmployee as E
INNER JOIN HumanResource.tblJobTitle as JT on E.JobID = JT.JobID
group by JT.Title
;
go

select * from HumanResource.HourlyRateSummaryView
;
go