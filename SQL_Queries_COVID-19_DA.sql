Select location, date, total_cases, new_cases, total_cases, population 
from PortfolioProject..CovidDeaths
order by 1,2

----- Looking at total cases vs total deaths 
------ Shows likelihood of dying 

Select location, date, total_cases, total_cases, (total_deaths/total_cases)*100 as DeathPercent
from PortfolioProject..CovidDeaths
where location like '%Costa Rica%'
order by 1,2

-------Looking at total cases vs population 

Select location, date, total_cases, population, (total_cases/population)*100 as PopulationInfected
from PortfolioProject..CovidDeaths
where location like '%Costa Rica%'
order by 1,2

-----------Looking at countries with highest infections rates compared to population 

Select location, MAX(total_cases) AS HighestIngfectionCount, population, max((total_cases/population))*100 as PopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%Costa Rica%'
group by location, population
order by PopulationInfected desc

---- Looking the countries highest death counts per population 


Select location, Max(cast(total_deaths as int)) as  TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not NULL
group by location
order by TotalDeathCount desc

--Lets break things down by continent 

Select location, Max(cast(total_deaths as int)) as  TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is NULL
group by location
order by TotalDeathCount desc

---- Showing continents with highest death count 

Select continent, Max(cast(total_deaths as int)) as  TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not NULL
group by continent
order by TotalDeathCount desc

--- Global numbers 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not Null 
group by date
order by 1,2

--- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioProject .. CovidDeaths dea 
join PortfolioProject .. CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null
order by 2,3

--- CTE 

with PopvsVac (Continent, Location, Date, Population, New_Vaccionations, RollingPeopleVaccinated)

as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From PortfolioProject .. CovidDeaths dea 
join PortfolioProject .. CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100

from PopvsVac

-- Temp table 

Drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccionations numeric, 
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From PortfolioProject .. CovidDeaths dea 
join PortfolioProject .. CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not Null 
group by date
order by 1,2

-- Creating view to store data for later visualizacions 

Create view PercentPopulationVaccinated as 
Select continent, Max(cast(total_deaths as int)) as  TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not NULL
group by continent
--order by TotalDeathCount desc