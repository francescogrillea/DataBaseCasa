CREATE DATABASE Rebibbia2; 
USE Rebibbia2;

SET NAMES utf8 ;
SET character_set_client = utf8mb4 ;

CREATE TABLE IF NOT EXISTS Bollette (
  BollettaID tinyint(4) NOT NULL AUTO_INCREMENT,
  Utenza varchar(50) NOT NULL,
  ImportoTotale decimal(6,2) NOT NULL,
  QuotaFissa decimal(6,2),
  Mora decimal(6,2) NOT NULL DEFAULT 0.00,
  Scadenza date NOT NULL, 
  DataPagamento date,
  InizioPeriodoRiferimento date NOT NULL,
  FinePeriodoRiferimento date NOT NULL,
  PRIMARY KEY (BollettaID)
);


CREATE TABLE IF NOT EXISTS Coinquilini (
  Nome varchar(32) NOT NULL,
  Email varchar(32),
  DataIngresso date NOT NULL,
  DataUscita date,
  PRIMARY KEY (Nome)
); 

CREATE TABLE IF NOT EXISTS Pagamenti (
  BollettaID tinyint(4) NOT NULL,
  NomeCoinquilino varchar(32) NOT NULL,
  Importo decimal(6,2) NOT NULL DEFAULT 0.00,
  DataPagamento date,
  FOREIGN KEY (BollettaID) REFERENCES Bollette (BollettaID) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (NomeCoinquilino) REFERENCES Coinquilini (Nome) ON DELETE RESTRICT ON UPDATE CASCADE
);