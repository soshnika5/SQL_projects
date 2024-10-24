-- Data Cleaning: 4 tasks
-- 1) Remove duplicates
-- 2) Standardize the data - issues with spellings, etc
-- 3) Null or blank values -- see we can populate it
-- 4) Remove any columns

-- Lets start by creating a working table -- a copy of the raw data and insert it into the new one
-- if you make a mistake in working table, it wouldn't effect the original
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-------------------------------------------------------------------------------------------------------
-- 1) REMOVING DUPLICATES
-------------------------------------------------------------------------------------------------------
-- since we dont have any unique ids, we are going to use row_number to match against all columns to search for duplicates
select *,
row_number() over(
	partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;
-- here we want to filter anything that has row_number > 1

with duplicates_cte as (
select *,
row_number() over(
	partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
SELECT *
from duplicates_cte
where row_num > 1;
-- multiple potential entries for duplicates, but lets take a look at them closer

select *
from layoffs_staging
where company = 'Casper';
-- 1 and 3rd rows are duplicates

delete
from duplicate_cte
where row_num >1;
-- unfortunately this method doesn't work because delete is like an update, therefore, we will create a new table with extra column corresponding to row_num

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

SET SQL_SAFE_UPDATES = 0;

delete
from layoffs_staging2
where row_num > 1;

select *
from layoffs_staging2
where row_num > 0;

-- 2) Standardizing data -- finding issues and fixing it.
select distinct(company)
from layoffs_staging2;

-- trimming
select distinct(trim(company))
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct(industry)
from layoffs_staging2
order by 1;
-- notice that crypto, crypto currency, etc are the same industry

select *
from layoffs_staging2
where industry like '%crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like '%crypto%';

select distinct(location)
from layoffs_staging2
order by 1;

select distinct(country)
from layoffs_staging2
order by 1;
-- needs to be trimmed with trail

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

select *
from layoffs_staging2;

-------------------------------------------------------------------------------------------------------
-- 2) Standardize the data - issues with spellings, date, etc
-------------------------------------------------------------------------------------------------------
select `date`
from layoffs_staging2;

-- lets reformat date with month, day, year format
select `date`,
str_to_date(`date`, '%m/%d/%Y') as ref_date
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

-- changing the type of date column
alter table layoffs_staging2
modify column `date` DATE;

-------------------------------------------------------------------------------------------------------
-- 2) Null or blank values
-------------------------------------------------------------------------------------------------------
select *
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

select *
from layoffs_staging2
where industry is null or industry='';

select *
from layoffs_staging2
where company = 'Airbnb';
-- some entries are blank, even though the correct industry is Travel. Therefore, we need to populate it correctly

-- first we will convert blanks to null
update  layoffs_staging2
set industry = null
where industry = '';

-- using self-join to search for correct industry
select t1.company, t1.industry, t2.company, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '') and t2.industry is not null;
-- Juul, carvana, and airbnb dont have populated industries

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company=t2.company and t1.location=t2.location
set t1.industry=t2.industry
where t1.industry is null and t2.industry is not null;

select *
from  layoffs_staging2
where industry is null;
-- looks like Bally's has an issue

select *
from layoffs_staging2
where company like 'Bally%';
-- sole example

-- looking at data where both total laid off and % are null
select *
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

delete 
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

-------------------------------------------------------------------------------------------------------
-- 4) Remove any columns
-------------------------------------------------------------------------------------------------------
alter table layoffs_staging2
drop column row_num;

select *
from layoffs_staging2;


















