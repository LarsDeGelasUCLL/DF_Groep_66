--------------------------------------------------
-- Hier word de data van de tabellen verwijdert.
DELETE FROM groep_66.boeking_dienst;
DELETE FROM groep_66.kamer;
DELETE FROM groep_66.vaarroute_haven;


-- Eerst word de FK van boeking op NULL gezet zodat we de tabel passagier
-- kunnen verwijderen zonder dat de passagier_id nog naar een waarde in boeking verwijst.
UPDATE groep_66.boeking SET fk_passagier_id = NULL;

-- Nu kunnen we passagier, gevolgd door boeking, verwijderen.
DELETE FROM groep_66.passagier;
DELETE FROM groep_66.boeking;

DELETE FROM groep_66.attractie;
DELETE FROM groep_66.dienst;
DELETE FROM groep_66.haven;
DELETE FROM groep_66.cruise;
DELETE FROM groep_66.schip;
DELETE FROM groep_66.vaarroute;

--------------------------------------------------
-- Hier worden de tabellen zelf verwijdert.
DROP TABLE groep_66.boeking_dienst;
DROP TABLE groep_66.kamer;
DROP TABLE groep_66.vaarroute_haven;

-- Gelijkaardig als bij het verwijderen van de data zorgen we eerst dat de
-- fk_passagier_id in boeking niet meer verwijst naar de passagier_id in passagier,
ALTER TABLE groep_66.boeking DROP CONSTRAINT fk_boeking_passagier;

-- en vervolgens kunnen we eerst passgier verwijderen gevolgd door boeking.
DROP TABLE groep_66.passagier;
DROP TABLE groep_66.boeking;

DROP TABLE groep_66.attractie;
DROP TABLE groep_66.dienst;
DROP TABLE groep_66.haven;
DROP TABLE groep_66.cruise;
DROP TABLE groep_66.schip;
DROP TABLE groep_66.vaarroute;
--------------------------------------------------