select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths;

-- Total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location like '%states%'
order by 1,2;

-- Total cases vs population: percentage of population got COVID
select location, date, total_cases, population, (total_deaths/population)*100 as PercentPopulationInfected
from coviddeaths
where location like '%states%'
order by 1,2; 

-- Countries w/Highest Infection Rate compared to population
select location, date, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from coviddeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc; 

-- Countries with Highest Death Count per Population
select location, max(total_deaths) as TotalDeathsCount
from coviddeaths
where continent is not null
group by location
order by TotalDeathsCount desc; 

-- Highest Death count by continent
select continent, max(total_deaths) as TotalDeathCount
from coviddeaths
-- where continent is null or continent !=' '
group by continent
order by totaldeathcount desc;

-- total cases, death, and death percentage by date
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from coviddeaths
group by date
order by 1,2 desc;

------------------------------------------------------------------------------------------------------------
-- Joining deaths and vaccinations tables
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent !=''
order by 2,3;

-- Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent !=''
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query
with PopVsVac(continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent !=''
-- order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as RS_Vac_Pop
from PopVsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query
drop table if exists PercentPopulationVaccinated;
CREATE TABLE `PercentPopulationVaccinated`
(
`Continent` varchar(255),
`Location` varchar(255),
`Date` text,
`Population` int,
`New_vaccinations` int,
`RollingPeopleVaccinated` int
);

select *
from PercentPopulationVaccinated;

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
;
Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;


