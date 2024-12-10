------------------------------------------------------------
------------------------------------------------------------

-- Laat zien hoeveel de hoofdboeker moet betalen.
-- geeft de e-mail van de Hboeker en de totale prijs.

SET search_path TO groep_66;

SELECT 
	P.naam ||', '||P.voornaam AS naam, 
	P.email AS "E-mail", 
	C.prijs AS basisprijs_cruise, 
	SUM(CASE WHEN D.prijs IS NULL THEN 0 ELSE D.prijs END) AS tot_prijs_dienst, 
	K.prijs AS prijs_kamer_per_dag, 
	V.duur AS dagen_op_zee,
	(K.prijs * V.duur) AS tot_prijs_kamer,
	(C.prijs + SUM(CASE WHEN D.prijs IS NULL THEN 0 ELSE D.prijs END) + (K.prijs * V.duur)) AS totaal_prijs
FROM boeking B 
	INNER JOIN passagier P ON B.fk_passagier_id = P.passagier_id
	LEFT JOIN boeking_dienst BD ON B.boeking_id = BD.fk_boeking_id
	LEFT JOIN dienst D ON BD.fk_dienst_id = D.dienst_id
	INNER JOIN cruise C ON B.fk_cruise_id = C.cruise_id
	INNER JOIN kamer K ON B.boeking_id = K.fk_boeking_id 
	INNER JOIN vaarroute V on C.fk_route_id = V.route_id
GROUP BY 
	P.naam, P.voornaam, P.email, C.prijs, K.prijs, V.duur
ORDER BY P.naam;

------------------------------------------------------------
------------------------------------------------------------

-- Geeft de populairste reisbestemming (cruise) van de belgen weer,
-- en we kunnen aflezen of ze liever voor goedkopere bestemmingen gaan of niet.

SET search_path TO groep_66;

SELECT
	P.nationaliteit,
	C.naam AS cruise_naam,
	C.prijs AS prijs_cruise,
	COUNT (DISTINCT B.boeking_id) AS aantal_boekingen,
	COUNT (P.passagier_id) AS aantal_passagiers
FROM boeking B
	INNER JOIN passagier P ON B.boeking_id = P.fk_boeking_id
	INNER JOIN cruise C ON B.fk_cruise_id = C.cruise_id
WHERE P.nationaliteit = 'BE'
GROUP BY P.nationaliteit, C.naam, C.prijs
ORDER BY aantal_boekingen DESC;

------------------------------------------------------------
------------------------------------------------------------

-- Geeft de cruises en de schepen waarmee ze gevaart worden,
-- en we kunnen makkelijk bevestigen dat de havens waar de cruise passeert 
-- diep genoeg zijn voor onze schepen om er aan te meren.

SET search_path TO groep_66;

SELECT
	C.naam AS naam_cruise,
	S.naam AS naam_schip,
	S.diepgang AS schip_diepgang,
	H.diepgang AS haven_diepgang,
	H.locatie AS haven_locatie,
	H.haven_id
FROM haven H
	INNER JOIN vaarroute_haven VH ON H.haven_id = VH.fk_haven_id
	INNER JOIN vaarroute V ON VH.fk_route_id = V.route_id
	INNER JOIN cruise C ON V.route_id = C.fk_route_id
	INNER JOIN schip S ON C.fk_schip_id = S.schip_id
WHERE
	C.naam = 'Northern Lights Expedition'
	OR C.naam = 'Caribbean Escape'
	OR C.naam ='Mediterranean Wonders'
ORDER BY C.naam

------------------------------------------------------------
------------------------------------------------------------

-- Geeft in volgorde weer welke cruise het meeste geld hebben opgebracht.
-- we kunnen ook aflezen of mensen meer geintereseerd zijn in lange cruises.

SET search_path TO groep_66;

SELECT 
    V.route_id, 
    V.duur AS dagen_op_zee,
    C.naam AS naam_cruise,
    S.naam AS naam_schip, 
	COUNT(DISTINCT B.boeking_id) AS boekingen,
	C.prijs AS prijs_cruise,
    (C.prijs * COUNT(DISTINCT B.boeking_id)) AS totaal_winst
FROM vaarroute V
	INNER JOIN cruise C ON V.route_id = C.fk_route_id
	INNER JOIN schip S ON C.fk_schip_id = S.schip_id
	INNER JOIN boeking B ON C.cruise_id = B.fk_cruise_id
GROUP BY 
    V.route_id, V.duur, C.naam, S.naam, C.prijs
HAVING (C.prijs * COUNT(DISTINCT B.boeking_id)) > 8000
ORDER BY totaal_winst DESC;

-- Hulpquery voor demo.
SELECT *
FROM groep_66.boeking
ORDER BY fk_cruise_id

------------------------------------------------------------
------------------------------------------------------------

SET search_path TO groep_66;

SELECT
    C.naam AS naam_cruise,
    S.naam AS naam_schip,
    H_START.locatie AS vertrek_haven,
	C.vertrek AS vertrek_datum,
    H_END.locatie AS aankomst_haven,
    C.aankomst AS aankomst_datum,
    V.duur AS aantal_dagen
FROM cruise C
	INNER JOIN schip S ON C.fk_schip_id = S.schip_id
	INNER JOIN vaarroute V ON C.fk_route_id = V.route_id
	
	INNER JOIN vaarroute_haven AS VH_START ON V.route_id = VH_START.fk_route_id
    AND VH_START.van = ( SELECT MIN(VH.van) 
		FROM vaarroute_haven AS VH
		WHERE VH.fk_route_id = V.route_id )
	INNER JOIN haven AS H_START ON VH_START.fk_haven_id = H_START.haven_id
	
	INNER JOIN vaarroute_haven AS VH_END ON V.route_id = VH_END.fk_route_id
    AND VH_END.tot = ( SELECT MAX(VH.tot) 
		FROM vaarroute_haven AS VH
		WHERE VH.fk_route_id = V.route_id )
	INNER JOIN haven AS H_END ON VH_END.fk_haven_id = H_END.haven_id
WHERE
	C.naam = 'Northern Lights Expedition'
	OR C.naam = 'Caribbean Escape'
	OR C.naam ='Mediterranean Wonders'
GROUP BY 
    C.naam, S.naam, H_START.locatie, H_END.locatie, C.vertrek, C.aankomst, V.duur
ORDER BY C.vertrek ASC;

------------------------------------------------------------
------------------------------------------------------------
