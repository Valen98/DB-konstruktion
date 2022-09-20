DROP DATABASE b21leowa;
CREATE DATABASE b21leowa;
FLUSH PRIVILEGES;
USE b21leowa;

-- Tables

-- DEFAULT TABLE FOR BARN 
CREATE TABLE barn(
	PNR CHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    födelseår DATE NOT NULL,
    snällhetsSkala SMALLINT,
    PRIMARY KEY (PNR, namn)
)ENGINE=INNODB;

CREATE INDEX barnFödelseår ON barn(födelseår);

 CREATE TABLE barnRelation(
    PNR1 CHAR(14) NOT NULL,
    namn1 VARCHAR(255) NOT NULL,
    PNR2 CHAR(14) NOT NULL,
    namn2 VARCHAR(255) NOT NULL,
    typAvRelation VARCHAR(255) NOT NULL,
	FOREIGN KEY (PNR1, namn1) REFERENCES barn(PNR, namn),
    FOREIGN KEY (PNR2, namn2) REFERENCES barn(PNR, namn),
    PRIMARY KEY (PNR1, namn1, PNR2, namn2)
)ENGINE=INNODB;

CREATE TABLE barnKod (
	ID INTEGER NOT NULL,
    snällhet VARCHAR(255),
    PRIMARY KEY(ID)
)ENGINE=INNODB;

CREATE TABLE barnLog (
	ID INTEGER NOT NULL AUTO_INCREMENT,
    OPERATION CHAR(3),
	username VARCHAR(32),
    PNR CHAR(14),
    namn VARCHAR(255),
    tid DATETIME,
    tabell VARCHAR(255),
    PRIMARY KEY(ID)
)ENGINE=INNODB;

-- INSERT DEFAULT CHILD FOR TESTING THE DB
INSERT INTO barn(PNR, namn, födelseår) VALUES ("20090909-0909", "Anders Andersson", "2009-09-09");

# Sysslor är antal sysslor som barnet har tilldelats och hur av dom sysslor hen har utfört. Därefter beräknas hjälpsamhet genom sysslor/utfördaSysslor
-- TABLE FOR BARN INHERITANCE
CREATE TABLE snälltBarn(
	PNR CHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    sysslor SMALLINT,
	utfördaSysslor SMALLINT,
    FOREIGN KEY (PNR, namn) REFERENCES barn(PNR, namn),
    PRIMARY KEY(PNR, namn)
)ENGINE=INNODB;

INSERT INTO snälltBarn(PNR, namn, sysslor, utfördaSysslor) VALUES ("20090909-0909", "Anders Andersson", 12, 10);

-- TABLE FOR BARN INHERITANCE
CREATE TABLE mindreSnälltBarn(
	PNR CHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    nivå SMALLINT,
    leveransNummer CHAR(10),
    FOREIGN KEY (PNR, namn) REFERENCES barn(PNR, namn),
    PRIMARY KEY(PNR, namn)
)ENGINE=INNODB;


-- Horizontell split from child and childText
CREATE TABLE barnBeskrivning (
    beskrivning TEXT,
	PNR CHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
	FOREIGN KEY (PNR, namn) REFERENCES barn(PNR, namn),
	PRIMARY KEY(PNR, namn)
)ENGINE=INNODB;

CREATE TABLE barnBeskrivningLOG(
	ID INTEGER NOT NULL AUTO_INCREMENT,
    OPERATION CHAR(3),
    PNR CHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    tid DATETIME,
    PRIMARY KEY(ID)
)ENGINE=INNODB;

CREATE TABLE inspelning(
	tid DATETIME NOT NULL,
    beskrivning VARCHAR(11),
    kvalitet TINYINT,
    filnamn VARCHAR(10),
    PNR CHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    FOREIGN KEY(PNR, namn) REFERENCES barn(PNR, namn),
    PRIMARY KEY (tid, PNR, namn)
)ENGINE=INNODB;

-- CREATES A NEW TABLE FOR HORIZONTAL DENORMALIZATION ON COMMENT
CREATE TABLE inspelningsText(
	tid DATETIME NOT NULL,
    inspelningsText TEXT,
    PNR CHAR(14) NOT NULL,
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
    PNR CHAR(14) NOT NULL,
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

-- Inserts
INSERT INTO önskelista(årtal, medgiven, beskrivning, levererad, PNR, namn) VALUES ("2022-09-12", 0, "Vattenpistol", 0, "20090909-0909", "Anders Andersson");
INSERT INTO inspelning(tid, beskrivning, kvalitet, filnamn, PNR, namn) VALUES("2022-09-12 10:25:00", "AndersFilm", 78, "Anders", "20090909-0909","Anders Andersson");
INSERT INTO barnBeskrivning(PNR, namn, beskrivning) VALUES("20090909-0909", "Anders Andersson" ,"Detta är en beskrivning");

SELECT * FROM barnBeskrivning;

-- Users

CREATE USER IF NOT EXISTS 'barn'@'localhost' IDENTIFIED BY 'barn';

CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY 'admin';
CREATE USER IF NOT EXISTS 'tomten'@'localhost' IDENTIFIED BY 'tomten';

GRANT SELECT, DELETE, UPDATE ON * TO 'tomten'@'localhost';

SHOW GRANTS FOR 'admin'@'localhost';

SELECT * FROM önskelista, barn WHERE önskelista.PNR = barn.PNR;

 -- Views 
#A view where the child for his/hers own wishlist
CREATE VIEW barnetsÖnskelista AS SELECT önskelista.årtal, önskelista.beskrivning, önskelista.levererad, önskelista.PNR, önskelista.namn FROM önskelista LEFT JOIN barn ON önskelista.PNR = barn.PNR;

SELECT * FROM barnetsÖnskelista; 

CREATE VIEW barnetsInspelning AS SELECT inspelning.tid, inspelning.beskrivning, inspelning.PNR, inspelning.namn FROM inspelning LEFT JOIN barn ON inspelning.PNR = barn.PNR;

SELECT * FROM barnetsInspelning;

# Skapar en vy för att räkna ut hur mycket hjälpsamhet ett snälltbarn har. 0 är inga gjorda sysslor och 100 är alla sysslor gjorda.
CREATE VIEW hjälpsamhet AS SELECT utfördaSysslor/sysslor*100 AS hjälpsamhet, PNR, namn FROM snälltBarn;

SELECT * FROM hjälpsamhet;

/*GIVES THE CHILDREN ACCESS TO SELECT, DELETE and UPDATE to barnetsÖnskelista and barnetsInspelning */
GRANT SELECT, DELETE, UPDATE ON barnetsÖnskelista TO 'barn'@'localhost';
GRANT SELECT, DELETE, UPDATE ON barnetsInspelning TO 'barn'@'localhost';
GRANT SELECT ON önskelista TO 'barn'@'localhost';
GRANT SELECT ON inspelning  TO 'barn'@'localhost';

-- PUT ALL PROCEDURE AND TRIGGERS INSIDE THE DELIMITER
DELIMITER //
CREATE PROCEDURE uppdateraBarnBeskrivning(iPNR VARCHAR(14), iNamn VARCHAR(255), iBeskrivning TEXT)
BEGIN 
    IF (SELECT PNR FROM barnBeskrivning WHERE PNR = iPNR AND namn = iNamn) THEN
        UPDATE barnBeskrivning SET beskrivning = iBeskrivning WHERE PNR = iPNR AND namn = iNamn;
    ELSE 
        INSERT INTO barnBeskrivning(PNR, namn, beskrivning) VALUES (iPNR, iNamn, iBeskrivning);
END IF;
END; 

#PROCEDURE Som flyttar ifall ett barn går från snäll till mindre snällt.
CREATE PROCEDURE tillMindreSnälltBarn(iPNR VARCHAR(14), iNamn VARCHAR(255), iNivå INTEGER, iLeveransNummer CHAR(10)) 
BEGIN
	IF (SELECT PNR FROM snälltBarn WHERE PNR = iPNR AND namn = iNamn) THEN 
		DELETE FROM snälltBarn WHERE PNR = iPNR AND namn = iNamn;
		INSERT INTO mindreSnälltBarn(PNR, namn, nivå, leveransNummer) VALUES (iPNR, iNamn, iNivå , iLeveransNummer);
	ELSE 
		IF(SELECT PNR FROM mindreSnälltBarn WHERE PNR != iPNR AND namn != iNamn) THEN
			INSERT INTO mindreSnälltBarn(PNR, namn, nivå, leveransNummer) VALUES (iPNR, iNamn, iNivå , iLeveransNummer);
		END IF;
	END IF;
END;

#PROCEDURE Som flyttar ifall ett barn går från mindre snäll till snällt. Ifall 
CREATE PROCEDURE tillSnälltBarn(iPNR VARCHAR(14), iNamn VARCHAR(255)) 
BEGIN
	#Kollar ifall barnet är med i mindreSnällt och ifall barnet är där tas barnet bort från mindre snällt tabellen.
	IF (SELECT PNR FROM mindreSnälltBarn WHERE PNR = iPNR AND namn = iNamn) THEN 
		DELETE FROM mindreSnälltBarn WHERE PNR = iPNR AND namn = iNamn;
		INSERT INTO snälltBarn(PNR, namn) VALUES (iPNR, iNamn);
	ELSE 
		IF(SELECT PNR FROM snälltBarn WHERE PNR != iPNR AND namn != iNamn) THEN
			INSERT INTO snälltBarn(PNR, namn) VALUES (iPNR, iNamn);
		END IF;
	END IF;
END;

#Log på insert
CREATE TRIGGER tillSnälltBarnTrigger AFTER INSERT ON snälltBarn
 FOR EACH ROW BEGIN
	INSERT INTO barnLog(OPERATION, username, PNR, namn, tid, tabell) VALUES ("INS", USER(), new.PNR, new.namn, NOW(), "snälltBarn");
END;

#Log på insert
CREATE TRIGGER tillMindreSnälltBarnTrigger AFTER INSERT ON mindreSnälltBarn
 FOR EACH ROW BEGIN
 INSERT INTO barnLog(OPERATION, username, PNR, namn, tid, tabell) VALUES ("INS", USER(), new.PNR, new.namn, NOW(), "mindreSnälltBarn");
 END;
 
 #Log på insert
 CREATE TRIGGER barnBeskrvningTriggerINS AFTER INSERT ON barnBeskrivning
 FOR EACH ROW BEGIN 
	  INSERT INTO barnBeskrivningLOG(OPERATION, PNR, namn, tid) VALUES ("INS", new.PNR, new.Namn, NOW()); 
END;

#Log på update
CREATE TRIGGER barnBeskrivningTriggerUDP AFTER UPDATE ON barnBeskrivning
FOR EACH ROW BEGIN
	INSERT INTO barnBeskrivningLOG(OPERATION, PNR, namn, tid) VALUES ("UPD", new.PNR, new.Namn, NOW()); 
END//
DELIMITER ;


INSERT INTO barn(PNR, namn, födelseår) VALUES ("20070707-0707", "Simon Eldstrand", "2007-07-07");

INSERT INTO inspelning(tid, beskrivning, kvalitet, filnamn, PNR, namn) VALUES("2022-09-12 10:25:00", "SimonFilm", 78, "Simon", "20070707-0707","Simon Eldstrand");

INSERT INTO mindreSnälltBarn VALUES("20070707-0707", "Simon Eldstrand", 70, 32);

INSERT INTO barnRelation(PNR1, namn1, PNR2, namn2, typAvRelation) VALUES ("20070707-0707", "Simon Eldstrand", "20090909-0909", "Anders Andersson", "Kusiner");

SELECT * FROM barnRelation;

CALL uppdateraBarnBeskrivning("20070707-0707", "Simon Eldstrand", "Detta är en ny beskrivning");
CALL uppdateraBarnBeskrivning("20090909-0909", "Anders Andersson", "Detta är en uppdaterad beskrivning");
SELECT * FROM barnBeskrivning;
SELECT * FROM barnBeskrivningLOG;

SELECT * FROM mindreSnälltBarn;
SELECT * FROM snälltBarn;

CALL tillMindreSnälltBarn("20090909-0909","Anders Andersson", 2, 1);

SELECT * FROM barnLog;

CALL tillSnälltBarn("20090909-0909","Anders Andersson");

SELECT * FROM barnLog;
SELECT * FROM barnetsInspelning;