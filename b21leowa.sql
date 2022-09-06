drop database B21leowa;
create database b21leowa;

use b21leowa;

CREATE TABLE snälltBarn(
	PNR CHAR(14) NOT NULL,
    förnamn VARCHAR(10) NOT NULL,
	efternamn VARCHAR(10) NOT NULL,
    födelseår CHAR(4) NOT NULL,
    summa INTEGER, 
	hjälpsamhet INTEGER,
    PRIMARY KEY (PNR, Förnamn)
)ENGINE=INNODB;

CREATE TABLE mindreSnälltBarn(
	PNR CHAR(14) NOT NULL,
    förnamn VARCHAR(10) NOT NULL,
	efternamn VARCHAR(10) NOT NULL,
    födelseår CHAR(4) NOT NULL,
    summa INTEGER,
    nivå CHAR(3),
    leveransNummer CHAR(10),
    PRIMARY KEY (PNR, Förnamn)
)ENGINE=INNODB;

CREATE TABLE inspelning(
	tid DATETIME NOT NULL,
    beksrivning VARCHAR(11),
    kvalitet CHAR(3),
    filnamn VARCHAR(10),
    text TEXT,
    PNR CHAR(14) NOT NULL,
    förnamn VARCHAR(10) NOT NULL,
    efternamn VARCHAR(10) NOT NULL,
    FOREIGN KEY(PNR, förnamn, efternamn) REFERENCES snälltBarn(PNR, förnamn, efternamn),
    PRIMARY KEY (tid, PNR, förnamn, efternamn)
    
)ENGINE=INNODB;