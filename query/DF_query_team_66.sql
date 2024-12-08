SET search_path TO groep_66;

SELECT 
	P.naam ||', '||P.voornaam AS naam, 
	P.email, 
	C.prijs AS cruise_prijs, 
	sum(D.prijs) AS tot_prijs_dienst, 
	K.prijs AS prijs_kamer, 
	(C.prijs + sum(D.prijs) + K.prijs) AS totaal_prijs
FROM boeking B 
	INNER JOIN passagier P ON B.fk_passagier_id = P.passagier_id
	INNER JOIN boeking_dienst BD ON B.boeking_id = BD.fk_boeking_id
	INNER JOIN dienst D ON BD.fk_dienst_id = D.dienst_id
	INNER JOIN cruise C ON B.fk_cruise_id = C.cruise_id
	INNER JOIN kamer K ON B.boeking_id = K.fk_boeking_id 
GROUP BY 
	P.naam, P.voornaam, P.email, C.prijs, K.prijs
ORDER BY P.naam;
