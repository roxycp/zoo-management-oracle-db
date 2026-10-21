-- ----------------------------------------------------------------------
-- Cerinta 1: Să se realizeze un bloc PL/SQL care primește de la tastatură id-ul unui îngrijitor.
-- Se verifică dacă îngrijitorul există în tabela ingrijitori, dacă nu există, se va afișa un mesaj corespunzător.
-- Dacă îngrijitorul există, se vor prelua numele, prenumele și salariul acestuia si se va determina numărul de animale aflate în grija sa, luând în considerare doar înregistrările active din tabela animale_ingrijitori.
-- Dacă îngrijitorul nu are animale active în grijă, se va afișa un mesaj corespunzător.
-- Dacă îngrijitorul are animale în grijă, se va actualiza salariul acestuia în funcție de numărul de animale:
-- pentru 1 animal - fără modificare;
-- pentru 2 animale - creștere cu 5%;
-- pentru 3 sau mai multe animale - creștere cu 10%;
-- Se va afișa numărul de modificări efectuate.
-- Se vor parcurge animalele aflate în grija îngrijitorului folosind un cursor explicit.
-- Pentru fiecare animal se vor afișa, id-ul animalului, denumirea specie, rolul îngrijitorului pentru acel animal.
set serveroutput on
    accept p_id_ingrijitor prompt 'Introduceti id-ul ingrijitorului: '
declare
    v_id_ingrijitor ingrijitori.id_ingrijitor%type := &p_id_ingrijitor;
    v_nr_ingrijitor number;
    v_nume ingrijitori.nume%type;
    v_sal ingrijitori.salariu%type;
    v_nr_animale number;
    v_procent_marire number := 0;

    cursor c_animale is
        select a.id_animal, s.denumire, ai.rol
        from animale a
        join specii s on a.id_specie = s.id_specie
        join animale_ingrijitori ai on a.id_animal = ai.id_animal
        where ai.id_ingrijitor = v_id_ingrijitor and ai.data_final is null;

    v_id_animal animale.id_animal%type;
    v_denumire specii.denumire%type;
    v_rol animale_ingrijitori.rol%type;

begin
    select count(*) into v_nr_ingrijitor from ingrijitori where id_ingrijitor=v_id_ingrijitor;
    if v_nr_ingrijitor=0 then
        dbms_output.put_line('Nu exista ingrijitorul cu id-ul ' || v_id_ingrijitor);
    else
        select nume, salariu into v_nume, v_sal from ingrijitori where id_ingrijitor=v_id_ingrijitor;
        select count(*) into v_nr_animale from animale_ingrijitori where id_ingrijitor=v_id_ingrijitor and data_final is null;

        dbms_output.put_line('Ingrijitor: ' || v_nume);
        dbms_output.put_line('Salariu initial: ' || v_sal);
        dbms_output.put_line('Numarul de animale pe care le are in grija: ' || v_nr_animale);

        if v_nr_animale=0 then
            dbms_output.put_line('Ingrijitorul nu are animale in grija ');
        else
            if v_nr_animale=1 then v_procent_marire:=0;
            elsif v_nr_animale=2 then v_procent_marire:=0.05;
            else v_procent_marire:=0.1;
            end if;

            update ingrijitori
            set salariu = salariu + salariu * v_procent_marire
            where id_ingrijitor=v_id_ingrijitor;

            dbms_output.put_line('Numar modificari efectuate ale salariului: ' || sql%rowcount);

            dbms_output.put_line('Lista animalelor active: ');

            open c_animale;
            loop
                fetch c_animale into v_id_animal, v_denumire, v_rol;
                exit when c_animale%notfound;

                dbms_output.put_line('Id animal: ' || v_id_animal || ', specie: ' || v_denumire || ', rol: ' || v_rol);
            end loop;
close c_animale;
        end if;
    end if;
end;
/

-- ----------------------------------------------------------------------
-- Cerinta 2: Să se realizeze un bloc PL/SQL care analizează prețurile biletelor și aplică o ajustare pentru biletele sub prețul mediu.
-- Se va calcula prețul mediu al tuturor biletelor din tabela bilete si se va afișa valoarea prețului mediu.
-- Se vor parcurge toate biletele folosind un cursor explicit, iar pentru fiecare bilet se vor afișa: id-ul biletului, tipul biletului, prețul.
-- Fiecare bilet va fi încadrat într-o categorie:
-- sub medie - sub pretul mediu
-- egal cu media - pret mediu
-- peste medie - peste pretul mediu
-- Dacă prețul unui bilet este sub media calculată, atunci acesta va fi majorat cu 5%, se va actualiza tabela bilete corespunzător si se va afișa numărul total de înregistrări modificate.
-- La final, se vor afișa din nou toate biletele pentru a evidenția modificările efectuate.
set serveroutput on
declare
    v_pret_mediu bilete.pret%type;
    v_total_modificari number := 0;
    cursor c_bilete is
        select id_bilet, tip_bilet, pret
        from bilete
        order by id_bilet;
begin
    select avg(pret) into v_pret_mediu from bilete;
    dbms_output.put_line('Pretul mediu al biletelor este: ' || round(v_pret_mediu, 2));
    dbms_output.put_line('Lista biletelor inainte de actualizare:');
    for rec in c_bilete loop
        dbms_output.put_line('Id bilet: ' || rec.id_bilet || ', tip: ' || rec.tip_bilet || ', pret: ' || rec.pret || ', categorie: ' ||
            case
                when rec.pret < v_pret_mediu then 'sub pretul mediu'
                when rec.pret = v_pret_mediu then 'pret mediu'
                else 'peste pretul mediu'
            end);
        if rec.pret < v_pret_mediu then
            update bilete set pret = pret * 1.05 where id_bilet = rec.id_bilet;
            v_total_modificari := v_total_modificari + sql%rowcount;
        end if;
    end loop;
    dbms_output.put_line('Numar total de bilete modificate: ' || v_total_modificari);
    dbms_output.put_line('Lista biletelor dupa actualizare:');
    for rec in (select id_bilet, tip_bilet, pret from bilete order by id_bilet) loop
        dbms_output.put_line('Id bilet: ' || rec.id_bilet ||', tip: ' || rec.tip_bilet ||', pret nou: ' || round(rec.pret, 2));
    end loop;
end;
/

-- ----------------------------------------------------------------------
-- Cerinta 3: Să se creeze un bloc PL/SQL care primește o clasă de animale (ex: „Mamifer”) și verifică dacă aceasta există în tabela specii. Dacă valoarea introdusă este invalidă, se va afișa un mesaj corespunzător. În caz contrar, se vor parcurge toate speciile din clasa respectivă folosind un cursor explicit. Pentru fiecare specie, se va afișa denumirea și valoarea atributului protejata, iar prin intermediul unei structuri CASE se va afișa un mesaj personalizat în funcție de această valoare (Y / N). Pe parcursul parcurgerii se va determina numărul de specii protejate și neprotejate, iar la final se va afișa un raport cu numărul de specii din fiecare categorie.
set serveroutput on
accept p_clasa prompt 'Introduceti clasa de animale: '
declare
    v_clasa specii.clasa%type := '&p_clasa';
    v_nr number;
    v_protejate number := 0;
    v_neprotejate number := 0;
    v_i number := 1;
    cursor c_specii is
        select id_specie, denumire, protejata
        from specii
        where lower(clasa) = lower(v_clasa);
    v_specie c_specii%rowtype;
begin
    select count(*)
    into v_nr
    from specii
    where lower(clasa) = lower(v_clasa);
    if v_nr = 0 then
        dbms_output.put_line('Clasa invalida. Rulati din nou blocul si introduceti o valoare corecta.');
    else
        dbms_output.put_line('Speciile din clasa ' || v_clasa || ':');
        open c_specii;
        loop
            fetch c_specii into v_specie;
            exit when c_specii%notfound;
            dbms_output.put_line('Specie: ' || v_specie.denumire || ', protejata: ' || v_specie.protejata || ' - ' ||
                case
                    when upper(v_specie.protejata) = 'Y' then 'Specie protejata'
                    when upper(v_specie.protejata) = 'N' then 'Specie neprotejata'
                    else 'Valoare necunoscuta'
                end);
            if upper(v_specie.protejata) = 'Y' then
                v_protejate := v_protejate + 1;
            else
                v_neprotejate := v_neprotejate + 1;
            end if;
        end loop;
        close c_specii;
        dbms_output.put_line('---RAPORT FINAL---');
        while v_i <= 2 loop
            if v_i = 1 then
                dbms_output.put_line('Numar specii protejate: ' || v_protejate);
            else
                dbms_output.put_line('Numar specii neprotejate: ' || v_neprotejate);
            end if;
            v_i := v_i + 1;
        end loop;
    end if;
end;
/
-- Clasa de animale: mamifier
-- Clasa de animale: mamifiere

-- ----------------------------------------------------------------------
-- Cerinta 4: Să se creeze un bloc PL/SQL care determină primele 3 habitate cu cele mai multe animale. Se vor selecta habitatele ordonate descrescător după numărul de animale cazate, iar acestea vor fi parcurse folosind un cursor explicit. Pentru fiecare habitat se vor afișa numele habitatului, tipul acestuia și numărul de animale. În plus, se va afișa un mesaj special pentru habitatele care au mai mult de un animal. La final, se va afișa numărul total de habitate afișate.
set serveroutput on
declare
    cursor c_habitate is
        select h.nume, h.tip, count(a.id_animal) nr_animale
        from habitate h
        join animale a on h.id_habitat = a.id_habitat
        group by h.nume, h.tip
        order by count(a.id_animal) desc;
    v_contor number := 0;
    v_total number;
begin
    select count(*)
    into v_total
    from (
        select h.id_habitat
        from habitate h
        join animale a on h.id_habitat = a.id_habitat
        group by h.id_habitat
    );
    if v_total = 0 then
        dbms_output.put_line('Nu exista habitate care sa aiba animale.');
    else
        dbms_output.put_line('Primele 3 habitate cu cele mai multe animale sunt: ');
        for rec in c_habitate loop
            v_contor := v_contor + 1;
            dbms_output.put_line(v_contor || '. habitat: ' || rec.nume || ', tip: ' || rec.tip || ', numar animale: ' || rec.nr_animale);
            if rec.nr_animale > 1 then
                dbms_output.put_line('Acest habitat gazduieste mai mult de un animal.');
            end if;
            exit when v_contor = 3;
        end loop;
        dbms_output.put_line('Numar total de habitate afisate: ' || v_contor);
    end if;
end;
/

-- ----------------------------------------------------------------------
-- Cerinta 5: Să se creeze un bloc PL/SQL care primește de la tastatură un tip de bilet (ex: „adult”, „student”, „copil”) prin intermediul unei variabile de substituție. Se vor selecta toate biletele corespunzătoare tipului introdus. Pentru fiecare bilet se vor afișa id-ul, prețul si un mesaj suplimentar în funcție de valoarea prețului. În cazul în care nu există bilete de tipul introdus, se va afișa un mesaj corespunzător. Dacă există astfel de bilete, acestea vor fi șterse din tabelă si se va afisa numărul de înregistrări șterse și va fi salvat într-o variabilă globală. La final, mesajul va fi afișat, iar modificările vor fi anulate.
set serveroutput on
accept g_tip_bilet prompt 'Introduceti tipul biletului: '
-- variable g_mesaj varchar2(100)
declare
    cursor c_bilete is
        select id_bilet, pret
        from bilete
        where lower(tip_bilet) = lower('&g_tip_bilet');
    v_bilet c_bilete%rowtype;
    v_exista number := 0;
begin
    open c_bilete;
    loop
        fetch c_bilete into v_bilet;
        exit when c_bilete%notfound;
        v_exista := 1;
        dbms_output.put_line('Id bilet: ' || v_bilet.id_bilet || ', pret: ' || v_bilet.pret);
        if v_bilet.pret > 30 then
            dbms_output.put_line('Bilet scump');
        else
            dbms_output.put_line('Bilet ieftin');
        end if;
    end loop;
    close c_bilete;
    if v_exista = 0 then
        :g_mesaj := 'Nu exista bilete de tipul introdus';
    else
        delete from bilete
        where lower(tip_bilet) = lower('&g_tip_bilet');
        :g_mesaj := to_char(sql%rowcount) || ' bilete au fost sterse';
    end if;
end;
/
-- print g_mesaj
rollback;
-- tipul biletului: student

-- ----------------------------------------------------------------------
-- Cerinta 6: Să se creeze un bloc PL/SQL care parcurge toate habitatele existente și, pentru fiecare habitat, afișează animalele cazate în acesta. Pentru fiecare habitat se va afișa numele acestuia, urmat de lista animalelor (id și sex). Dacă un habitat nu conține animale, se va afișa un mesaj corespunzător. La final, se va afișa numărul total de habitate analizate.
set serveroutput on
declare
    cursor c_habitate is
        select id_habitat, nume, tip
        from habitate
        order by id_habitat;
    cursor c_animale(p_id_habitat habitate.id_habitat%type) is
        select id_animal, sex
        from animale
        where id_habitat = p_id_habitat
        order by id_animal;
    v_habitat c_habitate%rowtype;
    v_animal c_animale%rowtype;
    v_nr_animale number;
    v_total_habitate number := 0;
begin
    open c_habitate;
    loop
        fetch c_habitate into v_habitat;
        exit when c_habitate%notfound;
        v_total_habitate := v_total_habitate + 1;
        dbms_output.put_line('Habitat: ' || v_habitat.nume || ' (' || v_habitat.tip || ')');
        select count(*)
        into v_nr_animale
        from animale
        where id_habitat = v_habitat.id_habitat;
        if v_nr_animale = 0 then
            dbms_output.put_line('Nu exista animale in acest habitat');
        else
            open c_animale(v_habitat.id_habitat);
            loop
                fetch c_animale into v_animal;
                exit when c_animale%notfound;
                dbms_output.put_line('   Id animal: ' || v_animal.id_animal || ', sex: ' || v_animal.sex);
            end loop;
            close c_animale;
        end if;
        dbms_output.put_line('--------------------------');
    end loop;
    close c_habitate;
    dbms_output.put_line('Numar total de habitate analizate: ' || v_total_habitate);
end;
/
