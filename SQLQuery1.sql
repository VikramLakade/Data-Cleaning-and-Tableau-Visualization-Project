select*
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at the Total Cases vs Total Deaths
--Shows liklihood of dying if you get in contact with the virus in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location like '%India%' and continent is not null
order by 1,2


--Looking at the Total Cases vs Population
--Shows what percentage of people affected by covid

select Location, date, total_cases, population, (total_cases/population)*100 as Affected_Percentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--Looking at countries with highest infection rate w.r.t population

select Location, population, max(total_cases)as HighestInfectionCount, max(total_cases/population)*100 as 
PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by Location, population 
order by PercentPopulationInfected desc

--Showing countries with Highest death count per population

select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the continents with highest death count

select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc


--GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths ,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Bar graaph for total cases

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths ,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


--Now exploring COVID Vaccination data
--Looking at total vaccination vs population


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Using CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population Numeric,
New_Vaccinations Numeric,
RollingPeopleVaccinated Numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date=vac.date
--where dea.continent is not null

select (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated
 

 --Creating View to store data for later

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

-------------------------------------------------------------------------------------------------------------------------------------------------
select *
from PercentPopulationVaccinated
-------------------------------------------------------------------------------------------------------------------------------------------------

