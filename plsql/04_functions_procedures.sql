-- ----------------------------------------------------------------------
-- Cerinta 1: Sa se construiasca procedura p_majorare_pret_bilet care primeste ca parametri tipul de bilet si procentul de majorare. Procedura va actualiza pretul biletelor de tipul respectiv. Daca procentul introdus este mai mic sau egal cu 0, se va invoca o exceptie definita de utilizator. Daca nu exista niciun bilet de tipul introdus, se va trata corespunzator situatia. La final, se va afisa numarul de bilete actualizate.
set serveroutput on;
create or replace procedure p_majorare_pret_bilet( p_tip_bilet bilete.tip_bilet%type, p_procent   number)
is
    e_procent_invalid exception;
begin
    if p_procent <= 0 then
        raise e_procent_invalid;
    end if;
    update bilete
    set pret = pret + pret * p_procent / 100
    where lower(tip_bilet) = lower(p_tip_bilet);
    if sql%notfound then
        dbms_output.put_line('Nu exista niciun bilet de tipul ' || p_tip_bilet );
    else
        dbms_output.put_line('S-au actualizat ' || sql%rowcount || ' bilete de tipul ' || p_tip_bilet );
    end if;
exception
    when e_procent_invalid then
        dbms_output.put_line('Procentul de majorare trebuie sa fie mai mare decat 0');
    when others then
        dbms_output.put_line('A aparut o eroare: ' || sqlerrm);
end;
/
-- APEL:
begin
    p_majorare_pret_bilet('adult', 10);
    p_majorare_pret_bilet('adult', 0);
    p_majorare_pret_bilet('senior', 15);
end;
/

-- ----------------------------------------------------------------------
-- Cerinta 2: Sa se construiasca procedura p_afisare_animale_habitat care primeste ca parametru id-ul unui habitat si afiseaza toate animalele din habitatul respectiv, impreuna cu denumirea speciei. Daca habitatul introdus nu exista, se va trata corespunzator situatia. Daca habitatul exista, dar nu contine niciun animal, se va invoca o exceptie definita de utilizator.
set serveroutput on;
create or replace procedure p_afisare_animale_habitat(p_id_habitat habitate.id_habitat%type)
is
    v_exista number;
    e_fara_animale exception;
    cursor c_animale is
        select a.id_animal, s.denumire
        from animale a
        join specii s on a.id_specie = s.id_specie
        where a.id_habitat = p_id_habitat;
begin
    select count(*)
    into v_exista
    from habitate
    where id_habitat = p_id_habitat;
    if v_exista = 0 then
        dbms_output.put_line('Habitatul cu id-ul ' || p_id_habitat || ' nu exista.');
        return;
    end if;
    if not c_animale%isopen then
        open c_animale;
    end if;
    if c_animale%notfound is null then
        null;
    end if;
    declare
        v_id_animal animale.id_animal%type;
        v_denumire specii.denumire%type;
    begin
        fetch c_animale into v_id_animal, v_denumire;
        if c_animale%notfound then
            raise e_fara_animale;
        end if;
        loop
            dbms_output.put_line('Animalul cu id-ul ' || v_id_animal || ' apartine speciei ' || v_denumire );
            fetch c_animale into v_id_animal, v_denumire;
            exit when c_animale%notfound;
        end loop;
    exception
        when e_fara_animale then
            dbms_output.put_line('Habitatul cu id-ul ' || p_id_habitat || ' nu contine animale.');
    end;
    close c_animale;
exception
    when others then
        if c_animale%isopen then
            close c_animale;
        end if;
        dbms_output.put_line('A aparut o eroare: ' || sqlerrm);
end;
/
-- APEL:
begin
    p_afisare_animale_habitat(1);
    p_afisare_animale_habitat(20);
    p_afisare_animale_habitat(6);
end;
/

-- ----------------------------------------------------------------------
-- Cerinta 3: Sa se construiasca procedura p_asignare_ingrijitor care primeste ca parametri id-ul unui animal, id-ul unui ingrijitor si rolul acestuia si insereaza o noua asociere in tabela animale_ingrijitori. Daca animalul introdus nu exista, se va invoca o exceptie definita de utilizator. Daca ingrijitorul introdus nu exista, se va invoca o exceptie definita de utilizator. Daca asocierea dintre animal si ingrijitor exista deja, se va trata corespunzator situatia. La final, se va afisa un mesaj corespunzator operatiei efectuate.
set serveroutput on;
create or replace procedure p_asignare_ingrijitor(p_id_animal animale.id_animal%type, p_id_ingrijitor  ingrijitori.id_ingrijitor%type, p_rol animale_ingrijitori.rol%type)
is
    v_nr_animale number;
    v_nr_ingrijitori number;
    e_animal_inexistent exception;
    e_ingrijitor_inexistent exception;
begin
    select count(*) into v_nr_animale from animale where id_animal = p_id_animal;
    if v_nr_animale = 0 then
        raise e_animal_inexistent;
    end if;
    select count(*) into v_nr_ingrijitori from ingrijitori where id_ingrijitor = p_id_ingrijitor;
    if v_nr_ingrijitori = 0 then
        raise e_ingrijitor_inexistent;
    end if;
    insert into animale_ingrijitori
    values (p_id_animal, p_id_ingrijitor, sysdate, null, p_rol);
    dbms_output.put_line('Asocierea a fost adaugata cu succes.');
exception
    when e_animal_inexistent then
        dbms_output.put_line('Nu exista animalul cu id-ul ' || p_id_animal);
    when e_ingrijitor_inexistent then
        dbms_output.put_line('Nu exista ingrijitorul cu id-ul ' || p_id_ingrijitor);
    when dup_val_on_index then
        dbms_output.put_line('Asocierea dintre animalul ' || p_id_animal || ' si ingrijitorul ' || p_id_ingrijitor || ' exista deja.');
    when others then
        dbms_output.put_line('A aparut o eroare: ' || sqlerrm);
end;
/
-- APEL:
begin
    p_asignare_ingrijitor(1, 2, 'asistent');
    p_asignare_ingrijitor(50, 2, 'asistent');
    p_asignare_ingrijitor(1, 50, 'asistent');
    p_asignare_ingrijitor(1, 1, 'titular');
end;
/

-- ----------------------------------------------------------------------
-- Cerinta 4: Sa se construiasca functia f_numar_animale_habitat care primeste ca parametru id-ul unui habitat si returneaza numarul de animale aflate in habitatul respectiv. Daca habitatul introdus nu exista, se va trata corespunzator situatia.
set serveroutput on;
create or replace function f_numar_animale_habitat( p_id_habitat habitate.id_habitat%type )
return number
is
    v_nr_habitate number;
    v_nr_animale  number;
begin
    select count(*) into v_nr_habitate from habitate where id_habitat = p_id_habitat;
    if v_nr_habitate = 0 then
        raise_application_error(-20001, 'Nu exista habitatul cu id-ul ' || p_id_habitat || '.');
    end if;
    select count(*) into v_nr_animale from animale where id_habitat = p_id_habitat;
    return v_nr_animale;
exception
    when others then
        raise;
end;
/
-- APEL:
declare
    v_rezultat number;
begin
    v_rezultat := f_numar_animale_habitat(1);
    dbms_output.put_line('Numarul de animale din habitat este: ' || v_rezultat);
end;
/

-- ----------------------------------------------------------------------
-- Cerinta 5: Sa se construiasca functia f_incasari_tip_bilet care primeste ca parametru tipul de bilet si returneaza suma totala a incasarilor pentru acel tip de bilet. In cadrul functiei se vor lua in considerare toate biletele existente si se va calcula suma preturilor acestora. Daca nu exista bilete de tipul introdus, functia va returna valoarea 0 si va afisa un mesaj corespunzator.
set serveroutput on;
create or replace function f_incasari_tip_bilet(p_tip_bilet bilete.tip_bilet%type)
return number
is
    v_incasari number := 0;
    v_exista   number;
begin
    select count(*)
    into v_exista
    from bilete
    where lower(tip_bilet) = lower(p_tip_bilet);
    if v_exista = 0 then
        dbms_output.put_line('Nu exista bilete de tipul ' || p_tip_bilet);
        return 0;
    end if;
    select nvl(sum(pret),0)
    into v_incasari
    from bilete
    where lower(tip_bilet) = lower(p_tip_bilet);
    return v_incasari;
end;
/
-- APEL:
declare
    v_rezultat number;
begin
    v_rezultat := f_incasari_tip_bilet('adult');
    dbms_output.put_line('Incasarile pentru biletele de tip adult sunt: ' || v_rezultat);
end;
/
-- APEL:
declarev_rezultat number;beginv_rezultat := f_incasari_tip_bilet('senior');dbms_output.put_line('Incasarile sunt: ' || v_rezultat);end;/

Cerinta 6: Sa se construiasca functia f_salariu_mediu_habitat care primeste ca parametru id-ul unui habitat si returneaza salariul mediu al ingrijitorilor care au grija de animalele din habitatul respectiv. In cazul in care habitatul introdus nu exista, se va trata corespunzator situatia. In cazul in care in habitatul respectiv nu exista animale sau nu exista ingrijitori asociati animalelor din acel habitat, functia va returna valoarea 0.
set serveroutput on;
create or replace function f_salariu_mediu_habitat(p_id_habitat habitate.id_habitat%type)
return number
is
    v_nr_habitate number;
    v_salariu_mediu number;
begin
    select count(*)
    into v_nr_habitate
    from habitate
    where id_habitat = p_id_habitat;
    if v_nr_habitate = 0 then
        raise_application_error(-20002, 'Nu exista habitatul cu id-ul ' || p_id_habitat);
    end if;
    select nvl(avg(i.salariu), 0)
    into v_salariu_mediu
    from animale a
    join animale_ingrijitori ai on a.id_animal = ai.id_animal
    join ingrijitori i on ai.id_ingrijitor = i.id_ingrijitor
    where a.id_habitat = p_id_habitat;
    return round(v_salariu_mediu, 2);
exception
    when others then
        raise;
end;
/
-- APEL:
declare
    v_rezultat number;
begin
    begin
        v_rezultat := f_salariu_mediu_habitat(1);
        dbms_output.put_line('Caz valid: ' || v_rezultat);
    exception
        when others then
            dbms_output.put_line('Eroare la caz valid: ' || sqlerrm);
    end;
    begin
        v_rezultat := f_salariu_mediu_habitat(20);
        dbms_output.put_line('Caz invalid: ' || v_rezultat);
    exception
        when others then
            dbms_output.put_line('Eroare la caz invalid: ' || sqlerrm);
    end;
end;
/

-- ----------------------------------------------------------------------
-- Cerinta 7: Sa se construiasca functia f_total_cheltuit_vizitator care primeste ca parametru id-ul unui vizitator si returneaza suma totala cheltuita de acesta pe biletele cumparate. Daca vizitatorul introdus nu exista, se va trata corespunzator situatia.
set serveroutput on;
create or replace function f_total_cheltuit_vizitator(p_id_vizitator vizitatori.id_vizitator%type)
return number
is
    v_nr_vizitatori number;
    v_total number;
begin
    select count(*)
    into v_nr_vizitatori
    from vizitatori
    where id_vizitator = p_id_vizitator;
    if v_nr_vizitatori = 0 then
        raise_application_error(-20005, 'Nu exista vizitatorul cu id-ul ' || p_id_vizitator);
    end if;
    select nvl(sum(pret), 0)
    into v_total
    from bilete
    where id_vizitator = p_id_vizitator;
    return v_total;
end;
/
-- APEL:
declare
    v_total number;
begin
    v_total := f_total_cheltuit_vizitator(1);
    dbms_output.put_line('Total cheltuit de vizitator este: ' || v_total);
end;
/

-- ----------------------------------------------------------------------
-- Cerinta 8: Sa se construiasca procedura p_raport_cheltuieli_vizitator care primeste ca parametru id-ul unui vizitator si apeleaza functia f_total_cheltuit_vizitator, realizata anterior. Procedura va calcula si afisa: numarul total de bilete cumparate de visitator,suma totala cheltuita, valoarea medie cheltuita pe bilet
-- In functie de suma totala cheltuita, procedura va afisa unul dintre urmatoarele mesaje:
-- "Vizitator cu cheltuieli reduse", daca suma este sub 50
-- "Vizitator cu cheltuieli medii", daca suma este intre 50 si 100
-- "Vizitator cu cheltuieli ridicate", daca suma este peste 100
-- Daca vizitatorul nu are niciun bilet cumparat, se va afisa un mesaj corespunzator.
set serveroutput on;
create or replace procedure p_raport_cheltuieli_vizitator(p_id_vizitator vizitatori.id_vizitator%type)
is
    v_total_cheltuit number;
    v_nr_bilete number;
    v_medie number;
begin
    v_total_cheltuit := f_total_cheltuit_vizitator(p_id_vizitator);
    select count(*) into v_nr_bilete from bilete where id_vizitator = p_id_vizitator;
    if v_nr_bilete = 0 then
        dbms_output.put_line('Vizitatorul cu id-ul ' || p_id_vizitator || ' nu a cumparat niciun bilet.');
    else
        v_medie := v_total_cheltuit / v_nr_bilete;
        dbms_output.put_line('Vizitatorul cu id-ul ' || p_id_vizitator || ' a cumparat ' || v_nr_bilete || ' bilete.');
        dbms_output.put_line('Suma totala cheltuita este: ' || v_total_cheltuit || ' lei.');
        dbms_output.put_line('Valoarea medie pe bilet este: ' || round(v_medie, 2) || ' lei.');
        if v_total_cheltuit < 50 then
            dbms_output.put_line('Vizitator cu cheltuieli reduse.');
        elsif v_total_cheltuit between 50 and 100 then
            dbms_output.put_line('Vizitator cu cheltuieli medii.');
        else
            dbms_output.put_line('Vizitator cu cheltuieli ridicate.');
        end if;
    end if;
exception
    when others then
        dbms_output.put_line('A aparut o eroare: ' || sqlerrm);
end;
/
-- APEL:
begin
    p_raport_cheltuieli_vizitator(1);
    p_raport_cheltuieli_vizitator(20);
    p_raport_cheltuieli_vizitator(11);
end;
/
