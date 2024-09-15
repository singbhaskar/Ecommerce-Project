create database projects;

USE projects;

SELECT * FROM hr;

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hr;

SELECT birthdate FROM hr;

SET sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE 
  WHEN birthdate LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
  WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
  ELSE NULL
END;
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

SELECT birthdate from hr;

UPDATE hr
SET hire_date  = CASE 
  WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
  WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
  ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

UPDATE hr
SET termdate = CASE
    WHEN termdate IS NULL OR termdate = '' THEN '0000-00-00'
    ELSE DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
END;

SELECT termdate
FROM hr
WHERE termdate = '0000-00-00' OR termdate IS NULL;

UPDATE hr
SET termdate = NULL
WHERE termdate = '0000-00-00';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

DESCRIBE hr;

SELECT termdate from hr;

ALTER TABLE hr ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR,birthdate, CURDATE());

SELECT 
   MIN(age) AS youngest,
   MAX(age) AS oldest
 FROM hr;
 
SELECT COUNT(*) FROM hr WHERE age < 18;
-- QUESTIONS 
-- 1 what is the gender breakdown of employees in the company ?
SELECT gender,count(*)AS count 
FROM hr
WHERE age >=18 and termdate is NULL
GROUP BY gender;

-- 2 WHat is race/ethnicity breakdown of employees in the company ?
SELECT race, COUNT(*) AS COUNT
FROM hr
WHERE age >= 18 AND termdate is NULL
GROUP BY race
ORDER BY COUNT(*) DESC;

-- 3 What is the age distribution of employees in the company ?
SELECT 
   min(age) AS youngest,
   max(age) AS oldest
FROM hr
WHERE age >= 18 AND termdate is NULL;

SELECT 
   CASE 
     WHEN age >= 18 AND age <=24 THEN '18-24'
     WHEN age >=25 AND age <=34 THEN '25-34'
     WHEN age >=35 AND age <=44 THEN '35-44'
     WHEN age >=45 AND age <=54 THEN '45-54'
     WHEN age >=55 AND age <=64 THEN '55-64'
     ELSE '65+'
    END as age_group,
    COUNT(*) AS count
 FROM hr
 WHERE age >= 18 AND termdate is NULL
 GROUP BY age_group
 ORDER BY age_group;
 
 SELECT 
   CASE 
     WHEN age >= 18 AND age <=24 THEN '18-24'
     WHEN age >=25 AND age <=34 THEN '25-34'
     WHEN age >=35 AND age <=44 THEN '35-44'
     WHEN age >=45 AND age <=54 THEN '45-54'
     WHEN age >=55 AND age <=64 THEN '55-64'
     ELSE '65+'
    END as age_group, gender,
    COUNT(*) AS count
 FROM hr
 WHERE age >= 18 AND termdate is NULL
 GROUP BY age_group, gender
 ORDER BY age_group, gender;
 -- 4 How many employees work at headquarters versus remote locations ?
 SELECT location, count(*) AS count
 FROM hr
 WHERE age >= 18 AND termdate is NULL
 GROUP BY location;
 
 -- 5 What is the average length of employment for employees who have been terminated ?
 SELECT 
    round(avg(datediff(termdate, hire_date))/365,0)AS avg_length_employment
 From hr
 WHERE termdate <= curdate() AND termdate is not null and age >= 18;
 
 -- 6 How does the gender distribution vary across departments and job titles?
 SELECT department,gender, count(*) as count
 from hr
 WHERE age >= 18 AND termdate is NULL
 group by department,gender
 order by department;
 
 -- 7 What is distribution of job titles across company?
 Select jobtitle, count(*) as count
 from hr
 WHERE age >= 18 AND termdate is NULL
 group by jobtitle 
 order by jobtitle DESC;
 
 -- 8 which department has the highest turnover rate ?
 
 SELECT department,
      total_count,
      terminated_count,
      terminated_count/total_count as termination_rate
 From (
      select department,
      count(*) as total_count,
      SUM(CASE WHEN termdate is not null and termdate <= curdate() THEN 1 ELSE 0 END) as terminated_count
      FROM hr
      WHERE age >=18
      group by department
      ) as subquery
 order by termination_rate desc;
 
 -- 9 what is the distribution of employees across locations by city and state ?
 Select location_state, count(*) as count
 from hr
 WHERE age >= 18 AND termdate is NULL
 group by location_state
 order by count desc;
 
 -- 10 How has the company's employee count changed over time based on hire and term dates ?
 select 
  year,
  hires,
  terminations,
  hires-terminations as net_change,
  round((hires-terminations/hires)*100,2) as net_change_percent
 from (
       select 
           year(hire_date) as year,
		   count(*) as hires, 
		   SUM(CASE WHEN termdate is not null and termdate <= curdate()THEN 1 ELSE 0 END) AS terminations
		   From hr
		   where age >= 18
		   group by year(hire_date)
           ) as subquery 
  order by year asc;
  
  -- 11 What is the tenure distribution for each department?
  select department, round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
  from hr 
  where termdate <= curdate() and termdate is not null and age >=18
  group by department;
  
