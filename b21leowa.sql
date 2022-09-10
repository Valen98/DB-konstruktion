drop database B21leowa;
create database b21leowa;

use b21leowa;

# DEFAULT TABLE FOR BARN 
CREATE TABLE barn(
	PNR CHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    födelseår CHAR(4) NOT NULL,
    PRIMARY KEY (PNR, namn)
)ENGINE=INNODB;

#TABLE FOR BARN INHERITANCE
CREATE TABLE snälltBarn(
	PNR CHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
	hjälpsamhet INTEGER,
    FOREIGN KEY (PNR, namn) REFERENCES barn(PNR, namn),
    PRIMARY KEY(PNR, namn)
)ENGINE=INNODB;

# TABLE FOR BARN INHERITANCE
CREATE TABLE mindreSnälltBarn(
	PNR CHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    nivå INTEGER,
    leveransNummer CHAR(10),
    FOREIGN KEY (PNR, namn) REFERENCES barn(PNR, namn),
    PRIMARY KEY(PNR, namn)
)ENGINE=INNODB;

CREATE TABLE inspelning(
	tid DATETIME NOT NULL,
    beksrivning VARCHAR(11),
    kvalitet CHAR(3),
    filnamn VARCHAR(10),
    inspelningsText TEXT,
    PNR CHAR(14) NOT NULL,
    namn VARCHAR(255) NOT NULL,
    FOREIGN KEY(PNR, namn) REFERENCES barn(PNR, namn),
    PRIMARY KEY (tid, PNR, namn)
)ENGINE=INNODB;

# CREATES A NEW TABLE FOR HORIZONTAL DENORMALIZATION ON COMMENT
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