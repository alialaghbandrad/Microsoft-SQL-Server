/*
 * Purpose: create database for Aragon Pharmacy
 * Script Date: FEB 12, 2021
 * Developed by: Team ZAYC (Zhiwei Li, Ali Alaghbandrad, Yaowu Huang, Carlo Nosliw Naude)
 */

 USE master;
 GO

 DROP DATABASE IF EXISTS AragonPharmacy_ZAYC;
 GO

 CREATE DATABASE AragonPharmacy_ZAYC
 ON PRIMARY
 (
	NAME = 'Aragon_PRM',
	FILENAME = 'F:\12.PROJECTS\DATABASE\SQLSERVER\Aragon_ZAYC_PRM.MDF',
	SIZE = 1MB,
	MAXSIZE = 64MB,
	FILEGROWTH = 1MB
 ),
FILEGROUP Aragon_FG
  ( NAME = 'Aragon_FG_DAT1',
    FILENAME =
       'F:\12.PROJECTS\DATABASE\SQLSERVER\Aragon_ZAYC_FG_1.NDF',
    SIZE = 1MB,
    MAXSIZE=64MB,
    FILEGROWTH=1MB
	),
  ( NAME = 'Aragon_FG_DAT2',
    FILENAME =
       'F:\12.PROJECTS\DATABASE\SQLSERVER\Aragon_ZAYC_FG_2.NDF',
    SIZE = 1MB,
    MAXSIZE=64MB,
    FILEGROWTH=1MB
	)
 LOG ON
 (
	NAME = 'Aragon_LOG',
	FILENAME = 'F:\12.PROJECTS\DATABASE\SQLSERVER\Aragon_ZAYC_LOG.LDF',
	SIZE = 1MB,
	MAXSIZE = 16MB,
	FILEGROWTH = 1MB
 )
 COLLATE SQL_Latin1_General_CP1_CI_AS; -- latin, case insensitive, accent sensitive
 GO