  CREATE OR REPLACE FUNCTION fu_Log_LoteFrango() RETURNS TRIGGER AS $tr_Log_LoteFrango$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO Log_LoteFrango SELECT OLD.cd_lote, OLD.id_ativo, OLD.dt_desativacao, OLD.dt_alojamento, OLD.cd_usuario, 'E', now();
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO Log_LoteFrango SELECT OLD.cd_lote, OLD.id_ativo, OLD.dt_desativacao, OLD.dt_alojamento, OLD.cd_usuario, 'U', now();
            INSERT INTO Log_LoteFrango SELECT NEW.cd_lote, NEW.id_ativo, NEW.dt_desativacao, NEW.dt_alojamento, NEW.cd_usuario, 'U', now();
            --INSERT INTO emp_audit SELECT 'A', user, now(), NEW.*;
            RETURN NEW;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO Log_LoteFrango SELECT NEW.cd_lote, NEW.id_ativo, NEW.dt_desativacao, NEW.dt_alojamento, NEW.cd_usuario, 'I', now();
            --INSERT INTO emp_audit SELECT 'I', user, now(), NEW.*;
            RETURN NEW;
        END IF;
        RETURN NULL; -- o resultado é ignorado uma vez que este é um gatilho AFTER
    END;
    $tr_Log_LoteFrango$ language plpgsql;

CREATE TRIGGER tr_Log_LoteFrango
  AFTER INSERT OR UPDATE OR DELETE ON Lote_Frango
    FOR EACH ROW EXECUTE PROCEDURE fu_Log_LoteFrango();


CREATE TABLE Log_LoteFrango (
    cd_lote character varying(12)
  , id_ativo character varying(1)
  , dt_desativacao timestamp without time zone
  , dt_alojamento timestamp without time zone
  , cd_usuario numeric(6,0)
  , tipo char(1)
  , data timestamp
); --drop table Log_LoteFrango


Select * from Lote_Frango; --campo ID_ATIVO da tabela LOTE_FRANGO
Select * from Log_LoteFrango;