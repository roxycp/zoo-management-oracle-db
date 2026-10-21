-- ----------------------------------------------------------------------
-- Cerinta 1: Să se citească de la tastatură habitatul unui id. Dacă habitatul nu există, să se invoce o excepție definită de utilizator. Dacă habitatul există, dar nu conține animale, să se invoce o altă excepție definită de utilizator. În caz contrar, să se afișeze numele habitatului și lista animalelor din acel habitat, împreună cu specia și sexul lor, folosind un cursor explicit parametrizat. La final să se afișeze și numărul total de animale găsite.
set serveroutput on
accept p_id_habitat prompt 'Introduceti id-ul habitatului: '
declare
    v_id_habitat habitate.id_habitat%type := &p_id_habitat;
    v_nume_habitat habitate.nume%type;
    v_exista number;
    v_nr_animale number := 0;
    e_habitat_inexistent exception;
    e_fara_animale exception;
    cursor c_animale(p_id habitate.id_habitat%type) is
        select a.id_animal, s.denumire, a.sex from animale a join specii s on a.id_specie = s.id_specie
        where a.id_habitat = p_id
        order by a.id_animal;
begin
    select count(*) into v_exista from habitate where id_habitat = v_id_habitat;
    if v_exista = 0 then
        raise e_habitat_inexistent;
    end if;
    select nume into v_nume_habitat from habitate where id_habitat = v_id_habitat;
    select count(*) into v_nr_animale from animale where id_habitat = v_id_habitat;
    if v_nr_animale = 0 then
        raise e_fara_animale;
    end if;
    dbms_output.put_line('Habitat: ' || v_nume_habitat);
    dbms_output.put_line('Lista animalelor:');
    v_nr_animale := 0;
    for rec in c_animale(v_id_habitat) loop
        v_nr_animale := v_nr_animale + 1;
        dbms_output.put_line('Animal ID: ' || rec.id_animal ||',  specie: ' || rec.denumire || ', sex: ' ||
                             case
                                 when rec.sex = 'M' then 'Mascul'
                                 when rec.sex = 'F' then 'Femela'
                                 else 'Necunoscut'
                             end);
    end loop;
    dbms_output.put_line('Numar total animale: ' || v_nr_animale);
exception
    when e_habitat_inexistent then
        dbms_output.put_line('Nu exista habitatul cu id-ul introdus.');
    when e_fara_animale then
        dbms_output.put_line('Habitatul exista, dar nu are animale repartizate.');
    when others then
        dbms_output.put_line('A aparut o eroare: ' || sqlerrm);
end;
/
-- id_habitat=2
-- id_habitat=9

-- ----------------------------------------------------------------------
-- Cerinta 2: Să se construiască un bloc PL/SQL prin care se citesc de la tastatură un tip de bilet și o dată de emitere. Să se verifice dacă există bilete emise la data respectivă; în caz contrar, să se invoce o excepție definită de utilizator. Dacă există, să se identifice vizitatorul care a cumpărat biletul de tipul indicat. Să se trateze excepțiile de sistem no_data_found și too_many_rows. În cazul în care există exact un singur rezultat, să se afișeze numele complet și emailul vizitatorului, tipul și prețul biletului, precum și o clasificare a prețului folosind case. La final, să se afișeze numărul total de bilete de acel tip emise în ziua respectivă.
set serveroutput on
accept p_tip prompt 'Introduceti tipul biletului: '
accept p_data prompt 'Introduceti data emiterii (ex: DD-MON-YY): '
declare
    v_tip bilete.tip_bilet%type := '&p_tip';
    v_data date := to_date('&p_data', 'dd-mon-yy');
    v_nume vizitatori.nume%type;
    v_prenume vizitatori.prenume%type;
    v_email vizitatori.email%type;
    v_pret bilete.pret%type;
    v_nr_bilete_data number;
    v_nr_bilete_tip number;
    v_categorie_pret varchar2(20);
    e_fara_bilete_in_ziua_respectiva exception;
begin
    select count(*) into v_nr_bilete_data from bilete where trunc(data_emitere) = trunc(v_data);
    if v_nr_bilete_data = 0 then
        raise e_fara_bilete_in_ziua_respectiva;
    end if;
    select v.nume, v.prenume, v.email, b.pret
    into v_nume, v_prenume, v_email, v_pret
    from vizitatori v join bilete b on v.id_vizitator = b.id_vizitator
    where lower(b.tip_bilet) = lower(v_tip) and trunc(b.data_emitere) = trunc(v_data);
    case
        when v_pret < 30 then
            v_categorie_pret := 'ieftin';
        when v_pret between 30 and 60 then
            v_categorie_pret := 'mediu';
        else
            v_categorie_pret := 'scump';
    end case;
    select count(*) into v_nr_bilete_tip from bilete
    where lower(tip_bilet) = lower(v_tip) and trunc(data_emitere) = trunc(v_data);
    dbms_output.put_line('Vizitator gasit: ' || v_nume || ' ' || v_prenume);
    dbms_output.put_line('Email: ' || v_email);
    dbms_output.put_line('Tip bilet: ' || v_tip);
    dbms_output.put_line('Pret bilet: ' || v_pret);
    dbms_output.put_line('Categoria de pret: ' || v_categorie_pret);
    dbms_output.put_line('Numar total de bilete de acest tip emise in ziua respectiva: ' || v_nr_bilete_tip);
exception
    when e_fara_bilete_in_ziua_respectiva then
        dbms_output.put_line('Nu exista bilete emise la data introdusa.');
    when no_data_found then
        dbms_output.put_line('Nu exista niciun vizitator care a cumparat tipul de bilet introdus la data respectiva.');
    when too_many_rows then
        dbms_output.put_line('Exista mai multi vizitatori care corespund criteriului introdus.');
    when others then
        dbms_output.put_line('A aparut o eroare: ' || sqlerrm);
end;
/
-- Tipul biletului: adult
-- Data emiterii: 05-MAY-24
-- Data emiterii: 24-MAR-26
-- Data emiterii: 04-MAY-24

-- ----------------------------------------------------------------------
-- Cerinta 3:  Să se citească de la tastatură un tip de bilet și un procent de majorare. Să se actualizeze prețul biletelor de tipul respective si sa se afiseze inainte si dupa actualizare. Dacă procentul introdus nu este cuprins intre 0 si 50, să se invoce o excepție definită de utilizator. Dacă nu există niciun bilet de tipul respectiv și comanda update nu modifică nimic, să se invoce o altă excepție definită de utilizator. Să se afișeze numărul de modificări. La final se face rollback, ca să pot testa de mai multe ori.
set serveroutput on
accept p_tip prompt 'Introduceti tipul biletului: '
accept p_proc prompt 'Introduceti procentul de majorare: '
declare
    v_tip bilete.tip_bilet%type := '&p_tip';
    v_procent number := &p_proc;
    e_procent_invalid exception;
    e_tip_inexistent exception;
    cursor c_bilete is
        select id_bilet, tip_bilet, pret
        from bilete
        where lower(tip_bilet) = lower(v_tip)
        order by id_bilet;
begin
    if v_procent <= 0 or v_procent > 50 then
        raise e_procent_invalid;
    end if;
    dbms_output.put_line('--- Preturi initiale ---');
    for rec in c_bilete loop
        dbms_output.put_line('Bilet id: ' || rec.id_bilet || ', tip: ' || rec.tip_bilet || ', pret initial: ' || rec.pret);
    end loop;
    update bilete
    set pret = pret + pret * v_procent / 100
    where lower(tip_bilet) = lower(v_tip);
    if sql%notfound then
        raise e_tip_inexistent;
    end if;
    dbms_output.put_line(' ');
    dbms_output.put_line('S-au modificat ' || sql%rowcount || ' bilete.');
    dbms_output.put_line('--- Preturi dupa modificare ---');
    for rec in c_bilete loop
        dbms_output.put_line('Bilet id: ' || rec.id_bilet || ', tip: ' || rec.tip_bilet || ', pret modificat: ' || rec.pret);
    end loop;
    rollback;
    dbms_output.put_line(' ');
    dbms_output.put_line('Modificarile au fost anulate prin rollback.');
exception
    when e_procent_invalid then
        dbms_output.put_line('Procentul introdus trebuie sa fie cuprins intre 0 si 50.');
    when e_tip_inexistent then
        dbms_output.put_line('Nu exista bilete de tipul introdus.');
    when others then
        dbms_output.put_line('A aparut o eroare: ' || sqlerrm);
        rollback;
end;
/
-- Tipul biletului: pensionar
-- Tipul biletului: student
-- Procentul de majorare=10
-- Pretul de majorare: 70

-- ----------------------------------------------------------------------
-- Cerinta 4: Să se construiască un bloc PL/SQL prin care se citește de la tastatură id-ul unui ingrijitor. Să se verifice dacă îngrijitorul există în baza de date; în caz contrar, să se invoce o excepție definită de utilizator. Dacă îngrijitorul există, să se determine animalele de care se ocupă acesta, utilizând un cursor explicit, și să se afișeze pentru fiecare animal id-ul, denumirea speciei, habitatul în care se află și rolul îngrijitorului. În cazul în care îngrijitorul nu are niciun animal asociat, să se invoce o excepție definită de utilizator. La final, să se afișeze numărul total de animale îngrijite de acesta și să se afișeze un mesaj corespunzător în funcție de numărul de animale: „îngrijitor foarte ocupat” dacă are mai mult de 3 animale, „îngrijitor moderat ocupat” dacă are între 1 și 3 animale sau „îngrijitor fără activitate” dacă nu are animale asociate.
set serveroutput on
accept p_id_ingrijitor prompt 'Introduceti id-ul ingrijitorului: '
declare
    v_id_ingrijitor ingrijitori.id_ingrijitor%type := &p_id_ingrijitor;
    v_exista number;
    v_nr_animale number := 0;
    v_nume ingrijitori.nume%type;
    v_prenume ingrijitori.prenume%type;
    e_ingrijitor_inexistent exception;
    e_fara_animale exception;
    cursor c_animale is
        select a.id_animal, s.denumire as specie, h.nume as habitat, ai.rol
        from animale_ingrijitori ai
        join animale a on ai.id_animal = a.id_animal
        join specii s on a.id_specie = s.id_specie
        join habitate h on a.id_habitat = h.id_habitat
        where ai.id_ingrijitor = v_id_ingrijitor;
begin
    select count(*) into v_exista from ingrijitori where id_ingrijitor = v_id_ingrijitor;
    if v_exista = 0 then
        raise e_ingrijitor_inexistent;
    end if;
    select nume, prenume into v_nume, v_prenume from ingrijitori where id_ingrijitor = v_id_ingrijitor;
    dbms_output.put_line('Ingrijitor: ' || v_nume || ' ' || v_prenume);
    dbms_output.put_line('Animalele ingrijite:');
    for rec in c_animale loop
        v_nr_animale := v_nr_animale + 1;
        dbms_output.put_line('Animal id: ' || rec.id_animal || ', specie: ' || rec.specie || ', habitat: ' || rec.habitat || ', rol: ' || rec.rol);
    end loop;
    if v_nr_animale = 0 then
        raise e_fara_animale;
    end if;
    dbms_output.put_line(' ');
    dbms_output.put_line('Numar total animale: ' || v_nr_animale);
    if v_nr_animale > 3 then
        dbms_output.put_line('Ingrijitor foarte ocupat.');
    elsif v_nr_animale between 1 and 3 then
        dbms_output.put_line('Ingrijitor moderat ocupat.');
    else
        dbms_output.put_line('Ingrijitor fara activitate.');
    end if;
exception
    when e_ingrijitor_inexistent then
        dbms_output.put_line('Ingrijitorul nu exista.');
    when e_fara_animale then
        dbms_output.put_line('Ingrijitorul nu are animale asociate.');
    when others then
        dbms_output.put_line('A aparut o eroare: ' || sqlerrm);
end;
/
-- id_inrgijitor=2
