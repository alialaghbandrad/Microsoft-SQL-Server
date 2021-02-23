/*
 * Purpose: create database for Aragon Pharmacy
 * Script Date: FEB 12, 2021
 * Developed by: Team ZAYC (Zhiwei Li, Ali Alaghbandrad, Yaowu Huang, Carlo Nosliw Naude)
 */

USE AragonPharmacy_ZAYC;
GO

ALTER TABLE HumanResource.tblEmployee
	ADD CONSTRAINT FK_EMP_JOB FOREIGN KEY (JobID) 
			REFERENCES HumanResource.tblJobTitle(JobID);
GO

ALTER TABLE HumanResource.tblAbsent
	ADD CONSTRAINT FK_ABS_EMP FOREIGN KEY (EmpID) 
			REFERENCES HumanResource.tblEmployee (EmpID);
GO

ALTER TABLE HumanResource.tblAbsent
	ADD CONSTRAINT FK_ABS_CAT FOREIGN KEY (AbsCategory) 
			REFERENCES HumanResource.tblAbsentCategory (AbsCategory);
GO

ALTER TABLE HumanResource.tblEmployeeTraining
	ADD CONSTRAINT FK_EMPTRN_EMP FOREIGN KEY (EmpID) 
			REFERENCES HumanResource.tblEmployee (EmpID) ;
GO

ALTER TABLE HumanResource.tblEmployeeTraining
	ADD CONSTRAINT FK_EMPTRN_CLS FOREIGN KEY (ClassID) 
			REFERENCES HumanResource.tblClass (ClassID);
GO

ALTER TABLE Operations.tblDrug
	ADD CONSTRAINT FK_DRUG_UNIT FOREIGN KEY (UnitID)
			REFERENCES Operations.tblUnit(UnitID);
GO

ALTER TABLE Operations.tblDrug
	ADD CONSTRAINT FK_DRUG_FORM FOREIGN KEY (DosageFormID)
			REFERENCES Operations.tblDosageForm (DosageFormID);
GO

ALTER TABLE Operations.tblDrug
	ADD CONSTRAINT FK_DRUG_SUP FOREIGN KEY (SupplierID)
			REFERENCES Operations.tblSupplier (SupplierID);
GO

ALTER TABLE Customers.tblCustomer
	ADD CONSTRAINT FK_CUST_PLAN FOREIGN KEY (PlanID) 
			REFERENCES Customers.tblHealthPlan (PlanID);
GO

ALTER TABLE Customers.tblCustomer
	ADD CONSTRAINT FK_CUST_HOUSE FOREIGN KEY (HouseID) 
			REFERENCES Customers.tblHousehold (HouseID);
GO

ALTER TABLE Pharmacy.tblDoctor
	ADD CONSTRAINT FK_DOC_CLINIC FOREIGN KEY (ClinicID) 
			REFERENCES Pharmacy.tblClinic (ClinicID);
GO

ALTER TABLE Pharmacy.tblRx
	ADD CONSTRAINT FK_RX_CUST FOREIGN KEY (CustID) 
			REFERENCES Customers.tblCustomer (CustID);
GO

ALTER TABLE Pharmacy.tblRx
	ADD CONSTRAINT FK_RX_DOC FOREIGN KEY (DoctorID) 
			REFERENCES Pharmacy.tblDoctor (DoctorID);
GO

ALTER TABLE Pharmacy.tblRxItem
	ADD CONSTRAINT FK_RXI_RX FOREIGN KEY (PrescriptionID) 
			REFERENCES Pharmacy.tblRx (PrescriptionID);
GO

ALTER TABLE Pharmacy.tblRxItem
	ADD CONSTRAINT FK_RXI_UNIT FOREIGN KEY (UnitID)
			REFERENCES Operations.tblUnit(UnitID);
GO

ALTER TABLE Pharmacy.tblRxItem
	ADD CONSTRAINT FK_RXI_DRUG FOREIGN KEY (DIN)
		REFERENCES Operations.tblDrug (DIN);
GO

ALTER TABLE Pharmacy.tblRefill
	ADD CONSTRAINT FK_REF_EMP FOREIGN KEY (EmpID)
			REFERENCES HumanResource.tblEmployee (EmpID);
GO

ALTER TABLE Pharmacy.tblRefill
	ADD CONSTRAINT FK_REF_RX FOREIGN KEY (PrescriptionID) 
			REFERENCES Pharmacy.tblRx (PrescriptionID);
GO

