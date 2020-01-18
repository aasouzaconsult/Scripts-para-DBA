-- Consumindo a API do Google Maps para obter informações de um endereço ou CEP no SQL Server

CREATE PROCEDURE [dbo].[stpBusca_Informacoes_Endereco] (
    @Ds_Endereco VARCHAR(500) = NULL,
    @Nr_Cep VARCHAR(9) = NULL
)
AS BEGIN
 

    SET NOCOUNT ON
    
    
    SET @Ds_Endereco = NULLIF(@Ds_Endereco, '')
    SET @Nr_Cep = NULLIF(@Nr_Cep, '')

    
    IF (@Ds_Endereco IS NULL AND @Nr_Cep IS NULL)
        RETURN


    ------------------------------------------------------------------------
    -- RECUPERAÇÃO DAS INFORMAÇÕES
    ------------------------------------------------------------------------

    DECLARE 
        @obj INT,
        @Url VARCHAR(8000),
        @resposta VARCHAR(8000),
        @xml XML,
        @endereco_busca VARCHAR(4000)


    IF (@Nr_Cep IS NOT NULL AND @Ds_Endereco IS NULL)
        SET @endereco_busca = LEFT(@Nr_Cep, 5) + '-' + RIGHT(@Nr_Cep, 3) + ', Brasil'
    ELSE
        SET @endereco_busca = @Ds_Endereco

 
    SET @Url = 'http://maps.googleapis.com/maps/api/geocode/xml?address=' + @endereco_busca + '&amp;sensor=false'
 
    EXEC sys.sp_OACreate @progid = 'MSXML2.ServerXMLHTTP', @objecttoken = @obj OUT, @context = 1
    EXEC sys.sp_OAMethod @obj, 'open', NULL, 'GET', @Url, false
    EXEC sys.sp_OAMethod @obj, 'send'
    EXEC sys.sp_OAGetProperty @obj, 'responseText', @resposta OUT
    EXEC sys.sp_OADestroy @obj
 
 
    SET @xml = @resposta COLLATE SQL_Latin1_General_CP1251_CS_AS


    ------------------------------------------------------------------------
    -- TRATAMENTO DO XML
    ------------------------------------------------------------------------

    IF (OBJECT_ID('tempdb..#XML') IS NOT NULL) DROP TABLE #XML
    CREATE TABLE #XML (
        Dados XML
    )

    INSERT INTO #XML
    SELECT Tabela.coluna.query('.') AS Resultado
    FROM @xml.nodes('/GeocodeResponse/result/address_component') Tabela(coluna)


    IF (OBJECT_ID('tempdb..#Endereco') IS NOT NULL) DROP TABLE #Endereco
    CREATE TABLE #Endereco (
        Ds_Tipo VARCHAR(100),
        Ds_Subtipo VARCHAR(100),
        Ds_ShortName VARCHAR(200),
        Ds_LongName VARCHAR(500)
    )

    INSERT INTO #Endereco
    SELECT 
        Dados.query('address_component/type[1]').value('.', 'varchar(100)') AS Ds_Tipo,
        Dados.query('address_component/type[2]').value('.', 'varchar(100)') AS Ds_Subtipo,
        Dados.query('address_component/short_name').value('.', 'varchar(200)') AS Ds_ShortName,
        Dados.query('address_component/long_name').value('.', 'varchar(500)') AS Ds_LongName
    FROM 
        #XML


    INSERT INTO #Endereco
    SELECT 
        'formatted_address',
        'formatted_address',
        '',
        @xml.value('(/GeocodeResponse/result/formatted_address)[1]', 'varchar(500)')


    INSERT INTO #Endereco
    SELECT 
        'latlon',
        'latitude_longitude',
        @xml.value('(/GeocodeResponse/result/geometry/location/lat)[1]', 'varchar(100)'),
        @xml.value('(/GeocodeResponse/result/geometry/location/lng)[1]', 'varchar(100)')



    ------------------------------------------------------------------------
    -- RESULTADO FINAL
    ------------------------------------------------------------------------

    SELECT 
        MAX(CASE WHEN Ds_Tipo = 'formatted_address' THEN Ds_LongName END) AS Ds_Endereco_Completo,
        MAX(CASE WHEN Ds_Tipo = 'route' THEN Ds_LongName END) AS Ds_Logradouro,
        MAX(CASE WHEN Ds_Tipo = 'street_number' THEN Ds_LongName END) AS Ds_Numero,
        MAX(CASE WHEN Ds_Tipo = 'sublocality_level_1' THEN Ds_LongName END) AS Ds_Bairro,
        MAX(CASE WHEN Ds_Tipo = 'administrative_area_level_2' THEN Ds_LongName END) AS Ds_Cidade,
        MAX(CASE WHEN Ds_Tipo = 'postal_code' THEN Ds_LongName END) AS Ds_CEP,
        MAX(CASE WHEN Ds_Tipo = 'administrative_area_level_1' THEN Ds_ShortName END) AS Ds_Estado_Sigla,
        MAX(CASE WHEN Ds_Tipo = 'administrative_area_level_1' THEN Ds_LongName END) AS Ds_Estado,
        MAX(CASE WHEN Ds_Tipo = 'country' THEN Ds_ShortName END) AS Ds_Pais_Sigla,
        MAX(CASE WHEN Ds_Tipo = 'country' THEN Ds_LongName END) AS Ds_Pais,
        MAX(CASE WHEN Ds_Tipo = 'latlon' THEN Ds_ShortName END) AS Ds_Latitude,
        MAX(CASE WHEN Ds_Tipo = 'latlon' THEN Ds_LongName END) AS Ds_Longitude
    FROM 
        #Endereco
    

END

-- Executando
EXEC dbo.stpBusca_Informacoes_Endereco @Ds_Endereco = '%Rua Quixada, 110, Eusébio%';

EXEC dbo.stpBusca_Informacoes_Endereco @Nr_Cep = '61760000';