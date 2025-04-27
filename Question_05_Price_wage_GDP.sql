/*
 * 	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách 
 *  potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
 */

-- zjistíme meziroční růst HDP v ČR a propojíme s výsledky měření z předchozí otázky

CREATE OR REPLACE VIEW cz_gdp AS
SELECT
	country,
	`year`,
	GDP
FROM t_zuzana_suchankova_project_sql_secondary_final
WHERE country = 'Czech Republic';

CREATE VIEW gdp_year AS
SELECT
	cg.`year` AS gdp_year_before,
	cg.GDP AS gdp_before,
	cg2.`year` AS gdp_year_current,
	cg2.GDP AS gdp_current,
	ROUND((cg2.GDP - cg.GDP) / cg2.GDP * 100, 2) AS gdp_difference 
FROM cz_gdp cg
JOIN cz_gdp cg2 
	ON cg.country = cg2.country
	AND cg2.`year` = cg.`year` + 1
GROUP BY cg.`year`;

CREATE OR REPLACE VIEW gdp_price_wage_trends AS
SELECT
	gdp.gdp_year_current AS year,
	gdp.gdp_difference,
	wage.year_current,
	wage.wage_difference,
	price.f_year_current,
	price.price_difference
FROM gdp_year gdp
JOIN avg_wage_year_increase wage 
	ON gdp.gdp_year_current = wage.year_current
JOIN year_avg_price_increase price 
	ON gdp.gdp_year_current = price.f_year_current;

SELECT *
FROM gdp_price_wage_trends
ORDER BY year;


/*
 *	Významný růst HDP jsme zaznamenali v letech 2007, 2015 a 2017.
 *	V roce 2007 vzrostlo HDP o 5,28%, zaznamenali jsme růst cen potravin o 6,74% a mezd o 7,59% v následujícím roce pak ceny potravin vzrostly o 6,19% a mzdy o 10,47%.
 *	V roce 2015 vzrostlo HDP o 5,11% zaznamenali jsme naopak pokles cen potravin o -0,54% a růst mezd o 1,53%, a v následujícím roce ceny potravin klesly o -1,21% a mzdy vzrostly o 7,33%
 * 	Na základě zjištěných dat nelze s jistotou potvrdit přímy vliv růstu HDP na ceny potravin a výšku mezd.
 * /
