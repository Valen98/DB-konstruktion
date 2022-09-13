DROP DATABASE B21leowa;
CREATE DATABASE b21leowa;
DROP USER 'barn'@'localhost';
DROP USER 'admin'@'localhost';
FLUSH PRIVILEGES;
USE b21leowa;

-- Tables

-- DEFAULT TABLE FOR BARN 
CREATE TABLE barn(
	PNR VARCHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    födelseår DATE NOT NULL,
    PRIMARY KEY (PNR, namn)
)ENGINE=INNODB;

-- CREATE INDEX barnPNR ON barn(PNR);

-- INSERT DEFAULT CHILD FOR TESTING THE DB
INSERT INTO barn(PNR, namn, födelseår) VALUES ("20090909-0909", "Anders Andersson", "2009-09-09");

-- TABLE FOR BARN INHERITANCE
CREATE TABLE snälltBarn(
	PNR VARCHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
	hjälpsamhet INTEGER,
    FOREIGN KEY (PNR, namn) REFERENCES barn(PNR, namn),
    PRIMARY KEY(PNR, namn)
)ENGINE=INNODB;

-- TABLE FOR BARN INHERITANCE
CREATE TABLE mindreSnälltBarn(
	PNR VARCHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    nivå INTEGER,
    leveransNummer CHAR(10),
    FOREIGN KEY (PNR, namn) REFERENCES barn(PNR, namn),
    PRIMARY KEY(PNR, namn)
)ENGINE=INNODB;

-- Horizontell split from child and childText
CREATE TABLE barnBeskrivning (
    beskrivning TEXT,
	PNR VARCHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
	FOREIGN KEY (PNR, namn) REFERENCES barn(PNR, namn),
	PRIMARY KEY(PNR, namn)
)ENGINE=INNODB;

CREATE TABLE inspelning(
	tid DATETIME NOT NULL,
    beskrivning VARCHAR(11),
    kvalitet TINYINT,
    filnamn VARCHAR(10),
    PNR VARCHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    FOREIGN KEY(PNR, namn) REFERENCES barn(PNR, namn),
    PRIMARY KEY (tid, PNR, namn)
)ENGINE=INNODB;

-- CREATES A NEW TABLE FOR HORIZONTAL DENORMALIZATION ON COMMENT
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


xCREATE TABLE önskelistaViewVärde (
     årtal DATE NOT NULL,
     PNR CHAR(14) NOT NULL,
     pris FLOAT
)ENGINE=INNODB;


-- Inserts
INSERT INTO önskelista(årtal, medgiven, beskrivning, levererad, PNR, namn) VALUES ("2022-09-12", 0, "Vattenpistol", 0, "20090909-0909", "Anders Andersson");
INSERT INTO inspelning(tid, beskrivning, kvalitet, filnamn, PNR, namn) VALUES("2022-09-12 10:25:00", "AndersFilm", 78, "Anders", "20090909-0909","Anders Andersson");
INSERT INTO barnBeskrivning(PNR, namn, beskrivning) VALUES("20090909-0909", "Anders Andersson" ,"Detta är en beskrivning");

SELECT * FROM barnBeskrivning;

-- Users

CREATE USER 'barn'@'localhost' IDENTIFIED BY 'barn';

CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';

SELECT * FROM önskelista, barn WHERE önskelista.PNR = barn.PNR;


 -- Views 
#A view where the child for his/hers own wishlist
CREATE VIEW barnetsÖnskelista AS SELECT önskelista.årtal, önskelista.beskrivning, önskelista.levererad, önskelista.PNR, önskelista.namn FROM önskelista LEFT JOIN barn ON önskelista.PNR = barn.PNR;

SELECT * FROM barnetsÖnskelista; 

CREATE VIEW barnetsInspelning AS SELECT inspelning.tid, inspelning.beskrivning, inspelning.PNR, inspelning.namn FROM inspelning LEFT JOIN barn ON inspelning.PNR = barn.PNR;

SELECT * FROM barnetsInspelning;

/*GIVES THE CHILDREN ACCESS TO SELECT, DELETE and UPDATE to barnetsÖnskelista and barnetsInspelning */
GRANT SELECT, DELETE, UPDATE ON barnetsÖnskelista TO 'barn'@'localhost';
GRANT SELECT, DELETE, UPDATE ON barnetsInspelning TO 'barn'@'localhost';

SELECT PNR as bPNR FROM barn;

-- PUT ALL PROCEDURE INSIDE THE DELIMITER
DELIMITER //
CREATE PROCEDURE insertChild(iPNR VARCHAR(14), iNamn VARCHAR(255), iFödelseår DATE)  
BEGIN 
    INSERT INTO barn(PNR, namn, födelseår) VALUES (iPNR, iNamn, iFödelseår);
END;


CREATE PROCEDURE uppdateraBarnBeskrivning(iPNR VARCHAR(14), iNamn VARCHAR(255), iBeskrivning TEXT)
BEGIN 
DECLARE uPNR VARCHAR(14);
SELECT PNR INTO uPNR FROM barnBeskrivning;
SELECT UPNR;
    IF (uPNR=iPNR) THEN
        UPDATE barnBeskrivning SET beskrivning = iBeskrivning WHERE PNR = uPNR;
    ELSE 
        INSERT INTO barnBeskrivning(PNR, namn, beskrivning) VALUES (iPNR, iNamn, iBeskrivning);
        SELECT 'Lägger in ett nytt meddelande' FROM barnBeskrivning;
    END IF;

END//
DELIMITER ;


CALL insertChild("20070707-0707", "Simon Eldstrand", "2007-07-07");
CALL uppdateraBarnBeskrivning("20070707-0707", "Simon Eldstrand", "Detta är en ny beskrivning");
CALL uppdateraBarnBeskrivning("20090909-0909", "Anders Andersson", "Detta är en uppdaterad beskrivning");
SELECT * FROM barnBeskrivning;