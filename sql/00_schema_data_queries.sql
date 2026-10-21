-- Am folosit comada CREATE pentru crearea tabelelor din baza mea de date. Apoi am utilizat comanda ALTER pentru a adauga restrictiile de integritate(cheie primara si cheile externe), si comanda DROP pentrua sterge coloane.
-- Tabela HABITATE
CREATE TABLE habitate (
  id_habitat NUMBER,
  nume VARCHAR2(100),
  tip VARCHAR2(50),
  suprafata NUMBER(10,2),
  temperatura_medie NUMBER(5,2)
);
ALTER TABLE habitate ADD CONSTRAINT pk_habitate PRIMARY KEY (id_habitat);

-- ----------------------------------------------------------------------
-- Cerinta: Sa se adauge o restrictive astfel incat campurile “nume” si “tip” sa nu poata fi nul.
ALTER TABLE habitate MODIFY (nume NOT NULL);
ALTER TABLE habitate MODIFY (tip NOT NULL);
-- Tabela SPECII
CREATE TABLE specii (
id_specie NUMBER,
denumire VARCHAR2(80) NOT NULL,
clasa VARCHAR2(80),
zona_origine VARCHAR2(50),
protejata CHAR(1) NOT NULL   );
ALTER TABLE specii ADD CONSTRAINT pk_specii PRIMARY KEY (id_specie);
-- Tabela INGRIJITORI
CREATE TABLE ingrijitori (
  id_ingrijitor NUMBER,
  nume VARCHAR2(80) NOT NULL,
  prenume VARCHAR2(80) NOT NULL,
  telefon VARCHAR2(20) NOT NULL,
  data_angajare DATE,
  salariu NUMBER(10,2)
);
ALTER TABLE ingrijitori ADD CONSTRAINT pk_ingrijitori PRIMARY KEY (id_ingrijitor);
ALTER TABLE ingrijitori ADD CONSTRAINT uq_ingrijitori_telefon UNIQUE (telefon);

-- ----------------------------------------------------------------------
-- Cerinta: Sa se adauge o noua coloana in tabela INGRIJITORI iar apoi sa fie stearsa:
ALTER TABLE ingrijitori ADD observatii VARCHAR2(200);
ALTER TABLE ingrijitori DROP COLUMN observatii;
-- Tabela VIZITATORI
CREATE TABLE vizitatori (
  id_vizitator  NUMBER,
  nume VARCHAR2(80) NOT NULL,
  prenume VARCHAR2(80) NOT NULL,
  email VARCHAR2(120) NOT NULL,
  data_nasterii DATE,
  newsletter CHAR(1)
);
ALTER TABLE vizitatori ADD CONSTRAINT pk_vizitatori PRIMARY KEY (id_vizitator);
ALTER TABLE vizitatori ADD CONSTRAINT uq_vizitatori_email UNIQUE (email);
ALTER TABLE vizitatori DROP COLUMN newsletter;
-- Tabela ANIMALE
CREATE TABLE animale (
id_animal NUMBER,
data_nasterii DATE,
sex CHAR(1) NOT NULL,
id_habitat NUMBER,
id_specie NUMBER );
ALTER TABLE animale ADD CONSTRAINT pk_animale PRIMARY KEY (id_animal);
ALTER TABLE animale ADD CONSTRAINT fk_animale_habitate FOREIGN KEY (id_habitat) REFERENCES habitate(id_habitat);
ALTER TABLE animale ADD CONSTRAINT fk_animale_specii FOREIGN KEY (id_specie) REFERENCES specii(id_specie);

-- ----------------------------------------------------------------------
-- Cerinta: Sa se adauge o restrictive de tip CHECK asupra uneia dintre coloanele din tabela ANIMALE, apoi sa se staerga aceasta restrictive
 ALTER TABLE animale ADD CONSTRAINT ck_animale_sex CHECK (sex IN ('M','F','U'));
ALTER TABLE animale DROP CONSTRAINT ck_animale_sex;
-- Tabela BILETE
CREATE TABLE bilete (
  id_bilet NUMBER,
  tip_bilet VARCHAR2(30) NOT NULL,
  pret NUMBER(10,2),
  data_emitere DATE,
  id_vizitator NUMBER );
ALTER TABLE bilete ADD CONSTRAINT pk_bilete PRIMARY KEY (id_bilet);
ALTER TABLE bilete ADD CONSTRAINT fk_bilete_vizitatori FOREIGN KEY (id_vizitator) REFERENCES vizitatori(id_vizitator);

-- ----------------------------------------------------------------------
-- Cerinta: Sa se modifice tipul de date al coloanei “tip_bilet” din tabela BILETE
ALTER TABLE bilete MODIFY (tip_bilet VARCHAR2(50));
-- Tabela ANIMALE_INGRIJITORI
CREATE TABLE animale_ingrijitori (
  id_animal NUMBER,
  id_ingrijitor NUMBER,
  data_start DATE,
  data_final DATE,
  rol VARCHAR2(30)
);
ALTER TABLE animale_ingrijitori ADD CONSTRAINT pk_animale_ingrijitori PRIMARY KEY (id_animal, id_ingrijitor);
ALTER TABLE animale_ingrijitori ADD CONSTRAINT fk_ai_animale FOREIGN KEY (id_animal) REFERENCES animale(id_animal);
ALTER TABLE animale_ingrijitori ADD CONSTRAINT fk_ai_ingrijitori FOREIGN KEY (id_ingrijitor) REFERENCES ingrijitori(id_ingrijitor);
-- Adaugarea de inregistrari in fiecare tabela:
-- Tabela HABITATE
INSERT INTO habitate VALUES (1,'Savana','exterior',1500,28);
INSERT INTO habitate VALUES (2,'Padure tropicala','exterior',1200,26);
INSERT INTO habitate VALUES (3,'Desert','exterior',900,40);
INSERT INTO habitate VALUES (4,'Acvariu','interior',600,18);
INSERT INTO habitate VALUES (5,'Zona arctica','interior',500,-5);
INSERT INTO habitate VALUES (6,'Ferma','exterior',800,20);
INSERT INTO habitate VALUES (7,'Reptilariu','interior',400,30);
INSERT INTO habitate VALUES (8,'Voliera','exterior',700,22);
INSERT INTO habitate VALUES (9,'Nocturn','interior',300,19);
INSERT INTO habitate VALUES (10,'Lac artificial','exterior',1000,15);
-- Tabela SPECII
INSERT INTO specii VALUES (1,'Leu','Mamifer','Africa','Y');
INSERT INTO specii VALUES (2,'Tigru','Mamifer','Asia','Y');
INSERT INTO specii VALUES (3,'Elefant','Mamifer','Africa','Y');
INSERT INTO specii VALUES (4,'Crocodil','Reptila','Africa','N');
INSERT INTO specii VALUES (5,'Pinguin','Pasare','Antarctica','Y');
INSERT INTO specii VALUES (6,'Sarpe','Reptila','Asia','N');
INSERT INTO specii VALUES (7,'Urs','Mamifer','Europa','Y');
INSERT INTO specii VALUES (8,'Girafa','Mamifer','Africa','N');
INSERT INTO specii VALUES (9,'Vultur','Pasare','Europa','N');
INSERT INTO specii VALUES (10,'Delfin','Mamifer','Ocean','Y');
-- Tabela INGRIJITORI
INSERT INTO ingrijitori VALUES (1,'Popescu','Ion','0711111111',DATE '2020-01-10',4000);
INSERT INTO ingrijitori VALUES (2,'Ionescu','Maria','0722222222',DATE '2019-03-15',4200);
INSERT INTO ingrijitori VALUES (3,'Georgescu','Andrei','0733333333',DATE '2021-06-01',3800);
INSERT INTO ingrijitori VALUES (4,'Dumitru','Elena','0744444444',DATE '2018-11-20',4500);
INSERT INTO ingrijitori VALUES (5,'Stan','Mihai','0755555555',DATE '2022-02-14',3600);
INSERT INTO ingrijitori VALUES (6,'Radu','Ana','0766666666',DATE '2017-07-07',4800);
INSERT INTO ingrijitori VALUES (7,'Marin','Paul','0777777777',DATE '2019-09-09',4100);
INSERT INTO ingrijitori VALUES (8,'Ilie','Cristina','0788888888',DATE '2020-12-01',3950);
INSERT INTO ingrijitori VALUES (9,'Petrescu','Alex','0799999999',DATE '2016-05-30',5000);
INSERT INTO ingrijitori VALUES (10,'Vasile','Ioana','0700000000',DATE '2023-01-10',3500);
-- Tabela VIZITATORI
INSERT INTO vizitatori VALUES (1,'Pop','Ana','ana.pop@gmail.com',DATE '1998-04-12');
INSERT INTO vizitatori VALUES (2,'Ionescu','Dan','dan.ionescu@yahoo.com',DATE '1990-07-22');
INSERT INTO vizitatori VALUES (3,'Marcu','Elena','elena.marcu@gmail.com',DATE '2001-01-15');
INSERT INTO vizitatori VALUES (4,'Stan','Paul','paul.stan@gmail.com',DATE '1985-09-30');
INSERT INTO vizitatori VALUES (5,'Luca','Andreea','andreea.luca@gmail.com',DATE '1999-11-05');
INSERT INTO vizitatori VALUES (6,'Toma','Vlad','vlad.toma@gmail.com',DATE '2003-03-18');
INSERT INTO vizitatori VALUES (7,'Rusu','Ioana','ioana.rusu@yahoo.com',DATE '1995-06-27');
INSERT INTO vizitatori VALUES (8,'Matei','George','george.matei@gmail.com',DATE '1988-02-14');
INSERT INTO vizitatori VALUES (9,'Barbu','Mara','mara.barbu@gmail.com',DATE '2000-08-08');
INSERT INTO vizitatori VALUES (10,'Dobre','Alexandru','alex.dobre@gmail.com',DATE '1992-12-01');
-- Tabela ANIMALE
INSERT INTO animale VALUES (1,DATE '2018-05-10','M',1,1);
INSERT INTO animale VALUES (2,DATE '2017-03-22','F',1,2);
INSERT INTO animale VALUES (3,DATE '2015-11-01','M',2,3);
INSERT INTO animale VALUES (4,DATE '2019-07-14','F',3,4);
INSERT INTO animale VALUES (5,DATE '2020-02-02','M',5,5);
INSERT INTO animale VALUES (6,DATE '2016-06-06','F',7,6);
INSERT INTO animale VALUES (7,DATE '2014-09-09','M',2,7);
INSERT INTO animale VALUES (8,DATE '2018-12-12','F',1,8);
INSERT INTO animale VALUES (9,DATE '2013-04-18','M',8,9);
INSERT INTO animale VALUES (10,DATE '2021-01-25','F',10,10);
-- Tabela BILETE
INSERT INTO bilete VALUES (1,'adult',40,DATE '2024-05-01',1);
INSERT INTO bilete VALUES (2,'copil',20,DATE '2024-05-01',2);
INSERT INTO bilete VALUES (3,'adult',40,DATE '2024-05-02',3);
INSERT INTO bilete VALUES (4,'student',25,DATE '2024-05-02',4);
INSERT INTO bilete VALUES (5,'adult',40,DATE '2024-05-03',5);
INSERT INTO bilete VALUES (6,'copil',20,DATE '2024-05-03',6);
INSERT INTO bilete VALUES (7,'adult',40,DATE '2024-05-04',7);
INSERT INTO bilete VALUES (8,'student',25,DATE '2024-05-04',8);
INSERT INTO bilete VALUES (9,'adult',40,DATE '2024-05-05',9);
INSERT INTO bilete VALUES (10,'adult',40,DATE '2024-05-05',10);
-- Tabela ANIMALE_INGRIJITORI
INSERT INTO animale_ingrijitori VALUES (1,1,DATE '2020-01-01',NULL,'titular');
INSERT INTO animale_ingrijitori VALUES (2,2,DATE '2019-05-01',NULL,'titular');
INSERT INTO animale_ingrijitori VALUES (3,3,DATE '2021-06-01',NULL,'titular');
INSERT INTO animale_ingrijitori VALUES (4,4,DATE '2018-11-20',NULL,'titular');
INSERT INTO animale_ingrijitori VALUES (5,5,DATE '2022-02-14',NULL,'asistent');
INSERT INTO animale_ingrijitori VALUES (6,6,DATE '2017-07-07',NULL,'titular');
INSERT INTO animale_ingrijitori VALUES (7,7,DATE '2019-09-09',NULL,'titular');
INSERT INTO animale_ingrijitori VALUES (8,8,DATE '2020-12-01',NULL,'asistent');
INSERT INTO animale_ingrijitori VALUES (9,9,DATE '2016-05-30',NULL,'titular');
INSERT INTO animale_ingrijitori VALUES (10,10,DATE '2023-01-10',NULL,'voluntar');
-- Actualizarea inregistrarilor:

-- ----------------------------------------------------------------------
-- Cerinta: Modificați tabela INGRIJITORI astfel încât numele și prenumele tuturor îngrijitorilor să fie scrise doar cu majuscule.
UPDATE ingrijitori
SET nume = UPPER(nume);
UPDATE ingrijitori
SET prenume = UPPER(prenume);

-- ----------------------------------------------------------------------
-- Cerinta: Să se modifice prenumele îngrijitorilor angajați înainte de anul 2019, înlocuindu-l cu valoarea ANONIM
UPDATE ingrijitori
SET prenume = 'ANONIM'
WHERE data_angajare < DATE '2019-01-01';

-- ----------------------------------------------------------------------
-- Cerinta: Să se mărească cu 20% prețul tuturor biletelor de tip adult.
UPDATE bilete
SET pret = pret * 1.2
WHERE tip_bilet = 'adult';

-- ----------------------------------------------------------------------
-- Cerinta: Să se completeze data_final pentru animalul cu id_animal = 1, îngrijit de îngrijitorul cu id_ingrijitor = 1.
UPDATE animale_ingrijitori
SET data_final = DATE '2024-06-30'
WHERE id_animal = 1 AND id_ingrijitor = 1;

-- ----------------------------------------------------------------------
-- Cerinta: Să se ajusteze temperatura medie a tuturor habitatelor de tip interior la 22°C.
UPDATE habitate
SET temperatura_medie = 22
WHERE tip = 'interior';
-- Stergerea si recuperarea unei tabele:
DROP TABLE animale_ingrijitori;
FLASHBACK TABLE animale_ingrijitori TO BEFORE DROP;
-- Exemple de interogari:

-- ----------------------------------------------------------------------
-- Cerinta 1: Să se afișeze animalele născute după 2018
SELECT id_animal, data_nasterii
FROM animale
WHERE data_nasterii > DATE '2018-01-01';

-- ----------------------------------------------------------------------
-- Cerinta 2: Să se afișeze numele și prenumele îngrijitorilor care se ocupă de animale având rolul „asistent”.
SELECT i.nume, i.prenume
FROM ingrijitori i
INNER JOIN animale_ingrijitori ai ON i.id_ingrijitor = ai.id_ingrijitor
WHERE ai.rol = 'asistent';

-- ----------------------------------------------------------------------
-- Cerinta 3: Să se afișeze toate biletele și numele vizitatorilor care le-au cumpărat, dacă există.”
SELECT v.nume, v.prenume, b.tip_bilet, b.data_emitere
FROM vizitatori v
RIGHT JOIN bilete b ON v.id_vizitator = b.id_vizitator;

-- ----------------------------------------------------------------------
-- Cerinta 4: Să se afișeze animalele îngrijite de îngrijitori cu salariul mai mare de 4000.
SELECT a.id_animal, i.nume, i.prenume
FROM animale a, animale_ingrijitori ai, ingrijitori i
WHERE a.id_animal = ai.id_animal AND ai.id_ingrijitor = i.id_ingrijitor AND i.salariu > 4000;
-- Funcții single-row (LOWER/UPPER/INITCAP, LENGTH, CONCAT, date)

-- ----------------------------------------------------------------------
-- Cerinta 5: Să se afișeze toți îngrijitorii care nu au prenumele „ANONIM” și au salariul mai mic de 4000.
SELECT nume, prenume, salariu
FROM ingrijitori
WHERE UPPER(prenume) <> 'ANONIM' AND salariu < 4000;

-- ----------------------------------------------------------------------
-- Cerinta 6: Să se afișeze vizitatorii care au email de tip gmail
SELECT nume, prenume, email
FROM vizitatori
WHERE LOWER(email) LIKE '%gmail%';

-- ----------------------------------------------------------------------
-- Cerinta 7: Să se afișeze un text concatenat pentru fiecare bilet.
SELECT 'Biletul ' || id_bilet || ' este de tip ' || INITCAP(tip_bilet) AS descriere
FROM bilete;

-- ----------------------------------------------------------------------
-- Cerinta 8: Să se afișeze numele și prenumele vizitatorilor astfel încât numele să fie afișat cu majuscule, iar prenumele să fie afișat cu prima literă mare, doar pentru vizitatorii care au adresa de email scrisă cu litere mici.
SELECT UPPER(nume) AS nume, INITCAP(prenume) AS prenume, email
FROM vizitatori
WHERE LOWER(email) = email;

-- ----------------------------------------------------------------------
-- Cerinta 9: Afisati data curenta din tabela DUAL.
SELECT SYSDATE
FROM dual;

-- ----------------------------------------------------------------------
-- Cerinta 10: Să se afișeze prețul mediu al biletelor pentru fiecare tip de bilet, rotunjit la 2 zecimale, ordonat crescator.
SELECT tip_bilet, ROUND(AVG(pret), 2) AS pret_mediu
FROM bilete
GROUP BY tip_bilet
ORDER BY pret_mediu ASC;

-- ----------------------------------------------------------------------
-- Cerinta 11: Să se afișeze salariul minim, maxim și salariul mediu (rotunjit la 2 zecimale)
SELECT MAX(salariu) salariu_maxim, MIN(salariu) salariu_minim, TRUNC(AVG(salariu),2) salariu_mediu
FROM ingrijitori;

-- ----------------------------------------------------------------------
-- Cerinta 12: Să se afișeze numărul de îngrijitori cu salariul mai mare de 3500.
SELECT COUNT(*) nr_ingrijitori
FROM ingrijitori
WHERE salariu > 3500;

-- ----------------------------------------------------------------------
-- Cerinta 13: Să se afișeze numărul de animale pe habitat.
SELECT id_habitat, COUNT(*) nr_animale
FROM animale
GROUP BY id_habitat;

-- ----------------------------------------------------------------------
-- Cerinta 14: Să se afișeze habitatele care au mai mult de 1 animal.
SELECT id_habitat, COUNT(*) nr_animale
FROM animale
GROUP BY id_habitat
HAVING COUNT(*) > 1;

-- ----------------------------------------------------------------------
-- Cerinta 15: Să se afișeze suma încasărilor pe tip de bilet, ordonată descrescător după încasări.
SELECT b.tip_bilet, SUM(b.pret) incasari
FROM bilete b
GROUP BY b.tip_bilet
ORDER BY incasari DESC;

-- ----------------------------------------------------------------------
-- Cerinta 16: Să se afișeze habitatele care au cel puțin 2 animale și temperatura medie > 20.
SELECT h.id_habitat, h.nume, COUNT(a.id_animal) nr_animale
FROM habitate h, animale a
WHERE h.id_habitat = a.id_habitat AND h.temperatura_medie > 20
GROUP BY h.id_habitat, h.nume
HAVING COUNT(a.id_animal) >= 2;
-- Cereri imbricate:

-- ----------------------------------------------------------------------
-- Cerinta 17: Să se afișeze animalele din habitate de tip „interior”.
SELECT * FROM animale
WHERE id_habitat IN (
SELECT id_habitat FROM habitate
WHERE tip='interior'
);
-- Case , Decode

-- ----------------------------------------------------------------------
-- Cerinta 18: Să se afișeze sexul animalelor în format text.
SELECT id_animal, DECODE(sex,'M','Mascul','F','Femela','Necunoscut') sex_descriere
FROM animale;

-- ----------------------------------------------------------------------
-- Cerinta 19: Să se afișeze categoria salariului pentru fiecare îngrijitor.
SELECT nume, prenume, salariu,
CASE
WHEN salariu < 4000 THEN 'MIC'
WHEN salariu BETWEEN 4000 AND 5000 THEN 'MEDIU'
ELSE 'MARE'
END categorie
FROM ingrijitori;
-- Operatori pe mulțimi: UNION / INTERSECT / MINUS

-- ----------------------------------------------------------------------
-- Cerinta 20: Să se afișeze îngrijitorii care îngrijesc animale, dar nu au niciodată rolul „titular”.
SELECT ai.id_ingrijitor FROM animale_ingrijitori ai
MINUS
SELECT ai.id_ingrijitor FROM animale_ingrijitori ai
WHERE ai.rol = 'titular';

-- ----------------------------------------------------------------------
-- Cerinta 21: Să se afișeze toate numele (nume, prenume) din îngrijitori și vizitatori.
SELECT nume, prenume FROM ingrijitori
UNION
SELECT nume, prenume FROM vizitatori;

-- ----------------------------------------------------------------------
-- Cerinta 22: Să se afișeze habitatele care există în tabela HABITATE și sunt folosite de cel puțin un animal.
SELECT id_habitat FROM habitate
INTERSECT
SELECT id_habitat FROM animale;
-- Structuri ierarhice: Am utilizat tabela DUAL deoarece schema bazei de date nu conține o relație ierarhică natural. Astfel, prin interogarea CONNECT BY aplicată pe DUAL, am putut demonstra funcționarea structurilor ierarhice fără a modifica structura bazei de date.

-- ----------------------------------------------------------------------
-- Cerinta 23: Să se afișeze o structură ierarhică folosind o interogare CONNECT BY.
SELECT LEVEL nivel
FROM dual
CONNECT BY LEVEL <= 10;
-- TO_CHAR, TO_DATE

-- ----------------------------------------------------------------------
-- Cerinta 24: Să se afișeze numărul de bilete emise în fiecare zi, ordonate descrescător după număr.
SELECT TO_CHAR(data_emitere,'YYYY-MM-DD') zi, COUNT(*) nr_bilete
FROM bilete
GROUP BY TO_CHAR(data_emitere,'YYYY-MM-DD')
ORDER BY nr_bilete DESC;

-- ----------------------------------------------------------------------
-- Cerinta 25: Să se afișeze biletele emise după 01/01/2021 (dată scrisă ca text).
SELECT * FROM bilete
WHERE data_emitere > TO_DATE('2021-01-01','YYYY-MM-DD');
-- Vederi, indecsi, sinonime, secvente:

-- ----------------------------------------------------------------------
-- Cerinta 1: Să se creeze o vedere care să conțină numele, prenumele și salariul îngrijitorilor care au salariul mai mare de 3700. Să se afișeze ulterior conținutul vederii create.
CREATE OR REPLACE VIEW v_ingrijitori_salariu_mare as
SELECT i.nume, i.prenume, i.salariu
FROM ingrijitori i
WHERE i.salariu > 3700;

-- ----------------------------------------------------------------------
-- Cerinta 2: Să se creeze un index pe coloana NUME din tabelul INGRIJITORI, pentru a accelera căutările după nume.
CREATE INDEX idx_ingrijitori_nume ON ingrijitori(nume);

-- ----------------------------------------------------------------------
-- Cerinta 3: Sa se stearga indexul creat anterior.
DROP INDEX idx_ingrijitori_nume;

-- ----------------------------------------------------------------------
-- Cerinta 4: Să se creeze un sinonim pentru tabela INGRIJITORI pentru a facilita accesul la aceasta. (Sinonimul permite accesarea tabelei sub un nume alternativ)
CREATE SYNONYM s_ingrijitori FOR INGRIJITORI;

-- ----------------------------------------------------------------------
-- Cerinta 5: Să se șteargă sinonimul creat anterior.
DROP SYNONYM s_ingrijitori;

-- ----------------------------------------------------------------------
-- Cerinta 6: Să se creeze o secvență pentru generarea automată a cheii primare ID_INGRIJITOR, cu valoare minimă 1 și valoare maximă 52.
CREATE SEQUENCE seq_ingrijitor
START WITH 1
INCREMENT BY 1
MAXVALUE 52
NOCYCLE;

-- ----------------------------------------------------------------------
-- Cerinta 7: Să se modifice secvența astfel încât valoarea maximă să fie 70.
ALTER SEQUENCE seq_ingrijitor
MAXVALUE 70;

-- ----------------------------------------------------------------------
-- Cerinta 8: Să se șteargă secvența creată anterior.
DROP SEQUENCE seq_ingrijitor;

-- ----------------------------------------------------------------------
-- Cerinta 9: Să se creeze o secvență de test. Să se obțină următoarea valoare folosind NEXTVAL, apoi să se afișeze valoarea curentă folosind CURRVAL. La final, să se șteargă secvența.
CREATE SEQUENCE seq_test_next_curr
START WITH 100000
INCREMENT BY 1
NOCYCLE;
SELECT seq_test_next_curr.NEXTVAL AS next_value
FROM dual;
SELECT seq_test_next_curr.CURRVAL AS curr_value
FROM dual;
SELECT seq_test_next_curr.NEXTVAL AS next_value_2,
       seq_test_next_curr.CURRVAL AS curr_value_2
FROM dual;
DROP SEQUENCE seq_test_next_curr;
