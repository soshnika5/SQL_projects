-- EXPLORATORY DATA ANALYSIS

select *
from layoffs_staging2;

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- company that had the most laidoffs
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select min(`date`), max(`date`)
from layoffs_staging2;

-- industry that had the most laidoffs
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- country that had the most laidoffs
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

-- year that had the most laidoffs
select YEAR(`date`), sum(total_laid_off)
from layoffs_staging2
group by  YEAR(`date`)
order by 2 desc;

-- stage of the company that had the most laidoffs
select stage, sum(total_laid_off)
from layoffs_staging2
group by  stage
order by 2 desc;

-- month that had the most laidoffs
select substring(`date`,1,7) as `month`, sum(total_laid_off) as tot_laid_off
from layoffs_staging2
where substring(`date`,1,7) is not NULL
group by `month`
order by 1 asc;

-- progression of layoffs (rolling sum)
with rolling_total as (
select substring(`date`,1,7) as `month`, sum(total_laid_off) as tot_laid_off
from layoffs_staging2
where substring(`date`,1,7) is not NULL
group by `month`
order by 1 asc)
select `month`, tot_laid_off, sum(tot_laid_off) over (order by `month`) as rolling_total
from rolling_total;

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select company, year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;

-- creating a query with cte where we look at the company, year, and how many people they laid off
with company_year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
) , company_year_rank as 
-- giving a rank w/another cte
(
select *, 
dense_rank() over (partition by  years order by total_laid_off desc) as ranking
from company_year
where years is not null
)
select *
from  company_year_rank
where ranking <= 5;






































