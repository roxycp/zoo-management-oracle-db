-- ----------------------------------------------------------------------
-- Cerinta 1: Sa se creeze un declansator care nu permite introducerea sau modificarea unui bilet cu pret mai mic sau egal cu 0. Daca data emiterii nu este completata, aceasta va fi setata automat la data curenta.
create or replace trigger trg_verifica_bilet
before insert or update on bilete
for each row
begin
    if :new.pret <= 0 then
        raise_application_error(-20010, 'pretul biletului trebuie sa fie mai mare decat 0');
    end if;
    if :new.data_emitere is null then
        :new.data_emitere := sysdate;
    end if;
end;
/
insert into bilete values (24, 'adult', 50, null, 1);
insert into bilete values (21, 'copil', -10, sysdate, 2);

-- ----------------------------------------------------------------------
-- Cerinta 2: Sa se creeze un declansator care nu permite micsorarea salariului unui ingrijitor si nu permite introducerea unui salariu sub 3000.
create or replace trigger trg_verifica_salariu_ingrijitor
before insert or update of salariu on ingrijitori
for each row
begin
    if :new.salariu < 3000 then
        raise_application_error(-20011, 'salariul ingrijitorului nu poate fi mai mic de 3000');
    end if;
    if updating and :new.salariu < :old.salariu then
        raise_application_error(-20012, 'salariul ingrijitorului nu poate fi micsorat');
    end if;
end;
/
update ingrijitori
set salariu = salariu + 500
where id_ingrijitor = 1;
update ingrijitori
set salariu = 1000
where id_ingrijitor = 1;
update ingrijitori
set salariu = salariu - 200
where id_ingrijitor = 2;

-- ----------------------------------------------------------------------
-- Cerinta 3: Sa se creeze un declansator care verifica rolul ingrijitorului la asocierea cu un animal, completeaza automat data de inceput si nu permite ca data finala sa fie mai mica decat data de inceput.
create or replace trigger trg_verifica_animale_ingrijitori
before insert or update on animale_ingrijitori
for each row
begin
    if :new.data_start is null then
        :new.data_start := sysdate;
    end if;
    if lower(:new.rol) not in ('titular', 'asistent', 'voluntar') then
        raise_application_error(-20013, 'rolul introdus nu este valid');
    end if;
    if :new.data_final is not null and :new.data_final < :new.data_start then
        raise_application_error(-20014, 'data finala nu poate fi mai mica decat data de inceput');
    end if;
end;
/
insert into animale_ingrijitori values (2, 5, null, null, 'asistent');
insert into animale_ingrijitori values (3, 6, sysdate, null, 'sef');
insert into animale_ingrijitori values (4, 7, sysdate, DATE '2020-01-01', 'titular');
