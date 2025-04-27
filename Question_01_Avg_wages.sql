/*
 * 	Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
 */

-- za sledovaná období zjistíme průměrné mzdy pro dané odvětví

CREATE OR REPLACE VIEW avg_wages AS
SELECT industry,
	payroll_year,
	average_wages 
FROM t_zuzana_suchankova_project_sql_primary_final
GROUP BY industry, payroll_year
ORDER BY industry;

 -- tabulka s procentuálním přehledem růstu/poklesu průměrných mezd
CREATE OR REPLACE VIEW avg_wages_growth AS
SELECT
	aw.industry, 
	aw.payroll_year,
	aw2.payroll_year  AS year_previous,
	ROUND ((aw.average_wages - aw2.average_wages) / aw2.average_wages * 100, 2) AS wage_growth
FROM avg_wages aw 
JOIN avg_wages aw2 
	ON aw.industry = aw2.industry 
	AND aw.payroll_year = aw2.payroll_year + 1;

-- Největší meziroční nárůst průměrné mzdy
SELECT 
    awg.industry,
    ROUND(awg.wage_growth, 2) AS max_growth,
    awg.payroll_year AS year_of_max_growth
FROM avg_wages_growth awg
JOIN (
    SELECT industry, MAX(wage_growth) AS max_growth
    FROM avg_wages_growth
    GROUP BY industry
) mg ON awg.industry = mg.industry AND awg.wage_growth = mg.max_growth;

-- Největší meziroční pokles průměrné mzdy
SELECT 
    awg.industry,
    ROUND(awg.wage_growth, 2) AS max_drop,
    awg.payroll_year AS year_of_max_drop
FROM avg_wages_growth awg
JOIN (
    SELECT industry, MIN(wage_growth) AS max_drop
    FROM avg_wages_growth
    GROUP BY industry
) md ON awg.industry = md.industry AND awg.wage_growth = md.max_drop;

/*
 *  Mzdy ve všech odvětvích rostou. Ale v každém odvětví jsme během sledovaného období v letech 2006-2018 zaznamenali pokles průměrné mzdy.
 *  Největší pokles mzdy jsme zaznameli v sektoru "Peněžnictví a pojišťovnictví" v roce 2013 a "Zemědělství, lesnictví, rybářství" v roce 2018. 
 *  Největší nárůst mzdy jsme zaznamenali v sektoru "Zemědělství, lesnictví, rybářství" v roce 2017 a v "Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu"
 *  v roce 2008.
 */
