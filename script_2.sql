-- Para criação da tabela

IF OBJECT_ID('[dbo].[issues_por_encarregados]', 'U') IS NOT NULL
DROP TABLE [dbo].[issues_por_encarregados]
GO

CREATE TABLE [dbo].[issues_por_encarregados]
(
    nome VARCHAR(255),
    descricao VARCHAR(255),
    milestone VARCHAR(50),
    autor VARCHAR(255),
    tags VARCHAR(255),
    encarregado_login VARCHAR(255),
    encarregado_nome VARCHAR(255)
);

IF OBJECT_ID('[dbo].[dados_brutos]', 'U') IS NOT NULL
DROP TABLE [dbo].[dados_brutos]

CREATE TABLE [dbo].[dados_brutos]
(
    string_dados NVARCHAR(MAX) NOT NULL
)

BULK INSERT [dbo].[dados_brutos]
FROM 'C:\Users\lucsa\Documents\EvolucaoSoftware\atividade_2\issues_por_milestone.json'

DECLARE @issue NVARCHAR(MAX)
SET @issue = (SELECT TOP 1 * FROM [dbo].[dados_brutos])

INSERT INTO [dbo].[issues_por_encarregados]
SELECT nome, descricao, milestone, autor, tag, e_login, e_nome
FROM OPENJSON(@issue)
WITH(
    nome VARCHAR(255) '$.number',
    descricao VARCHAR(255) '$.title',
    milestone VARCHAR(50) '$.milestone.title',
    tags NVARCHAR(MAX) '$.labels' AS JSON,
    autor VARCHAR(255) '$.author.name',
    encarregado NVARCHAR(MAX) '$.assignees' AS JSON
)
OUTER APPLY OPENJSON(tags) 
WITH (
    tag NVARCHAR(50) '$.name'
)
OUTER APPLY OPENJSON(encarregado) 
WITH (
    e_login NVARCHAR(50) '$.login',
    e_nome NVARCHAR(50) '$.name'
)

DELETE FROM [dbo].[dados_brutos]

-- Agrega as tags e seus encarregadis por issues
SELECT nome, descricao, milestone, autor,
    STUFF(
        (
            SELECT '| ' + tags
            FROM [dbo].[issues_por_encarregados]
            WHERE [nome] = t1.[nome]
            FOR XML PATH ('') 
        ), 1, 1, ''
    ) AS tags,
    STUFF(
        (
            SELECT ', ' + encarregado_login
            FROM [dbo].[issues_por_encarregados]
            WHERE [nome] = t1.[nome]
            FOR XML PATH ('') 
        ), 1, 1, '') 
    AS encarregados_logins
FROM [dbo].[issues_por_encarregados] t1
GROUP BY nome, descricao, milestone, autor
ORDER BY milestone DESC, tags

-- SELECT * FROM [dbo].[issues_por_encarregados]