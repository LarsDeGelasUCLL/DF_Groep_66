------------------------------------------------------------
------------------------------------------------------------

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

SET search_path TO groep_66;

SELECT 
    V.route_id, 
    V.duur AS route_duur,
    C.naam AS cruise_naam,
    S.naam AS schip_naam, 
    (C.prijs * COUNT(DISTINCT B.boeking_id)) AS totale_omzet
FROM vaarroute V
	INNER JOIN cruise C ON V.route_id = C.fk_route_id
	INNER JOIN schip S ON C.fk_schip_id = S.schip_id
	INNER JOIN boeking B ON C.cruise_id = B.fk_cruise_id
GROUP BY 
    V.route_id, V.duur, C.naam, S.naam, C.prijs
ORDER BY totale_omzet DESC LIMIT 10;

------------------------------------------------------------
------------------------------------------------------------

SET search_path TO groep_66;
SELECT 
    cruise.naam AS cruise_naam,
    schip.naam AS schip_naam,
    haven_start.locatie AS vertrek_haven,  -- Naam van de vertrekhaven
    haven_eind.locatie AS aankomst_haven,  -- Naam van de aankomsthaven
    MIN(cruise.vertrek) AS vertrek_datum,  -- Eerste vertrekdatum
    MAX(cruise.aankomst) AS aankomst_datum,  -- Laatste aankomstdatum
    (MAX(cruise.aankomst) - MIN(cruise.vertrek)) AS aantal_dagen,  -- Aantal dagen van de reis
    SUM(cruise.prijs) AS totale_reis_prijs  -- Totale prijs van de reis
FROM cruise
	INNER JOIN schip ON cruise.fk_schip_id = schip.schip_id
	INNER JOIN vaarroute ON cruise.fk_route_id = vaarroute.route_id
	INNER JOIN vaarroute_haven AS vh_start ON vaarroute.route_id = vh_start.fk_route_id
    AND vh_start.van = (
		SELECT MIN(van) 
		FROM vaarroute_haven 
		WHERE fk_route_id = vaarroute.route_id)
	INNER JOIN vaarroute_haven AS vh_eind ON vaarroute.route_id = vh_eind.fk_route_id
    AND vh_eind.tot = (
		SELECT MAX(tot) 
		FROM vaarroute_haven 
		WHERE fk_route_id = vaarroute.route_id)
	INNER JOIN haven AS haven_start ON vh_start.fk_haven_id = haven_start.haven_id
	INNER JOIN haven AS haven_eind ON vh_eind.fk_haven_id = haven_eind.haven_id
	LEFT JOIN boeking ON cruise.cruise_id = boeking.fk_cruise_id
	LEFT JOIN passagier ON boeking.fk_passagier_id = passagier.passagier_id
GROUP BY 
    cruise.naam, schip.naam, schip.max_passagiers, haven_start.locatie, haven_eind.locatie, cruise.vertrek
ORDER BY cruise.vertrek ASC;  -- Sorteer op vertrekdatum in oplopende volgorde

------------------------------------------------------------
------------------------------------------------------------
