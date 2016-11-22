/*
 TP2 BDDR M1 INFO
 AUTEURS : PELLETIER Sebastien, BOUDERMINE Antoine
*/

DROP TABLE SURVEILLANCES;
DROP TABLE OCCUPATIONS;
DROP TABLE HORAIRES;
DROP TABLE INSCRIPTIONS;
DROP TABLE SALLES;
DROP TABLE EPREUVES;
DROP TABLE ENSEIGNANTS;
DROP TABLE ETUDIANTS;

purge recyclebin;

CREATE TABLE Etudiants(
  NumEtu    NUMERIC(6) PRIMARY KEY,
  NomEtu    CHAR(20)   NOT NULL,
  PrenomEtu CHAR(20)   NOT NULL
  );

CREATE TABLE Enseignants(
  NumEns    NUMERIC(6) PRIMARY KEY,
  NomEns    CHAR(20)   NOT NULL,
  PrenomEns CHAR(20)   NOT NULL
  );
  
CREATE TABLE Salles(
  NumSal      NUMERIC(6) PRIMARY KEY,
  NomSal      CHAR(10)   NOT NULL,
  CapaciteSal NUMERIC(3) NOT NULL
  );
  
CREATE TABLE Epreuves(
  NumEpr  NUMERIC(6) PRIMARY KEY,
  NomEpr  CHAR(20)   NOT NULL,
  DureeEpr INTERVAL DAY TO SECOND(0) NOT NULL
  );

CREATE TABLE Inscriptions(
  NumEtu NUMERIC(6) REFERENCES Etudiants,
  NumEpr NUMERIC(6) REFERENCES Epreuves,
  PRIMARY KEY (NumEtu, NumEpr)
  );

CREATE TABLE Surveillances(
  NumEns         NUMERIC(6) REFERENCES Enseignants,
  DateHeureDebut TIMESTAMP(0),
  NumSal         NUMERIC(6) REFERENCES Salles,
  PRIMARY KEY (NumEns, DateHeureDebut)
  );

CREATE TABLE HORAIRES(
  NumEpr NUMERIC(6) REFERENCES Epreuves,
  DateHeureDebut TIMESTAMP(0),
  PRIMARY KEY (NumEpr)
  );

CREATE TABLE Occupations(
  NumSal NUMERIC(6) REFERENCES Salles,
  NumEpr NUMERIC(6) REFERENCES Epreuves,
  NbPlacesOcc NUMERIC(6) NOT NULL,
  PRIMARY KEY(NumSal, NumEpr)
  );

/*C1*/


CREATE OR REPLACE TRIGGER C1_horaire_I_U
AFTER INSERT OR UPDATE
ON Horaires
DECLARE
  N binary_integer;
BEGIN
  SELECT 1 INTO N
  FROM  (SELECT E.NumEpr, E.DureeEpr, I.NumEtu, H.DateHeureDebut
         FROM Epreuves E, Inscriptions I, Horaires H
         WHERE E.NumEpr = I.NumEpr
         AND   H.NumEpr = E.NumEpr) a, 
        (SELECT E.NumEpr, E.DureeEpr, I.NumEtu, H.DateHeureDebut
         FROM Epreuves E, Inscriptions I, Horaires H
         WHERE E.NumEpr = I.NumEpr
         AND   H.NumEpr = E.NumEpr) b
  WHERE a.NumEtu = b.NumEtu
  AND a.NumEpr > b.NumEpr
  AND (a.DateHeureDebut, a.DureeEpr) OVERLAPS (b.DateHeureDebut, b.DureeEpr);

  RAISE too_many_rows;
  
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C1');
    WHEN no_data_found THEN NULL;

END;
/

CREATE OR REPLACE TRIGGER C1_inscription_I_U
AFTER INSERT OR UPDATE
ON Inscriptions
DECLARE
  N binary_integer;
BEGIN
  SELECT 1 INTO N
  FROM  (SELECT E.NumEpr, E.DureeEpr, I.NumEtu, H.DateHeureDebut
         FROM Epreuves E, Inscriptions I, Horaires H
         WHERE E.NumEpr = I.NumEpr
         AND   H.NumEpr = E.NumEpr) a, 
        (SELECT E.NumEpr, E.DureeEpr, I.NumEtu, H.DateHeureDebut
         FROM Epreuves E, Inscriptions I, Horaires H
         WHERE E.NumEpr = I.NumEpr
         AND   H.NumEpr = E.NumEpr) b
  WHERE a.NumEtu = b.NumEtu
  AND a.NumEpr > b.NumEpr
  AND (a.DateHeureDebut, a.DureeEpr) OVERLAPS (b.DateHeureDebut, b.DureeEpr);

  RAISE too_many_rows;
  
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C1_ins');
    WHEN no_data_found THEN NULL;

END; 
/

CREATE OR REPLACE TRIGGER C1_epreuves_I_U
AFTER UPDATE
ON Epreuves
DECLARE
  N binary_integer;
BEGIN
  SELECT 1 INTO N
  FROM  (SELECT E.NumEpr, E.DureeEpr, I.NumEtu, H.DateHeureDebut
         FROM Epreuves E, Inscriptions I, Horaires H
         WHERE E.NumEpr = I.NumEpr
         AND   H.NumEpr = E.NumEpr) a, 
        (SELECT E.NumEpr, E.DureeEpr, I.NumEtu, H.DateHeureDebut
         FROM Epreuves E, Inscriptions I, Horaires H
         WHERE E.NumEpr = I.NumEpr
         AND   H.NumEpr = E.NumEpr) b
  WHERE a.NumEtu = b.NumEtu
  AND a.NumEpr > b.NumEpr
  AND (a.DateHeureDebut, a.DureeEpr) OVERLAPS (b.DateHeureDebut, b.DureeEpr);

  RAISE too_many_rows;
  
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C1_ins');
    WHEN no_data_found THEN NULL;

END; 
/

/*C2*/


CREATE OR REPLACE TRIGGER C2_epreuve_I_U
AFTER INSERT OR UPDATE
ON Epreuves
DECLARE
  N binary_integer;
BEGIN
  SELECT 1 INTO N
  FROM  (SELECT E.NumEpr, E.DureeEpr, H.DateHeureDebut, O.NumSal
         FROM Epreuves E, Occupations O, Horaires H
         WHERE E.NumEpr = H.NumEpr
         AND   O.NumEpr = E.NumEpr) a, 
        (SELECT E.NumEpr, E.DureeEpr, H.DateHeureDebut, O.NumSal
         FROM Epreuves E, Occupations O, Horaires H
         WHERE E.NumEpr = H.NumEpr
         AND   O.NumEpr = E.NumEpr) b
  WHERE a.NumSal = b.NumSal
  AND a.NumEpr > b.NumEpr
  AND a.DateHeureDebut <> b.DateHeureDebut
  AND (a.DateHeureDebut, a.DureeEpr) OVERLAPS (b.DateHeureDebut, b.DureeEpr);

  RAISE too_many_rows;
  
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C2');
    WHEN no_data_found THEN NULL;

END;
/

CREATE OR REPLACE TRIGGER C2_horaires_I_U
AFTER INSERT OR UPDATE
ON Horaires
DECLARE
  N binary_integer;
BEGIN
  SELECT 1 INTO N
  FROM  (SELECT E.NumEpr, E.DureeEpr, H.DateHeureDebut, O.NumSal
         FROM Epreuves E, Occupations O, Horaires H
         WHERE E.NumEpr = H.NumEpr
         AND   O.NumEpr = E.NumEpr) a, 
        (SELECT E.NumEpr, E.DureeEpr, H.DateHeureDebut, O.NumSal
         FROM Epreuves E, Occupations O, Horaires H
         WHERE E.NumEpr = H.NumEpr
         AND   O.NumEpr = E.NumEpr) b
  WHERE a.NumSal = b.NumSal
  AND a.NumEpr > b.NumEpr
  AND a.DateHeureDebut <> b.DateHeureDebut
  AND (a.DateHeureDebut, a.DureeEpr) OVERLAPS (b.DateHeureDebut, b.DureeEpr);

  RAISE too_many_rows;
  
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C2');
    WHEN no_data_found THEN NULL;

END;
/

CREATE OR REPLACE TRIGGER C2_occupations_I_U
AFTER INSERT OR UPDATE
ON occupations
DECLARE
  N binary_integer;
BEGIN
  SELECT 1 INTO N
  FROM  (SELECT E.NumEpr, E.DureeEpr, H.DateHeureDebut, O.NumSal
         FROM Epreuves E, Occupations O, Horaires H
         WHERE E.NumEpr = H.NumEpr
         AND   O.NumEpr = E.NumEpr) a, 
        (SELECT E.NumEpr, E.DureeEpr, H.DateHeureDebut, O.NumSal
         FROM Epreuves E, Occupations O, Horaires H
         WHERE E.NumEpr = H.NumEpr
         AND   O.NumEpr = E.NumEpr) b
  WHERE a.NumSal = b.NumSal
  AND a.NumEpr > b.NumEpr
  AND a.DateHeureDebut <> b.DateHeureDebut
  AND (a.DateHeureDebut, a.DureeEpr) OVERLAPS (b.DateHeureDebut, b.DureeEpr);

  RAISE too_many_rows;
  
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C2');
    WHEN no_data_found THEN NULL;

END;
/

CREATE OR REPLACE TRIGGER C3_Occupations_U_I
AFTER INSERT OR UPDATE
ON Occupations
DECLARE
  N binary_integer;
BEGIN
    SELECT 1 INTO N
    FROM
    (
      SELECT Occupations.NumSal
      FROM Occupations, Horaires, Salles
      WHERE Occupations.NumEpr = Horaires.NumEpr
      AND Occupations.NumSal = Salles.NumSal
      GROUP BY Occupations.NumSal, CapaciteSal
      HAVING sum(NbPlacesOcc) > Salles.CAPACITESAL
    );
    
    RAISE too_many_rows;
  
    EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C4');
    WHEN no_data_found THEN NULL;
END;
/

CREATE OR REPLACE TRIGGER C3_Salles_U_D
AFTER UPDATE OR DELETE
ON Salles
DECLARE
  N binary_integer;
BEGIN
    SELECT 1 INTO N
    FROM
    (
      SELECT Occupations.NumSal
      FROM Occupations, Horaires, Salles
      WHERE Occupations.NumEpr = Horaires.NumEpr
      AND Occupations.NumSal = Salles.NumSal
      GROUP BY Occupations.NumSal, CapaciteSal
      HAVING sum(NbPlacesOcc) > Salles.CAPACITESAL
    );
    
    RAISE too_many_rows;
  
    EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C4');
    WHEN no_data_found THEN NULL;
END;
/

---------------  New  ----------------------


-- Update/Delete sur Horaires
create or replace TRIGGER C4_HORAIRES_U_D
AFTER UPDATE OR DELETE
ON Horaires
FOR EACH ROW
DECLARE
  N binary_integer;
  A integer;
  B integer;
  C integer;
BEGIN

  select count(*) into A from SURVEILLANCES;
  
  if  A < 1 then
   RAISE too_many_rows;
  end if;
  
  SELECT count(*) INTO B
  FROM Surveillances s, Occupations o, Horaires h
  WHERE s.NumSal not in ( select NumSal from Occupations );
    
  if B > 0 then
    RAISE too_many_rows;
  end if;
    
  SELECT count(*) INTO C
  FROM Surveillances s, Occupations o, Horaires h
  WHERE s.NumSal = o.NumSal
  AND o.NumEpr = h.NumEpr
  AND s.DateHeureDebut != h.DateHeureDebut;
  
  if C > 0 then
    RAISE too_many_rows;
  end if;

    
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C4');
    WHEN no_data_found THEN NULL;
END;
/

-- Update/Delete sur Occupations 
create or replace TRIGGER C4_OCCUPATIONS_U_D
AFTER UPDATE OR DELETE
ON Occupations
FOR EACH ROW
DECLARE
  N binary_integer;
  A integer;
  B integer;
  C integer;
BEGIN

  select count(*) into A from SURVEILLANCES;
  
  if  A < 1 then
   RAISE too_many_rows;
  end if;
  
  SELECT count(*) INTO B
  FROM Surveillances s, Occupations o, Horaires h
  WHERE s.NumSal not in ( select NumSal from Occupations );
    
  if B > 0 then
    RAISE too_many_rows;
  end if;
    
  SELECT count(*) INTO C
  FROM Surveillances s, Occupations o, Horaires h
  WHERE s.NumSal = o.NumSal
  AND o.NumEpr = h.NumEpr
  AND s.DateHeureDebut != h.DateHeureDebut;
  
  if C > 0 then
    RAISE too_many_rows;
  end if;
  
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C4');
    WHEN no_data_found THEN NULL;
END;
/

-- Update/Insert sur Surveillance
create or replace TRIGGER C4_SURVEILLANCES_U_I
AFTER UPDATE OR INSERT
ON Surveillances
FOR EACH ROW
DECLARE
  N binary_integer;
  A integer;
  B integer;
  C integer;
BEGIN

  select count(*) into A from SURVEILLANCES;
  
  if  A < 1 then
   RAISE too_many_rows;
  end if;
  
  SELECT count(*) INTO B
  FROM Surveillances s, Occupations o, Horaires h
  WHERE s.NumSal not in ( select NumSal from Occupations );
    
  if B > 0 then
    RAISE too_many_rows;
  end if;
    
  SELECT count(*) INTO C
  FROM Surveillances s, Occupations o, Horaires h
  WHERE s.NumSal = o.NumSal
  AND o.NumEpr = h.NumEpr
  AND s.DateHeureDebut != h.DateHeureDebut;
  
  if C > 0 then
    RAISE too_many_rows;
  end if;
  
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C4');
    WHEN no_data_found THEN NULL;
END;
/

commit;
---------------- Interférence pour la contrainte C1 -------------------

-- Deux épreuves quit ont des étudiants en commun
-- ne peuvent pas avoir lieux en même temp.

-- Pour mettre en évidence le conflit on va utiliser ces données puis
-- modifier un horraire qui ne pausait pas de problèmme et inscrire
-- un étudiant à cette horraire sur une autre transaction.

INSERT INTO Etudiants VALUES
  (0, 'Grenet', 'Maxine');

INSERT INTO Epreuves VALUES
  (0, 'Theorie du signal', INTERVAL '1' HOUR);
INSERT INTO Epreuves VALUES
  (1, 'cplusplus', INTERVAL '1' HOUR);

INSERT INTO Horaires VALUES
  (0, TIMESTAMP '2015-02-01 10:00:00');
INSERT INTO Horaires VALUES
  (1, TIMESTAMP '2015-02-01 11:00:00');

INSERT INTO Inscriptions VALUES
  (0, 1);

commit;


-- T1 --
--LOCK TABLE Inscriptions IN Share MODE;
Update Horaires
set DateHeureDebut = Timestamp '2015-02-01 11:00:00'
where NumEpr = 0;
--commit;

-- T2 --
----LOCK TABLE Horaires IN Share MODE;
--Insert into Inscriptions
--values
--(0, 0);
--commit;

-- Pour gérer la concurence, on pose des véroux SHARE sur chaque 
-- les tables concerné.

-- On peut voir un etudiant inscrit à deux épreuves qui se déroulent
-- au même moment (version sans les LOCK).
select * from Inscriptions;
select * from Horaires;

-- La pose d'un vérous SHARE sur la table bloque :
--     - Les vérous excluxifs
--     - Les intentions d'écritures sur la table
--     - SRX


---------------- Interférence pour la contrainte C2 -------------------

-- Toutes les épreuves qui ont lieu dans une même salle au même moment
-- doivent commencer en même temps.

INSERT INTO Epreuves VALUES
  (0, 'Theorie du signal', INTERVAL '1' HOUR);
INSERT INTO Epreuves VALUES
  (1, 'Complexité', INTERVAL '1' HOUR);

INSERT INTO Salles VALUES
  (0, 'T1', 10);
  
INSERT INTO Horaires VALUES
  (0, TIMESTAMP '2015-02-01 10:00:00');
  
INSERT INTO Horaires VALUES
  (1, TIMESTAMP '2015-02-01 10:30:00');
  
commit;

-- Pour le test, on essai de mettre dans une même salle
-- deux épreuves qui ne commence pas au même moment.

-- T1 --
--LOCK TABLE Occupations IN Share MODE;
INSERT INTO Occupations VALUES
  (0, 0, 3);
  
-- T2 --
-- --LOCK TABLE Occupations IN Share MODE;
--INSERT INTO Occupations VALUES
--  (0, 1, 2);


-- Pour gérer la concurence, on pose des véroux SHARE sur
-- les tables concerné (ils sont commenté).

-- La pose d'un vérous SHARE sur la table bloque :
--     - Les vérous excluxifs
--     - Les intentions d'écritures sur la table
--     - SRX

select * from epreuves;
select * from horaires;
select * from occupations;


---------------- Interférence pour la contrainte C3 -------------------

-- Le nombre total de places occupées par les épreuves qui ont lieux
-- dans une même salle au même moment, ne doit pas dépasser la capacité
-- de la salle.

INSERT INTO Epreuves VALUES
  (0, 'Theorie du signal', INTERVAL '1' HOUR);
INSERT INTO Epreuves VALUES
  (1, 'Complexité', INTERVAL '1' HOUR);

INSERT INTO Salles VALUES
  (0, 'T1', 10);
  
INSERT INTO Horaires VALUES
  (0, TIMESTAMP '2015-02-01 10:00:00');
  
INSERT INTO Horaires VALUES
  (1, TIMESTAMP '2015-02-01 10:00:00');
  
commit;

-- Ici on essai de mettre deux épreuve dans une même salle
-- se qui aurai pour effet de remplire la salle : 18 places sur 10

--- T1 ---
--LOCK TABLE Occupations IN Share MODE;
INSERT INTO Occupations VALUES
  (0, 0, 9);
commit;

--- T2 ---
-- --LOCK TABLE Occupations IN Share MODE;
--INSERT INTO Occupations VALUES
--  (0, 1, 9);
--commit;

-- Pour gérer la concurence, on pose des véroux SHARE sur
-- les tables concerné (ils sont commenté).


-- La pose d'un vérous SHARE sur la table bloque :
--     - Les vérous excluxifs
--     - Les intentions d'écritures sur la table
--     - SRX


---------------- Interférence pour la contrainte C4 -------------------

-- Un enseignant assure une surveillance dans une salle uniquement
-- lorsqu'une épreuve à lieu.


INSERT INTO Salles VALUES
  (0, 'T1', 10);
  
INSERT INTO Epreuves VALUES
  (0, 'Theorie du signal', INTERVAL '1' HOUR);

INSERT INTO Enseignants VALUES
  (0, 'Langevin', 'Patrique');
  
INSERT INTO Occupations VALUES
  (0, 0, 9);

INSERT INTO Horaires VALUES
  (0, TIMESTAMP '2015-02-01 10:00:00');
  
commit;

--- T1 ---
--LOCK TABLE Occupations IN Share MODE;
INSERT INTO Surveillances VALUES
  (0, TIMESTAMP '2015-02-01 10:00:00', 0);
  
--- T2 ---
----LOCK TABLE Surveillances IN Share MODE;
--DELETE FROM Occupations
--WHERE NumSal = 0
--AND NumEpr = 0;

-- Pour gérer la concurence, on pose des véroux SHARE sur
-- les tables concerné (ils sont commenté).

-- En fesant cette question on a remarqué que l'on avait fait
-- une erreur sur la Trigger C4 du TP2. On la corrigé pour ce TP.

select * from occupations;
select * from Surveillances;

select * from Horaires;
DELETE FROM occupations
WHERE NumEpr = 0;
