
-- indien het schema nog niet bestaat wordt het hier gemaakt.
CREATE SCHEMA IF NOT EXISTS groep_66;

-- hier maken we de tabellen aan.
CREATE  TABLE groep_66.dienst ( 
	dienst_id            char(8)  NOT NULL  ,
	dienst               varchar(50)  NOT NULL  ,
	prijs                smallint  NOT NULL  ,
	beschrijving         varchar(200)    ,
	CONSTRAINT pk_dienst PRIMARY KEY ( dienst_id )
 );

CREATE  TABLE groep_66.haven ( 
	haven_id             char(5)  NOT NULL  ,
	diepgang             smallint  NOT NULL  ,
	locatie              varchar(50)  NOT NULL  ,
	CONSTRAINT pk_haven PRIMARY KEY ( haven_id )
 );

CREATE  TABLE groep_66.schip ( 
	schip_id             char(11)  NOT NULL  ,
	naam                 varchar(50)  NOT NULL  ,
	max_passagiers       smallint  NOT NULL  ,
	diepgang             smallint  NOT NULL  ,
	CONSTRAINT pk_schip PRIMARY KEY ( schip_id )
 );

CREATE  TABLE groep_66.vaarroute ( 
	route_id             char(6)  NOT NULL  ,
	duur                 smallint  NOT NULL  ,
	beschrijving         varchar(200)    ,
	CONSTRAINT pk_vaarroute PRIMARY KEY ( route_id )
 );

CREATE  TABLE groep_66.vaarroute_haven ( 
	fk_route_id          char(6)  NOT NULL  ,
	fk_haven_id          char(5)  NOT NULL  ,
	van                  date  NOT NULL  ,
	tot                  date  NOT NULL  ,
	CONSTRAINT vaarroute_haven_id PRIMARY KEY ( fk_route_id, fk_haven_id, van ),
	CONSTRAINT fk_vaarroute_haven_vaarroute FOREIGN KEY ( fk_route_id ) REFERENCES groep_66.vaarroute( route_id )   ,
	CONSTRAINT fk_vaarroute_haven_haven FOREIGN KEY ( fk_haven_id ) REFERENCES groep_66.haven( haven_id )   
 );

CREATE  TABLE groep_66.attractie ( 
	attractie_id         char(6)  NOT NULL  ,
	naam                 varchar(50)  NOT NULL  ,
	beschrijving         varchar(200)    ,
	afstand_haven        smallint  NOT NULL  ,
	fk_haven_id          char(5)  NOT NULL  ,
	CONSTRAINT pk_attractie PRIMARY KEY ( attractie_id ),
	CONSTRAINT fk_attractie_haven FOREIGN KEY ( fk_haven_id ) REFERENCES groep_66.haven( haven_id )   
 );

CREATE  TABLE groep_66.cruise ( 
	cruise_id            char(7)  NOT NULL  ,
	naam                 varchar(50)  NOT NULL  ,
	prijs                smallint  NOT NULL  ,
	vertrek              date  NOT NULL  ,
	aankomst             date  NOT NULL  ,
	fk_schip_id          char(11)  NOT NULL  ,
	fk_route_id          char(6)  NOT NULL  ,
	CONSTRAINT pk_cruise PRIMARY KEY ( cruise_id ),
	CONSTRAINT fk_cruise_schip FOREIGN KEY ( fk_schip_id ) REFERENCES groep_66.schip( schip_id )   ,
	CONSTRAINT fk_cruise_vaarroute FOREIGN KEY ( fk_route_id ) REFERENCES groep_66.vaarroute( route_id )   
 );

-- in deze tabel kunnen we de FK van passagier nog niet toewijzen aangezien de tabel nog niet is aangemaakt
-- de tabel passagier bevat ook een FK van boeking, dus de tabellen in de andere volgorde creëren geeft hetzelfde probleem.
CREATE  TABLE groep_66.boeking ( 
	boeking_id           char(13)  NOT NULL  ,
	datum                date  NOT NULL  ,
	fk_cruise_id         char(7)  NOT NULL  ,
	fk_passagier_id      char(7)    ,
	CONSTRAINT pk_boeking PRIMARY KEY ( boeking_id )  ,
	CONSTRAINT fk_boeking_cruise FOREIGN KEY ( fk_cruise_id ) REFERENCES groep_66.cruise( cruise_id )
 );

CREATE  TABLE groep_66.boeking_dienst ( 
	fk_boeking_id        char(13)  NOT NULL  ,
	fk_dienst_id         char(8)  NOT NULL  ,
	CONSTRAINT boeking_dienst_id PRIMARY KEY ( fk_boeking_id, fk_dienst_id )  ,
	CONSTRAINT fk_boeking_dienst_dienst FOREIGN KEY ( fk_dienst_id ) REFERENCES groep_66.dienst( dienst_id )  ,
	CONSTRAINT fk_boeking_dienst_boeking FOREIGN KEY ( fk_boeking_id ) REFERENCES groep_66.boeking( boeking_id )
 );

CREATE  TABLE groep_66.kamer ( 
	kamer_id             char(7)  NOT NULL  ,
	capaciteit           smallint  NOT NULL  ,
	prijs                smallint  NOT NULL  ,
	"type"               varchar(50)  NOT NULL  ,
	fk_schip_id          char(11)  NOT NULL  ,
	fk_boeking_id        char(13)    ,
	CONSTRAINT pk_kamer PRIMARY KEY ( kamer_id, fk_schip_id )  ,
	CONSTRAINT fk_kamer_schip FOREIGN KEY ( fk_schip_id ) REFERENCES groep_66.schip( schip_id )  ,
	CONSTRAINT fk_kamer_boeking FOREIGN KEY ( fk_boeking_id ) REFERENCES groep_66.boeking( boeking_id )
 );

CREATE  TABLE groep_66.passagier ( 
	passagier_id         char(7)  NOT NULL  ,
	geslacht             char(1)  NOT NULL  ,
	naam                 varchar(50)  NOT NULL  ,
	voornaam             varchar(50)  NOT NULL  ,
	email                varchar(100)  NOT NULL  ,
	geboortedatum        date  NOT NULL  ,
	nationaliteit        char(2)  NOT NULL  ,
	fk_boeking_id        char(13)  NOT NULL  ,
	CONSTRAINT pk_passagier PRIMARY KEY ( passagier_id )  ,
	CONSTRAINT fk_passagier_boeking FOREIGN KEY ( fk_boeking_id ) REFERENCES groep_66.boeking( boeking_id )
 );

-- nu kunnen we de FK van boeking laten verwijzen naar passagier_id.
ALTER TABLE groep_66.boeking ADD CONSTRAINT fk_boeking_passagier FOREIGN KEY ( fk_passagier_id ) REFERENCES groep_66.passagier( passagier_id );
