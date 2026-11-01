-- Analytical views on the Lakehouse SQL analytics endpoint (T-SQL).
-- They shape raw ingested data into what the report needs, so the semantic
-- model doesn't do row-level work. A notebook materialises each vw_X into
-- tb_X (see fabric-onelake-portfolio); the model reads the tb_ tables.
--
-- Table and column names are anonymised.

-- 1. Consolidated view per business unit: one raw table per year → one view.
CREATE OR ALTER VIEW dbo.vw_UnitA AS
SELECT *, 2024 AS [Year] FROM dbo.Raw_UnitA_2024
UNION ALL
SELECT *, 2025 AS [Year] FROM dbo.Raw_UnitA_2025
UNION ALL
SELECT *, 2026 AS [Year] FROM dbo.Raw_UnitA_2026;
GO

-- 2. Cross-unit view: same shape for every unit, so one report page can show all.
CREATE OR ALTER VIEW dbo.vw_AllUnits AS
SELECT 'Unit A' AS Unit, ProcessId, ItemCode, Scope, Entity, [Year],
       StatusCode, AwardFlag, QtyInProcess, AwardedValue, BaseValue
FROM dbo.vw_UnitA
UNION ALL
SELECT 'Unit B', ProcessId, ItemCode, Scope, Entity, [Year],
       StatusCode, AwardFlag, QtyInProcess, AwardedValue, BaseValue
FROM dbo.vw_UnitB;
GO

-- 3. Working days between process milestones, using a calendar table that
--    flags weekends and public holidays.
CREATE OR ALTER VIEW dbo.vw_UnitA_WorkingDays AS
SELECT
    p.ProcessId,
    p.StartDate,
    p.AwardDate,
    COUNT(c.[Date]) AS WorkingDaysToAward
FROM dbo.vw_UnitA AS p
JOIN dbo.Calendar AS c
  ON c.[Date] > p.StartDate
 AND c.[Date] <= COALESCE(p.AwardDate, CAST(GETDATE() AS date))
 AND c.IsWorkingDay = 1
GROUP BY p.ProcessId, p.StartDate, p.AwardDate;
GO

-- 4. Monthly and annual KPIs, pre-aggregated for the overview page.
CREATE OR ALTER VIEW dbo.vw_UnitA_KPI_Monthly AS
SELECT
    [Year],
    MONTH(AwardDate)                                         AS [Month],
    Scope,
    COUNT(DISTINCT ProcessId)                                AS Processes,
    SUM(CASE WHEN AwardFlag = 1 THEN QtyInProcess ELSE 0 END) AS QtyAwarded,
    SUM(CASE WHEN AwardFlag = 1 THEN 0 ELSE QtyInProcess END) AS QtyInProgress,
    SUM(AwardedValue)                                        AS AwardedValue,
    SUM(BaseValue) - SUM(AwardedValue)                       AS Savings
FROM dbo.vw_UnitA
GROUP BY [Year], MONTH(AwardDate), Scope;
GO

-- 5. Plan vs actual: forecast quantities joined to what was processed.
CREATE OR ALTER VIEW dbo.vw_UnitA_Forecasts AS
SELECT
    f.[Year], f.Scope, f.ItemCode,
    f.ForecastQty,
    COALESCE(a.QtyAwarded, 0) AS QtyAwarded
FROM dbo.Raw_UnitA_Forecasts AS f
LEFT JOIN (
    SELECT [Year], Scope, ItemCode,
           SUM(CASE WHEN AwardFlag = 1 THEN QtyInProcess ELSE 0 END) AS QtyAwarded
    FROM dbo.vw_UnitA
    GROUP BY [Year], Scope, ItemCode
) AS a
  ON a.[Year] = f.[Year] AND a.Scope = f.Scope AND a.ItemCode = f.ItemCode;
GO
