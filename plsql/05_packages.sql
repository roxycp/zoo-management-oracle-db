-- Cerință: Sa se grupeze functiile si procedurile realizate anterior in doua pachete PL/SQL, astfel incat subprogramele sa fie organizate logic in functie de domeniul lor de utilizare.
-- Pachetul 1:
create or replace package pkg_animale_habitate is
    procedure p_afisare_animale_habitat(p_id_habitat habitate.id_habitat%type);
    procedure p_asignare_ingrijitor(
        p_id_animal animale.id_animal%type,
        p_id_ingrijitor ingrijitori.id_ingrijitor%type,
        p_rol animale_ingrijitori.rol%type
    );
    function f_numar_animale_habitat(p_id_habitat habitate.id_habitat%type) return number;
    function f_salariu_mediu_habitat(p_id_habitat habitate.id_habitat%type) return number;

end pkg_animale_habitate;
/
create or replace package body pkg_animale_habitate is
    procedure p_afisare_animale_habitat(p_id_habitat habitate.id_habitat%type)
    is
        v_exista number;
        e_fara_animale exception;
        cursor c_animale is
            select a.id_animal, s.denumire
            from animale a
            join specii s on a.id_specie = s.id_specie
            where a.id_habitat = p_id_habitat;
    begin
        select count(*) into v_exista from habitate where id_habitat = p_id_habitat;
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

    procedure p_asignare_ingrijitor(p_id_animal animale.id_animal%type,p_id_ingrijitor ingrijitori.id_ingrijitor%type,p_rol animale_ingrijitori.rol%type)
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

    function f_numar_animale_habitat(p_id_habitat habitate.id_habitat%type) return number
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

    function f_salariu_mediu_habitat(p_id_habitat habitate.id_habitat%type) return number
    is
        v_nr_habitate number;
        v_salariu_mediu number;
    begin
        select count(*)   into v_nr_habitate  from habitate where id_habitat = p_id_habitat;
        if v_nr_habitate = 0 then
            raise_application_error(-20002, 'Nu exista habitatul cu id-ul ' || p_id_habitat);
        end if;
        select nvl(avg(i.salariu), 0)  into v_salariu_mediu
        from animale a
        join animale_ingrijitori ai on a.id_animal = ai.id_animal
        join ingrijitori i on ai.id_ingrijitor = i.id_ingrijitor
        where a.id_habitat = p_id_habitat;

        return round(v_salariu_mediu, 2);
    exception
        when others then
            raise;
    end;
end;
/
-- Apel functii si proceduri:
set serveroutput on;
declare
    v_nr number;
    v_sal_mediu number;
begin
    pkg_animale_habitate.p_afisare_animale_habitat(1);
    pkg_animale_habitate.p_asignare_ingrijitor(1, 2, 'asistent');
    v_nr := pkg_animale_habitate.f_numar_animale_habitat(1);
    dbms_output.put_line('Numar animale: ' || v_nr);

    v_sal_mediu := pkg_animale_habitate.f_salariu_mediu_habitat(1);
    dbms_output.put_line('Salariu mediu: ' || v_sal_mediu);
end;
/
-- Pachetul 2:
create or replace package pkg_bilete_vizitatori is
    procedure p_majorare_pret_bilet(p_tip_bilet bilete.tip_bilet%type, p_procent number);
    procedure p_raport_cheltuieli_vizitator(p_id_vizitator vizitatori.id_vizitator%type);
    function f_incasari_tip_bilet(p_tip_bilet bilete.tip_bilet%type) return number;
    function f_total_cheltuit_vizitator(p_id_vizitator vizitatori.id_vizitator%type) return number;
end;
/
create or replace package body pkg_bilete_vizitatori is
    procedure p_majorare_pret_bilet(p_tip_bilet bilete.tip_bilet%type, p_procent number)
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

    procedure p_raport_cheltuieli_vizitator(p_id_vizitator vizitatori.id_vizitator%type)
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

    function f_incasari_tip_bilet(p_tip_bilet bilete.tip_bilet%type) return number
    is
        v_incasari number := 0;
        v_exista   number;
    begin
        select count(*) into v_exista from bilete where lower(tip_bilet) = lower(p_tip_bilet);
        if v_exista = 0 then
            dbms_output.put_line('Nu exista bilete de tipul ' || p_tip_bilet);
            return 0;
        end if;
        select nvl(sum(pret),0) into v_incasari from bilete
        where lower(tip_bilet) = lower(p_tip_bilet);
        return v_incasari;
    end;

    function f_total_cheltuit_vizitator(p_id_vizitator vizitatori.id_vizitator%type) return number
    is
        v_nr_vizitatori number;
        v_total number;
    begin
        select count(*) into v_nr_vizitatori from vizitatori where id_vizitator = p_id_vizitator;
        if v_nr_vizitatori = 0 then
            raise_application_error(-20005, 'Nu exista vizitatorul cu id-ul ' || p_id_vizitator);
        end if;
        select nvl(sum(pret), 0) into v_total from bilete
        where id_vizitator = p_id_vizitator;
        return v_total;
    end;
end;
/
-- Apel functii si proceduri:
set serveroutput on;
declare
    v_inc number;
    v_total number;
begin
    pkg_bilete_vizitatori.p_majorare_pret_bilet('adult', 10);
    pkg_bilete_vizitatori.p_raport_cheltuieli_vizitator(1);
    v_inc := pkg_bilete_vizitatori.f_incasari_tip_bilet('adult');
    dbms_output.put_line('Incasari adult: ' || v_inc);

    v_total := pkg_bilete_vizitatori.f_total_cheltuit_vizitator(1);
    dbms_output.put_line('Total vizitator: ' || v_total);
end;
/
