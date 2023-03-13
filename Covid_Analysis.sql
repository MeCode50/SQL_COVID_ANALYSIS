
-- let's convert our date colun from str to date
-- update CovidDeaths set date = STR_TO_DATE(date, "%m/%d/%Y");
-- select * from CovidDeaths;

 -- change the empty string column to display null
update CovidDeaths set  total_deaths = NULLIF(total_deaths, '');
select * from CovidDeaths;

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM portfolio_project.CovidDeaths
order by 1,2 ;

-- total cases vs total deaths 
-- Number of people who died of Covid in Nigeria
SELECT location,date, total_cases,total_deaths, (total_deaths / total_cases)*100  as DeathPercentage
FROM portfolio_project.CovidDeaths
where location like '%Nigeria%'
order by 1,2;

-- looking at total cases vs population in Nigeria
-- What % of population got Covid in Nigeria
SELECT location,date, total_cases,population, (total_cases / population)*100  as PercentaPopulationInfected
FROM portfolio_project.CovidDeaths
WHERE location like '%Nigeria%'
order by 1,2;

-- countries with highest inflation rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population))*100  as 
PercentaPopulationInfected
FROM portfolio_project.CovidDeaths
-- WHERE location like '%Nigeria%'
GROUP BY continent
order by PercentaPopulationInfected desc;

-- COUNTRIES WITH HIGHEST DEATH COUNTS
select location, MAX(cast(total_deaths as unsigned)) as TotalDeathCount
FROM portfolio_project.CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- HIGHEST NUMBER OF DEATHS  BY CONTINENTS
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM portfolio_project.CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount;

-- total number of people who died in the world
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as unsigned)) as total_deaths, 
SUM(cast(new_deaths as unsigned))/SUM(new_cases)*100
as DeathPercentage
FROM portfolio_project.CovidDeaths
where continent is not null
order by 1,2;

-- total number of population vs those who got vaccinated
with popvac (Continent, Location, Date, Population, New_Vaccinations,RollingPeople)
as(
select  dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as unsigned)) OVER (partition by location order by dea.location, dea
.date) as RollingPeople
from portfolio_project.CovidDeaths dea
join portfolio_project.CovidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeople / Population) * 100
from popvac;

-- let"s create a view

create view PercentPopulationVaccinated as
select  dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as unsigned)) OVER (partition by location order by dea.location, dea
.date) as RollingPeople
from portfolio_project.CovidDeaths dea
join portfolio_project.CovidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null;

SHOW STATUS;