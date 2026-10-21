-- ----------------------------------------------------------------------
-- Cerinta 1: Sa se realizeze un bloc PL/SQL care primeste de la tastatura id-ul unui habitat din gradina zoologica. Se cere sa se verifice daca acest habitat exista. Daca nu, atunci se va afisa un mesaj corespunzator. Altfel, se va afisa numele habitatului, tipul acestuia si temperatura medie. Se va determine numarul de animale care traiesc in habitatul respectiv, iar in fuctie de acesta se va clasifica habitatul astfel:
-- Daca numarul de animale este 0 – habitat gol;
-- Daca numarul de animale este intre 1 si 2 – habitat putin populat;
-- Daca numarul de animale este intre 3 si 5 – habitat populat;
-- Daca numarul de animale este mai mare decat 5 – habitat foarte populat;
-- Daca habitatul contine animale, sa se parcurga si sa se afiseze pentru fiecare id-ul, specia si sexul acestuia.
set serveroutput on
accept p_id_habitat prompt 'Introduceti id-ul habitatului: '
declare
    v_id_habitat habitate.id_habitat%type := &p_id_habitat;
    v_nr_habitate number;
    v_nume habitate.nume%type;
    v_tip habitate.tip%type;
    v_temperatura habitate.temperatura_medie%type;
    v_nr_animale number;
begin
    select count(*)
    into v_nr_habitate
    from habitate
    where id_habitat = v_id_habitat;
    if v_nr_habitate = 0 then
        dbms_output.put_line('Habitatul nu exista.');
    else
        select nume, tip, temperatura_medie
        into v_nume, v_tip, v_temperatura
        from habitate
        where id_habitat = v_id_habitat;
        dbms_output.put_line('Nume habitat: ' || v_nume);
        dbms_output.put_line('Tip habitat: ' || v_tip);
        dbms_output.put_line('Temperatura medie: ' || v_temperatura);
        select count(*)  into v_nr_animale  from animale where id_habitat = v_id_habitat;
        dbms_output.put_line('Numar animale: ' || v_nr_animale);
        case
            when v_nr_animale = 0 then
                dbms_output.put_line('Habitat gol');
            when v_nr_animale between 1 and 2 then
                dbms_output.put_line('Habitat putin populat');
            when v_nr_animale between 3 and 5 then
                dbms_output.put_line('Habitat populat');
            else
                dbms_output.put_line('Habitat foarte populat');
        end case;
        if v_nr_animale > 0 then
            dbms_output.put_line('Animalele din habitat sunt:');
for a in (
                select a.id_animal, s.denumire, a.sex
                from animale a
                join specii s on a.id_specie = s.id_specie
                where a.id_habitat = v_id_habitat
                order by a.id_animal
            ) loop
                dbms_output.put_line('Animal id: ' || a.id_animal || ', specie: ' || a.denumire || ', sex: ' || a.sex);
            end loop;
        end if;
    end if;
end;
/

-- ----------------------------------------------------------------------
-- Cerinta 2: Sa se scrie un bloc PL/SQL care primeste de la tastatura id-ul unui ingrijitor. Sa se verifice daca acesta exista sau nu. Daca nu, sa se afiseze un mesaj, altfel sa se afiseze numele, prenumele, salariul si vechimea in ani. In functie de vechime, se va stabili un prag maxim pentru un bonus:
-- sub 3 ani – 300 lei
-- intre 3 si 5 ani – 500 lei
-- peste 5 ani – 800 lei
-- Acest bonus va fi construit treptat, adaugand cate 100 lei la fiecare pas, pana se va ajunge la pragul stabilit. Salariul va fi actualizat si afisat.
set serveroutput on
accept p_id_ingrijitor prompt 'introduceti id-ul ingrijitorului: '
declare
    v_id_ingrijitor ingrijitori.id_ingrijitor%type := &p_id_ingrijitor;
    v_nr number;
    v_nume ingrijitori.nume%type;
    v_prenume ingrijitori.prenume%type;
    v_salariu ingrijitori.salariu%type;
    v_data_angajare ingrijitori.data_angajare%type;
    v_vechime number;
    v_prag_bonus number;
    v_bonus number := 0;
    v_salariu_nou ingrijitori.salariu%type;
begin
    select count(*)
    into v_nr
    from ingrijitori
    where id_ingrijitor = v_id_ingrijitor;
    if v_nr = 0 then
        dbms_output.put_line('Ingrijitorul nu exista.');
    else
        select nume, prenume, salariu, data_angajare
        into v_nume, v_prenume, v_salariu, v_data_angajare
        from ingrijitori
        where id_ingrijitor = v_id_ingrijitor;
        v_vechime := trunc(months_between(sysdate, v_data_angajare) / 12);
        dbms_output.put_line('Ingrijitor: ' || v_nume || ' ' || v_prenume);
        dbms_output.put_line('Salariu curent: ' || v_salariu);
        dbms_output.put_line('Vechime: ' || v_vechime || ' ani');
        if v_vechime < 3 then
            v_prag_bonus := 300;
        elsif v_vechime between 3 and 5 then
            v_prag_bonus := 500;
        else
            v_prag_bonus := 800;
        end if;
        loop
            v_bonus := v_bonus + 100;
            exit when v_bonus >= v_prag_bonus;
        end loop;
        dbms_output.put_line('Bonus acordat: ' || v_bonus);
        update ingrijitori
        set salariu = salariu + v_bonus
        where id_ingrijitor = v_id_ingrijitor;
        commit;
        select salariu
        into v_salariu_nou
        from ingrijitori
        where id_ingrijitor = v_id_ingrijitor;
        dbms_output.put_line('Salariu nou: ' || v_salariu_nou);
    end if;
end;
/

-- ----------------------------------------------------------------------
-- Cerinta 3: Sa se realizeze un bloc PL/SQL care primeste de la tastatura id-ul unui ingrijitor. Se va verifica daca acesta exista. Daca nu exista, se va afisa un mesaj, altfel se va afisa numele, prenumele si salariul acestuia. Se va determina numarul de animale de care se ocupa ingrijitorul folosind tabela ANIMALE_INGRIJITORI. Se parcurg acestea si se afiseaza id-ul si specia animalului ce se afla in grija lui. La final, sa se stabileasca daca ingrijitorul are un numar mare de responsabilitati(daca are grija de mai mult de 3 animale).
set serveroutput on
accept p_id_ingrijitor prompt 'introduceti id-ul ingrijitorului: '
declare
    v_id_ingrijitor ingrijitori.id_ingrijitor%type := &p_id_ingrijitor;
    v_nr number;
    v_nume ingrijitori.nume%type;
    v_prenume ingrijitori.prenume%type;
    v_salariu ingrijitori.salariu%type;
    v_nr_animale number;
    v_i number := 1;
    v_id_animal animale.id_animal%type;
    v_specie specii.denumire%type;
begin
    select count(*) into v_nr  from ingrijitori where id_ingrijitor = v_id_ingrijitor;
    if v_nr = 0 then
        dbms_output.put_line('Ingrijitorul nu exista.');
    else
        select nume, prenume, salariu
        into v_nume, v_prenume, v_salariu
        from ingrijitori
        where id_ingrijitor = v_id_ingrijitor;
        dbms_output.put_line('Ingrijitor: ' || v_nume || ' ' || v_prenume);
        dbms_output.put_line('Salariu: ' || v_salariu);
        select count(*) into v_nr_animale from animale_ingrijitori where id_ingrijitor = v_id_ingrijitor;
        dbms_output.put_line('Numar animale in grija: ' || v_nr_animale);
        while v_i <= v_nr_animale loop
            select id_animal, denumire
            into v_id_animal, v_specie
            from (
                select ai.id_animal, s.denumire, rownum rn
                from animale_ingrijitori ai
                join animale a on ai.id_animal = a.id_animal
                join specii s on a.id_specie = s.id_specie
                where ai.id_ingrijitor = v_id_ingrijitor )
            where rn = v_i;
            dbms_output.put_line( 'Se verifica animalul numarul ' || v_i || ' cu id-ul ' || v_id_animal || ' din specia ' || v_specie );
            v_i := v_i + 1;
        end loop;
        if v_nr_animale > 3 then
            dbms_output.put_line('Ingrijitorul are un numar mare de responsabilitati.');
        else
            dbms_output.put_line('Ingrijitorul are un numar normal de responsabilitati.');
        end if;
    end if;
end;
/

-- ----------------------------------------------------------------------
-- Cerinta 4: Sa se realizeze un bloc PL/SQL care primeste de la tastatura id-ul unui vizitator. Se va verifica daca acesta exista. Daca nu, se va afisa un mesaj, altfel se va afisa numele si prenumele acestuia. Sa se determine numarul de bilete cumparate si sa se afiseze. Sa se calculeze suma totala platita de vizitator. La final sa se simuleze acordarea unor puncte de fidelitate pentru achizitie, adaugand cate 10 puncte pana cand numarul de puncte depaseste valoarea totala platita de vizitator.
set serveroutput on
accept p_id_vizitator prompt 'Introduceti id-ul vizitatorului: '
declare
    v_id_vizitator vizitatori.id_vizitator%type := &p_id_vizitator;
    v_nr number;
    v_nume vizitatori.nume%type;
    v_prenume vizitatori.prenume%type;
    v_nr_bilete number;
    v_id_bilet bilete.id_bilet%type;
    v_tip_bilet bilete.tip_bilet%type;
    v_pret bilete.pret%type;
    v_total number := 0;
    v_i number := 1;
    v_puncte number := 0;
begin
    select count(*) into v_nr from vizitatori where id_vizitator = v_id_vizitator;
    if v_nr = 0 then
        dbms_output.put_line('Vizitatorul nu exista.');
    else
        select nume, prenume into v_nume, v_prenume from vizitatori
        where id_vizitator = v_id_vizitator;
        dbms_output.put_line('Vizitator: ' || v_nume || ' ' || v_prenume);
        select count(*) into v_nr_bilete from bilete where id_vizitator = v_id_vizitator;
        dbms_output.put_line('Numar bilete: ' || v_nr_bilete);
        if v_nr_bilete = 0 then
            dbms_output.put_line('Vizitatorul nu are bilete.');
        else
            while v_i <= v_nr_bilete loop
                select pret into v_pret
                from (select pret, rownum rn from bilete where id_vizitator = v_id_vizitator)
                where rn = v_i;
                v_total := v_total + v_pret;
                v_i := v_i + 1;
            end loop;
            dbms_output.put_line('Valoare totala bilete: ' || v_total);
            loop
                v_puncte := v_puncte + 10;
                exit when v_puncte > v_total;
            end loop;
            dbms_output.put_line('Puncte fidelitate: ' || v_puncte);
        end if;
    end if;
end;
/
