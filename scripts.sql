-- p2 нормалізація

USE pandemic;

DROP TABLE IF EXISTS entities;
CREATE TABLE entities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(255) NOT NULL,
    code VARCHAR(10),
    UNIQUE (entity, code)
    );

INSERT INTO entities (entity, code)
select distinct Entity, nullif(Code, '')
from infectious_cases;

DROP TABLE IF EXISTS infectious_cases_normalized;
CREATE TABLE infectious_cases_normalized (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_id INT NOT NULL,
    year INT NOT NULL,
    number_yaws DOUBLE,
    polio_cases DOUBLE,
    cases_guinea_worm DOUBLE,
    number_rabies DOUBLE,
    number_malaria DOUBLE,
    number_hiv DOUBLE,
    number_tuberculosis DOUBLE,
    number_smallpox DOUBLE,
    number_cholera_cases DOUBLE,
    FOREIGN KEY (entity_id) REFERENCES entities(id)
    );

INSERT INTO infectious_cases_normalized (
    entity_id,
    year,
    number_yaws,
    polio_cases,
    cases_guinea_worm,
    number_rabies,
    number_malaria,
    number_hiv,
    number_tuberculosis,
    number_smallpox,
    number_cholera_cases
)
select
    e.id,
    ic.Year,
    CAST(NULLIF(ic.Number_yaws, '') AS DOUBLE),
    CAST(NULLIF(ic.polio_cases, '') AS DOUBLE),
    CAST(NULLIF(ic.cases_guinea_worm, '') AS DOUBLE),
    CAST(NULLIF(ic.Number_rabies, '') AS DOUBLE),
    CAST(NULLIF(ic.Number_malaria, '') AS DOUBLE),
    CAST(NULLIF(ic.Number_hiv, '') AS DOUBLE),
    CAST(NULLIF(ic.Number_tuberculosis, '') AS DOUBLE),
    CAST(NULLIF(ic.Number_smallpox, '') AS DOUBLE),
    CAST(NULLIF(ic.Number_cholera_cases, '') AS DOUBLE)
from infectious_cases ic
join entities e on ic.Entity = e.entity and nullif(ic.Code, '') <=> e.code;


-- p3 

USE pandemic;

SELECT 
entity_id,
avg(number_rabies) as avg_number_rabies,
min(number_rabies) as min_number_rabies,
max(number_rabies) as max_number_rabies,
sum(number_rabies) as sum_number_rabies
FROM infectious_cases_normalized
where number_rabies is not null
group by 1
order by avg_number_rabies desc
limit 10


-- p4

USE pandemic;

SELECT 
year,
MAKEDATE(year, 1) as date_,
current_date,
TIMESTAMPDIFF(year, MAKEDATE(year,1), current_date) as year_diff
FROM infectious_cases_normalized


-- p5

USE pandemic;

DROP FUNCTION IF EXISTS year_diff_func;

DELIMITER //

CREATE FUNCTION year_diff_func(input_year INT)
RETURNS INT
DETERMINISTIC
NO SQL
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, MAKEDATE(input_year, 1), current_date);
END //

DELIMITER ;

SELECT
    `year`,
    year_diff_func(`year`) AS year_diff
FROM infectious_cases_normalized
