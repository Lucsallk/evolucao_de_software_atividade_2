-- Para criação da tabela

IF OBJECT_ID('[dbo].[issues]', 'U') IS NOT NULL
DROP TABLE [dbo].[issues]
GO

CREATE TABLE [dbo].[issues]
(
    nome VARCHAR(255),
    descricao VARCHAR(255),
    milestone VARCHAR(50),
    data_abertura DATETIME,
    data_conclusao DATETIME,
    autor VARCHAR(255),
    tags VARCHAR(255)
);

IF OBJECT_ID('[dbo].[dados_brutos]', 'U') IS NOT NULL
DROP TABLE [dbo].[dados_brutos]

CREATE TABLE [dbo].[dados_brutos]
(
    string_dados NVARCHAR(MAX) NOT NULL
)

-- Para popular a tabela

BULK INSERT [dbo].[dados_brutos]
FROM 'C:\Users\lucsa\Documents\EvolucaoSoftware\atividade_2\issues_por_milestone.json'

DECLARE @issue NVARCHAR(MAX)
SET @issue = (SELECT TOP 1 * FROM [dbo].[dados_brutos])

INSERT INTO [dbo].[issues]
SELECT nome, descricao, milestone, data_abertura, data_conclusao, autor, tag
FROM OPENJSON(@issue)
WITH(
    nome VARCHAR(255) '$.number',
    descricao VARCHAR(255) '$.title',
    milestone VARCHAR(50) '$.milestone.title',
    data_abertura DATETIME '$.createdAt',
    data_conclusao DATETIME '$.createdAt',
    autor VARCHAR(255) '$.author.name',
    tags NVARCHAR(MAX) '$.labels' AS JSON
)
OUTER APPLY OPENJSON(tags) WITH (tag NVARCHAR(50) '$.name')

DELETE FROM [dbo].[dados_brutos]

BULK INSERT [dbo].[dados_brutos]
FROM 'C:\Users\lucsa\Documents\EvolucaoSoftware\atividade_2\issues_por_milestone_2.json'

-- Para consultar os dados das Releases separados por milestones

SET @issue = (SELECT TOP 1 * FROM [dbo].[dados_brutos])

INSERT INTO [dbo].[issues]
SELECT nome, descricao, milestone, data_abertura, data_conclusao, autor, tag
FROM OPENJSON(@issue)
WITH(
    nome VARCHAR(255) '$.number',
    descricao VARCHAR(255) '$.title',
    milestone VARCHAR(50) '$.milestone.title',
    data_abertura DATETIME '$.createdAt',
    data_conclusao DATETIME '$.createdAt',
    autor VARCHAR(255) '$.author.name',
    tags NVARCHAR(MAX) '$.labels' AS JSON
)
OUTER APPLY OPENJSON(tags) WITH (tag NVARCHAR(50) '$.name'); 

SELECT nome, descricao, milestone, data_abertura, data_conclusao, autor,
    STUFF(
        (
            SELECT '| ' + tags
            FROM [dbo].[issues]
            WHERE [nome] = t1.[nome]
            FOR XML PATH ('') 
        ), 1, 1, '') AS tags
FROM [dbo].[issues] t1
GROUP BY nome, descricao, milestone, data_abertura, data_conclusao, autor
ORDER BY milestone DESC, tags