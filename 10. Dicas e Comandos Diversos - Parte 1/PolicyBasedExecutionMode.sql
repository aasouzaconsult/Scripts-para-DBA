USE msdb
GO

WITH AutomatedPolicyExecutionMode(ModeId, ModeName)
AS
(
	SELECT
		*
	FROM
		(VALUES 
			(0, 'On Demand'),
			(1, 'On Change - Prevent'),
			(2, 'On Change - Log Only'),
			(4, 'On Schedule')
		) AS EM(ModeId, ModeName)
)

SELECT
	pmf.[management_facet_id] AS FacetID,
	pmf.[name] AS FacetName,
	Apem.[ModeName]
FROM
	syspolicy_management_facets AS pmf
INNER JOIN
	AutomatedPolicyExecutionMode AS Apem
ON
	pmf.execution_mode & Apem.ModeId = Apem.ModeId
ORDER BY
	pmf.name, Apem.ModeName