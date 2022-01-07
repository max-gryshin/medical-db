--create function medical_limit() returns trigger as $medical_limit$
--begin
--    if (select count(medical_staff_id) from patient where medical_staff_id = NEW.medical_staff_id limit 1) >
--       (select patient_limit from medical_staff where id = NEW.medical_staff_id limit 1) then
--        NEW.medical_staff_id = (
--            select id from medical_staff as ms
--            where ms.patient_limit > (select count(medical_staff_id) from patient where medical_staff_id = ms.id)
--            limit 1
--        );
--    end if;
--
--    return NEW;
--end;
--$medical_limit$ language plpgsql;
--
--create trigger patient_check_medical_limit before insert or update on patient
--    for each row execute procedure medical_limit();