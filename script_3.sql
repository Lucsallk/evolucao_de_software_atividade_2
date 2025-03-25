-- Distinção de participação dos Devs
SELECT
    encarregado_login,
    encarregado_nome,
    STRING_AGG(tags, ', ') AS tags,
    COUNT(encarregado_login) AS nm_issues
FROM [dbo].[issues_por_encarregados] i
GROUP BY i.encarregado_login, encarregado_nome
ORDER BY COUNT(encarregado_login) DESC
