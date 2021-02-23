/*
 * Purpose: Security of Aragon Pharmacy Database
 * Script Date: FEB 15, 2021
 * Developed by: Team ZAYC (Zhiwei Li, Ali Alaghbandrad, Yaowu Huang, Carlo Nosliw Naude)
 */

USE AragonPharmacy_ZAYC;
GO

-- page 27 maintaining and securing




-- p4 settting role/user for field protection of human resource
/*Business Requirement
 manage all of the data about employees. Some of this data is descriptive, such as the employee¡¯s name and address. 
 Other data is sensitive, such as the employee¡¯s Social Security number, salary, and information about job performance, and needs to be protected from unauthorized access. 
*/

-- Create users

CREATE USER Maria without login;
CREATE USER John without login;
GO  



-- Set Access Permission , only HumanResource Manager --Maria can view the data with dynamic input mask in the HumanResource.tblEmployee

GRANT UNMASK TO Maria;  
GRANT SELECT ON OBJECT:: HumanResource.tblEmployee TO Maria
;
GRANT SELECT ON OBJECT:: HumanResource.tblEmployee TO John
;
GO



-- View data as HR manager, sensitive data will display as normal
EXECUTE AS USER = 'Maria';
SELECT *
FROM HumanResource.tblEmployee
;
GO

REVERT

-- View data as other users, sensitive data will be hidden
EXECUTE AS USER = 'John';
SELECT *
FROM HumanResource.tblEmployee
;
GO

REVERT

DROP USER Maria;
DROP USER John;
GO