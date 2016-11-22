--LOCK TABLE Horaires IN Share MODE;
Insert into Inscriptions
values
(0, 0);


LOCK TABLE Occupations IN Share MODE;
INSERT INTO Occupations VALUES
  (0, 1, 9);



--LOCK TABLE Surveillances IN Share MODE;
DELETE FROM Occupations
WHERE NumSal = 0
AND NumEpr = 0;

select * from occupations;


