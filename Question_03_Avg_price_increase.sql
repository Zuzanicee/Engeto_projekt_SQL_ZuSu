/*
 * 	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 */

-- nejdřívě zjistíme cenu pro jednotlivé kategorie v daném roce
CREATE OR REPLACE VIEW food_price_increase AS
SELECT
	food_category AS category,
	rounding_value AS value,
	rounding_unit AS unit,
	payroll_year AS year_pay,
	round(avg(price), 2) AS avg_price
FROM t_zuzana_suchankova_project_sql_primary_final
GROUP BY
	category,
	year_pay;


-- zjsitila jsem, že chybí validní data pro Jakostní víno bíle do roku 2015, můžeme srovnávat ceny pouze za období 2016-2018, 
-- proto ho do průzkumu nebudu dále zahrnovat

-- v další tabulce si vytvořím pohled pro zjištění meziročního procentuálního nárůstu

CREATE OR REPLACE VIEW food_price_increase_avg_year AS
SELECT
	fpi.category, 
	fpi.year_pay,
	fpi2.year_pay  AS year_previous,
	ROUND ((fpi.avg_price - fpi2.avg_price) / fpi2.avg_price * 100, 2) AS avg_price_increase
FROM food_price_increase fpi 
JOIN food_price_increase fpi2 
	ON fpi.category = fpi2.category 
	AND fpi.year_pay = fpi2.year_pay + 1;



-- v dalším pohledu si zobrazím celkový nárůst během sledovaného období, včetně ceny na začátku a na konci sledvaného období

CREATE OR REPLACE VIEW avg_price_total AS
SELECT	category,
	SUM(avg_price_increase)
FROM food_price_increase_avg_year
GROUP BY category;

CREATE OR REPLACE VIEW price_2006 AS
SELECT *
FROM food_price_increase fpi
WHERE year_pay = '2006';

CREATE OR REPLACE VIEW price_2018 AS
SELECT *
FROM food_price_increase fpi
WHERE year_pay = '2018';

CREATE OR REPLACE VIEW category_price_increase AS
SELECT
	apt.category,
	apt.`SUM(avg_price_increase)` AS avg_price_tot,
	p.year_pay AS year_start,
	p.avg_price AS price_start,
	p2.year_pay AS year_end,
	p2.avg_price AS price_end 
FROM avg_price_total apt
JOIN price_2006 p 
	ON apt.category = p.category 
JOIN price_2018 p2
	ON apt.category = p2.category
ORDER BY apt.`SUM(avg_price_increase)`;

CREATE OR REPLACE VIEW min_year_inc AS
SELECT
	category,
	year_pay,
	MIN(avg_price_increase) AS min_value
FROM food_price_increase_avg_year
GROUP BY category;


SELECT *
FROM category_price_increase
ORDER BY avg_price_tot ASC
LIMIT 5;

/*
 *  Z vytvořených pohledů na data jsem zjistila, že jsou kategorie potravin, které neježe nezdražují, ale dokonce i za sledované období zlevnily. Cukr krystalový zlevnil 
 *  za sledované období nejvíce. 
 *  Hned za cukrem zlevňují také Rajská jablka červená kulatá.
 *  Za sledované období nejpomaleji zdražují Banány žluté.
 */
