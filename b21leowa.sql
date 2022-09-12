DROP DATABASE B21leowa;
CREATE DATABASE b21leowa;
DROP USER 'barn'@'localhost';
DROP USER 'admin'@'localhost';
FLUSH PRIVILEGES;
USE b21leowa;

# DEFAULT TABLE FOR BARN 
CREATE TABLE barn(
	PNR VARCHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    födelseår DATE NOT NULL,
    PRIMARY KEY (PNR, namn)
)ENGINE=INNODB;
CREATE INDEX barnPNR ON barn(PNR);
#TABLE FOR BARN INHERITANCE
CREATE TABLE snälltBarn(
	PNR VARCHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
	hjälpsamhet INTEGER,
    FOREIGN KEY (PNR, namn) REFERENCES barn(PNR, namn),
    PRIMARY KEY(PNR, namn)
)ENGINE=INNODB;

# TABLE FOR BARN INHERITANCE
CREATE TABLE mindreSnälltBarn(
	PNR VARCHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    nivå INTEGER,
    leveransNummer CHAR(10),
    FOREIGN KEY (PNR, namn) REFERENCES barn(PNR, namn),
    PRIMARY KEY(PNR, namn)
)ENGINE=INNODB;

#Horizontell split from child and childText
CREATE TABLE barnBeskrivning (
	PNR VARCHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    beskrivning text,
	FOREIGN KEY (PNR, namn) REFERENCES barn(PNR, namn),
	PRIMARY KEY(PNR, namn)
)ENGINE=INNODB;

CREATE TABLE inspelning(
	tid DATETIME NOT NULL,
    beskrivning VARCHAR(11),
    kvalitet TINYINT,
    filnamn VARCHAR(10),
    inspelningsText TEXT,
    PNR VARCHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    FOREIGN KEY(PNR, namn) REFERENCES barn(PNR, namn),
    PRIMARY KEY (tid, PNR, namn)
)ENGINE=INNODB;

# CREATES A NEW TABLE FOR HORIZONTAL DENORMALIZATION ON COMMENT
CREATE TABLE inspelningsText(
	tid DATETIME NOT NULL,
    inspelningsText TEXT,
    PNR VARCHAR(14) NOT NULL,
	namn VARCHAR(255) NOT NULL,
    FOREIGN KEY(tid, PNR, namn) REFERENCES inspelning(tid, PNR, namn),
	PRIMARY KEY (tid, PNR, namn)
)ENGINE=INNODB;

/*CREATE TABLE OF önskelista
	Barn kan ha flera önskelistor
	
*/
CREATE TABLE önskelista(
	årtal DATE NOT NULL,
    medgiven TINYINT,
    beskrivning VARCHAR(255),
    levererad TINYINT,
    PNR VARCHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    FOREIGN KEY (PNR, namn) REFERENCES barn(PNR, namn),
	PRIMARY KEY(årtal, PNR, namn)
    
)ENGINE=INNODB;

CREATE TABLE önseklistaBeskrivning (
	årtal DATE NOT NULL,
	PNR CHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    beskrivning TEXT,
    FOREIGN KEY (årtal, PNR, namn) REFERENCES önskelista(årtal, PNR, namn),
    PRIMARY KEY(årtal, PNR, namn)
)ENGINE=INNODB;

INSERT INTO barn(PNR, namn, födelseår) VALUES ("20090909-0909", "Anders Andersson", "2009-09-09");
INSERT INTO önskelista(årtal, medgiven, beskrivning, levererad, PNR, namn) VALUES ("2022-09-12", 0, "Vattenpistol", 0, "20090909-0909", "Anders Andersson");
INSERT INTO inspelning(tid, beskrivning, kvalitet, filnamn, PNR, namn) VALUES("2022-09-12 10:25:00", "AndersFilm", 78, "Anders", "20090909-0909","Anders Andersson");

CREATE USER 'barn'@'localhost' IDENTIFIED BY 'barn';

CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';

GRANT DELETE, UPDATE ON önskelista TO 'barn'@'localhost';

SHOW GRANTS FOR 'barn'@'localhost';

SELECT * FROM önskelista, barn WHERE önskelista.PNR = barn.PNR;

#A view where the child for his/hers own wishlist
CREATE VIEW barnetsÖnskelista AS SELECT önskelista.årtal, önskelista.beskrivning, önskelista.levererad, önskelista.PNR, önskelista.namn FROM önskelista LEFT JOIN barn ON önskelista.PNR = barn.PNR;

SELECT * FROM barnetsÖnskelista; 

CREATE VIEW barnetsInspelning AS SELECT inspelning.tid, inspelning.beskrivning, inspelning.PNR, inspelning.namn FROM inspelning LEFT JOIN barn ON inspelning.PNR = barn.PNR;

SELECT * FROM barnetsInspelning;