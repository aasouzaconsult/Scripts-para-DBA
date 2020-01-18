--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.1
-- Dumped by pg_dump version 9.1.1
-- Started on 2011-10-29 11:35:54 BRT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 174 (class 3079 OID 12424)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2722 (class 0 OID 0)
-- Dependencies: 174
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 546 (class 2612 OID 16471)
-- Name: plpythonu; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpythonu;


SET search_path = public, pg_catalog;

--
-- TOC entry 540 (class 1247 OID 16478)
-- Dependencies: 5 172
-- Name: tp_base_idade; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE tp_base_idade AS (
	id integer,
	nome character varying,
	cpf character varying,
	idade integer,
	base_idade character varying
);


--
-- TOC entry 538 (class 1247 OID 16455)
-- Dependencies: 5 171
-- Name: tp_pessoa; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE tp_pessoa AS (
	nome character varying,
	idade integer
);


--
-- TOC entry 186 (class 1255 OID 16450)
-- Dependencies: 5 545
-- Name: data_atual(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION data_atual() RETURNS date
    LANGUAGE plpgsql
    AS $$
  declare 
     data date not null DEFAULT '2011-10-30'::date ;
  begin
      select current_date into data;
      --select null into data;
     return data;
  end;  
$$;


--
-- TOC entry 188 (class 1255 OID 16452)
-- Dependencies: 545 5
-- Name: data_atual2(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION data_atual2(OUT data date) RETURNS date
    LANGUAGE plpgsql
    AS $$
     begin
       select current_date into data;
     end;
  $$;


--
-- TOC entry 207 (class 1255 OID 16487)
-- Dependencies: 545 5
-- Name: divide(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION divide(a integer, b integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
  begin
    return a/b;
  exception
    when division_by_zero then
       return -1;     
  end;
$$;


--
-- TOC entry 205 (class 1255 OID 16488)
-- Dependencies: 5 545
-- Name: fnc_alt_pessoa(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_alt_pessoa() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin
     if NEW.idade > 20 then
       NEW.nome := upper(NEW.nome);
       RETURN NEW;
     else  
       RAISE NOTICE 'NAO POSSO CADASTRAR CRIANCAS';  
       RETURN NULL;
     end if;     
  end;
$$;


--
-- TOC entry 206 (class 1255 OID 16486)
-- Dependencies: 5 545 540
-- Name: fnc_base_idade(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_base_idade() RETURNS SETOF tp_base_idade
    LANGUAGE plpgsql
    AS $$
declare
   retorno record;
begin

   for retorno in (select id, nome, cpf, idade, ''::varchar as base_idade from pessoas) loop

      
      if retorno.idade < 18 then
         retorno.base_idade := 'menor';
      elsif retorno.idade <= 25 then
         retorno.base_idade := 'adulto 1';
      elsif retorno.idade <= 45 then
         retorno.base_idade := 'adulto 2';
      elsif retorno.idade <= 65 then
         retorno.base_idade := 'adulto 3';
      elsif retorno.idade > 65 then
         retorno.base_idade := '3 idade';
      else 
         retorno.base_idade := 'Idade nao definida';
      end if;
      return next retorno;
   end loop;

   return ;
end;
$$;


--
-- TOC entry 199 (class 1255 OID 16479)
-- Dependencies: 545 540 5
-- Name: fnc_base_idade(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_base_idade(pcpf character varying) RETURNS tp_base_idade
    LANGUAGE plpgsql
    AS $$
declare
   retorno tp_base_idade;
begin

   select * into retorno from pessoas where cpf = pcpf;
   if not FOUND then
      raise 
         exception 'Pessoa nao encontrada !!!';
   end if;

   if retorno.idade < 18 then
      retorno.base_idade := 'menor';
   elsif retorno.idade <= 25 then
      retorno.base_idade := 'adulto 1';
   elsif retorno.idade <= 45 then
      retorno.base_idade := 'adulto 2';
   elsif retorno.idade <= 65 then
      retorno.base_idade := 'adulto 3';
   elsif retorno.idade > 65 then
      retorno.base_idade := '3 idade';
   else 
      retorno.base_idade := 'Idade nao definida';
   end if;

   return retorno;
end;
$$;


--
-- TOC entry 200 (class 1255 OID 16480)
-- Dependencies: 545 5
-- Name: fnc_exibe_contador(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_exibe_contador(count integer) RETURNS SETOF integer
    LANGUAGE plpgsql
    AS $$
declare
   fcount integer default 1;
begin

   loop
      return next fcount;
      exit when count = fcount;
      fcount :=  fcount + 1; 
   end loop;
   
   return;
end;
$$;


--
-- TOC entry 202 (class 1255 OID 16482)
-- Dependencies: 5 545
-- Name: fnc_exibe_contador_for(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_exibe_contador_for(count integer) RETURNS SETOF integer
    LANGUAGE plpgsql
    AS $$
declare
   fcount integer;
begin

   for fcount in 1..count by 2 loop
      return next fcount; 
   end loop;
   
   return;
end;
$$;


--
-- TOC entry 203 (class 1255 OID 16483)
-- Dependencies: 5 545
-- Name: fnc_exibe_contador_for(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_exibe_contador_for(count integer, p2 integer) RETURNS SETOF integer
    LANGUAGE plpgsql
    AS $$
declare
   fcount integer;
begin

   for fcount in 1..count by p2 loop
      return next fcount; 
   end loop;
   
   return;
end;
$$;


--
-- TOC entry 201 (class 1255 OID 16481)
-- Dependencies: 5 545
-- Name: fnc_exibe_contador_while(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_exibe_contador_while(count integer) RETURNS SETOF integer
    LANGUAGE plpgsql
    AS $$
declare
   fcount integer default 1;
begin

   while count >= fcount loop
      return next fcount;
      fcount :=  fcount + 1; 
   end loop;
   
   return;
end;
$$;


--
-- TOC entry 191 (class 1255 OID 16457)
-- Dependencies: 545 5 538
-- Name: fnc_pessoa(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_pessoa() RETURNS SETOF tp_pessoa
    LANGUAGE plpgsql
    AS $$
     begin
       return query
                   select nome, idade 
                   from pessoas
                   order by nome;
     end;
   $$;


--
-- TOC entry 189 (class 1255 OID 16456)
-- Dependencies: 538 545 5
-- Name: fnc_pessoa(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_pessoa(pcpf character varying) RETURNS tp_pessoa
    LANGUAGE plpgsql
    AS $$
     declare
        resultado tp_pessoa;
     begin
        select nome, idade into resultado
        from pessoas
        where cpf = pcpf;
        return resultado;
     end;
   $$;


--
-- TOC entry 192 (class 1255 OID 16459)
-- Dependencies: 545 5
-- Name: fnc_pessoa2(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_pessoa2() RETURNS TABLE(pnome character varying, pidade integer)
    LANGUAGE plpgsql
    AS $$
     begin
       return query
                   select nome, idade 
                   from pessoas
                   order by nome;
     end;
   $$;


--
-- TOC entry 193 (class 1255 OID 16461)
-- Dependencies: 545 5
-- Name: fnc_pessoa2(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_pessoa2(pcpf character varying, OUT pnome character varying, OUT pidade integer) RETURNS record
    LANGUAGE plpgsql
    AS $$
     begin
        select nome, idade into pnome, pidade
        from pessoas
        where cpf = pcpf;
        
     end;
   $$;


--
-- TOC entry 187 (class 1255 OID 16462)
-- Dependencies: 545 5
-- Name: fnc_pessoa3(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_pessoa3(pcpf character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare 
   result varchar;
 begin
   select nome into result
   from pessoas
   where cpf = pcpf;
   return result; 
   
 end;
$$;


--
-- TOC entry 190 (class 1255 OID 16463)
-- Dependencies: 5 545
-- Name: fnc_pessoa3(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_pessoa3(pcpf character varying, pcampo character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
 declare 
   result varchar;
   sql    text;
 begin
   sql := 'select '|| pcampo || ' from pessoas where cpf = $1';
   execute sql into result using pcpf;
   return result; 
   
 end;
$_$;


--
-- TOC entry 195 (class 1255 OID 16465)
-- Dependencies: 545 5
-- Name: fnc_pessoa4(anyelement, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_pessoa4(pcpf anyelement, pcampo character varying) RETURNS anyelement
    LANGUAGE plpgsql
    AS $_$
 declare 
   result varchar;
   sql    text;
 begin
   sql := 'select '|| pcampo || ' from pessoas where cpf = $1';
   execute sql into result using pcpf;
   return result; 
   
 end;
$_$;


--
-- TOC entry 208 (class 1255 OID 16499)
-- Dependencies: 5 545
-- Name: fnc_tra(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_tra() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin
    insert into log values ('Usuario '|| user || ' cadastrou a transferencia ' || NEW.id);
    return new;
  end;
$$;


--
-- TOC entry 209 (class 1255 OID 16490)
-- Dependencies: 5 545
-- Name: fnc_transfere(integer, integer, numeric, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fnc_transfere(pcta_origem integer, pcta_destino integer, pvalor numeric, pdata date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  declare
    vorigem record;
    vdestino record;
    retorno integer = 0;
    texto text;
    id_tra integer;
  begin 
     -- validando se as contas sao iguais
     if pcta_origem = pcta_destino then
       retorno := 3;
     end if;
     -- validando o valor que deve ser positivo
     if pvalor <= 0 then
       retorno := 5;
     end if;

     -- validando a data da transf 
     if pdata < current_date then
       retorno := 6;
     end if;
     
     -- validando se a conta de origem eh uma conta valida
     select * into vorigem from contas
     where id = pcta_origem;

     if not FOUND then
       retorno := 1;
     end if;  

     -- validando o saldo da conta de origem
     if FOUND then
       if vorigem.saldo < pvalor then
         retorno := 4;
       end if;  
     end if;
       
     -- validando se a conta de destino eh uma conta valida
     select * into vdestino from contas
     where id = pcta_destino;

     if not FOUND then
       retorno := 2;
     end if;

    if retorno = 0 then
      -- retira o saldo da origem
      update contas 
      set saldo = saldo - pvalor
      where id = pcta_origem;

      --cadastra a transferencias
      insert into transferencias (id_conta_origem, id_conta_destino, data, valor) 
      values
      (vorigem.id, vdestino.id, pdata, pvalor) returning id into id_tra;

      -- soma o saldo no destino
      update contas
      set saldo = saldo + pvalor
      where id = pcta_destino;

      
    else
      insert into log values ('log de transf - usuario:' || user ||
                           ' hora: '|| now() ||
                           ' status: '|| retorno ||
                           ' id transf: '|| coalesce(id_tra::varchar,'')) ;
    end if;                       
   return retorno;   
  EXCEPTION
     WHEN OTHERS THEN
        return -1;          
  end;
$$;


--
-- TOC entry 197 (class 1255 OID 16472)
-- Dependencies: 5 546
-- Name: modulo_py(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION modulo_py(pnumero integer) RETURNS character varying
    LANGUAGE plpythonu
    AS $$
  if pnumero % 2 == 0:
     return 'par'
  else:
     return 'impar'    
$$;


--
-- TOC entry 194 (class 1255 OID 16451)
-- Dependencies: 545 5
-- Name: soma(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION soma(p1 integer, p2 integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  begin
     return p1 + p2 ;
  end;
$$;


--
-- TOC entry 196 (class 1255 OID 16467)
-- Dependencies: 5 545
-- Name: soma5(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION soma5(p1 anyelement, p2 anyelement) RETURNS anyelement
    LANGUAGE plpgsql
    AS $$
  begin
    return p1 + p2;
  end;
$$;


--
-- TOC entry 198 (class 1255 OID 16475)
-- Dependencies: 5 545
-- Name: teste(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION teste(pnome character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  declare
    retorno integer;
    d1 integer;
  begin
       select count(id) into retorno from pessoas where nome = pnome;
       GET DIAGNOSTICS d1 = ROW_COUNT;
       raise notice ' o valor contado no diagnostico eh: % ', d1;
       return retorno;  
  end;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 162 (class 1259 OID 16388)
-- Dependencies: 5
-- Name: pessoas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pessoas (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    cpf character varying(14) NOT NULL,
    idade integer
);


--
-- TOC entry 204 (class 1255 OID 16484)
-- Dependencies: 5 545 520
-- Name: teste_pessoas(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION teste_pessoas() RETURNS SETOF pessoas
    LANGUAGE plpgsql
    AS $$
  declare
    reg record;
  begin
     for reg in (select * from pessoas) loop
        reg.nome := upper(reg.nome);
        return next reg;
     end loop;
     return;
  end;
$$;


--
-- TOC entry 164 (class 1259 OID 16398)
-- Dependencies: 2693 5
-- Name: contas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contas (
    id integer NOT NULL,
    codigo_banco character varying(3) NOT NULL,
    codigo_agencia character varying(10) NOT NULL,
    numero_conta character varying(20) NOT NULL,
    digito_verificador_conta character varying(1) NOT NULL,
    saldo numeric(15,2) DEFAULT 0 NOT NULL,
    pessoa_id integer NOT NULL
);


--
-- TOC entry 163 (class 1259 OID 16396)
-- Dependencies: 5 164
-- Name: contas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2723 (class 0 OID 0)
-- Dependencies: 163
-- Name: contas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contas_id_seq OWNED BY contas.id;


--
-- TOC entry 2724 (class 0 OID 0)
-- Dependencies: 163
-- Name: contas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('contas_id_seq', 3, true);


--
-- TOC entry 173 (class 1259 OID 16491)
-- Dependencies: 5
-- Name: log; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log (
    texto text
);


--
-- TOC entry 161 (class 1259 OID 16386)
-- Dependencies: 162 5
-- Name: pessoas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pessoas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2725 (class 0 OID 0)
-- Dependencies: 161
-- Name: pessoas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pessoas_id_seq OWNED BY pessoas.id;


--
-- TOC entry 2726 (class 0 OID 0)
-- Dependencies: 161
-- Name: pessoas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('pessoas_id_seq', 7, true);


--
-- TOC entry 167 (class 1259 OID 16430)
-- Dependencies: 5
-- Name: t1; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE t1 (
    numero integer,
    nome character varying
);


--
-- TOC entry 168 (class 1259 OID 16436)
-- Dependencies: 5
-- Name: t2; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE t2 (
    numero integer,
    apelido character varying
);


--
-- TOC entry 166 (class 1259 OID 16414)
-- Dependencies: 5
-- Name: transferencias; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transferencias (
    id integer NOT NULL,
    id_conta_origem integer NOT NULL,
    id_conta_destino integer NOT NULL,
    data date NOT NULL,
    valor numeric(15,2) NOT NULL
);


--
-- TOC entry 165 (class 1259 OID 16412)
-- Dependencies: 166 5
-- Name: transferencias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE transferencias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2727 (class 0 OID 0)
-- Dependencies: 165
-- Name: transferencias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE transferencias_id_seq OWNED BY transferencias.id;


--
-- TOC entry 2728 (class 0 OID 0)
-- Dependencies: 165
-- Name: transferencias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('transferencias_id_seq', 4, true);


--
-- TOC entry 170 (class 1259 OID 16445)
-- Dependencies: 2690 5
-- Name: vw_join; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW vw_join AS
    SELECT t1.numero AS numero_t1, t1.nome, t2.numero AS numero_t2, t2.apelido FROM (t1 LEFT JOIN t2 USING (numero));


--
-- TOC entry 169 (class 1259 OID 16442)
-- Dependencies: 5
-- Name: vw_pessoas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vw_pessoas (
    id integer,
    nome character varying(100),
    cpf character varying(14)
);


--
-- TOC entry 2692 (class 2604 OID 16401)
-- Dependencies: 163 164 164
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE contas ALTER COLUMN id SET DEFAULT nextval('contas_id_seq'::regclass);


--
-- TOC entry 2691 (class 2604 OID 16391)
-- Dependencies: 161 162 162
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE pessoas ALTER COLUMN id SET DEFAULT nextval('pessoas_id_seq'::regclass);


--
-- TOC entry 2694 (class 2604 OID 16417)
-- Dependencies: 165 166 166
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE transferencias ALTER COLUMN id SET DEFAULT nextval('transferencias_id_seq'::regclass);


--
-- TOC entry 2711 (class 0 OID 16398)
-- Dependencies: 164
-- Data for Name: contas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY contas (id, codigo_banco, codigo_agencia, numero_conta, digito_verificador_conta, saldo, pessoa_id) FROM stdin;
3	237	21	34534	3	20.00	1
2	237	1	22331	3	9900.00	2
1	1	133	10987	1	1100.00	1
\.


--
-- TOC entry 2716 (class 0 OID 16491)
-- Dependencies: 173
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY log (texto) FROM stdin;
log de transf - usuario:postgres hora: 2011-10-29 11:27:15.453915-03 status: 6 id transf: 
Usuario postgres cadastrou a transferencia 4
\.


--
-- TOC entry 2710 (class 0 OID 16388)
-- Dependencies: 162
-- Data for Name: pessoas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY pessoas (id, nome, cpf, idade) FROM stdin;
2	JOAO	11111111112	35
1	MAGNO	11111111111	30
4	MEU TESTE	22	10
3	FULANO	10	45
5	meu teste2	220	10
\.


--
-- TOC entry 2713 (class 0 OID 16430)
-- Dependencies: 167
-- Data for Name: t1; Type: TABLE DATA; Schema: public; Owner: -
--

COPY t1 (numero, nome) FROM stdin;
1	FULANO DA SILVA
2	BELTRANO DA SILVA
3	JOAO DA SILVA
\.


--
-- TOC entry 2714 (class 0 OID 16436)
-- Dependencies: 168
-- Data for Name: t2; Type: TABLE DATA; Schema: public; Owner: -
--

COPY t2 (numero, apelido) FROM stdin;
1	FULANINHO
2	BELTRANO
5	MARGARIDA
\.


--
-- TOC entry 2712 (class 0 OID 16414)
-- Dependencies: 166
-- Data for Name: transferencias; Type: TABLE DATA; Schema: public; Owner: -
--

COPY transferencias (id, id_conta_origem, id_conta_destino, data, valor) FROM stdin;
1	1	2	2011-10-29	100.00
3	2	1	2011-10-29	100.00
4	2	1	2011-10-29	100.00
\.


--
-- TOC entry 2715 (class 0 OID 16442)
-- Dependencies: 169
-- Data for Name: vw_pessoas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY vw_pessoas (id, nome, cpf) FROM stdin;
1	MAGNO	11111111111
2	JOAO	11111111112
\.


--
-- TOC entry 2700 (class 2606 OID 16404)
-- Dependencies: 164 164
-- Name: contas_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contas
    ADD CONSTRAINT contas_pkey PRIMARY KEY (id);


--
-- TOC entry 2702 (class 2606 OID 16406)
-- Dependencies: 164 164 164 164
-- Name: idx_contas_conta; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contas
    ADD CONSTRAINT idx_contas_conta UNIQUE (codigo_banco, codigo_agencia, numero_conta);


--
-- TOC entry 2696 (class 2606 OID 16395)
-- Dependencies: 162 162
-- Name: idx_pessoa_cpf; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pessoas
    ADD CONSTRAINT idx_pessoa_cpf UNIQUE (cpf);


--
-- TOC entry 2698 (class 2606 OID 16393)
-- Dependencies: 162 162
-- Name: pessoas_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pessoas
    ADD CONSTRAINT pessoas_pkey PRIMARY KEY (id);


--
-- TOC entry 2704 (class 2606 OID 16419)
-- Dependencies: 166 166
-- Name: transferencias_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transferencias
    ADD CONSTRAINT transferencias_pkey PRIMARY KEY (id);


--
-- TOC entry 2708 (class 2620 OID 16489)
-- Dependencies: 162 205
-- Name: trg_pessoa; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_pessoa BEFORE INSERT OR UPDATE ON pessoas FOR EACH ROW EXECUTE PROCEDURE fnc_alt_pessoa();


--
-- TOC entry 2709 (class 2620 OID 16500)
-- Dependencies: 166 208
-- Name: trg_tra; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_tra AFTER INSERT ON transferencias FOR EACH ROW EXECUTE PROCEDURE fnc_tra();


--
-- TOC entry 2705 (class 2606 OID 16407)
-- Dependencies: 2697 162 164
-- Name: fk_contas_pessoas; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contas
    ADD CONSTRAINT fk_contas_pessoas FOREIGN KEY (pessoa_id) REFERENCES pessoas(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2706 (class 2606 OID 16420)
-- Dependencies: 2699 166 164
-- Name: fk_destino; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transferencias
    ADD CONSTRAINT fk_destino FOREIGN KEY (id_conta_destino) REFERENCES contas(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2707 (class 2606 OID 16425)
-- Dependencies: 2699 166 164
-- Name: fk_origem; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transferencias
    ADD CONSTRAINT fk_origem FOREIGN KEY (id_conta_origem) REFERENCES contas(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2721 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2011-10-29 11:35:54 BRT

--
-- PostgreSQL database dump complete
--

