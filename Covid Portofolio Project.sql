
select * 
from PortfolioProject..CovidDeaths
where continent != ''
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4


-- Select Data that we are going to using

Select Location, date, total_cases, new_cases, total_deaths, Population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at total cases vs Total deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'Indonesia'
order by 1,2


-- Loking at Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
where location like 'Indonesia'
order by 1,2


-- Looking at countries with the highest infection rate compared to population

Select Location, Population, max(total_cases) as HighestInfectionCount, max(total_cases/Population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like 'Indonesia'
group by location, Population
order by 4 desc


-- Showing countriees with the highest death count per population

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'Indonesia'
where continent != ''
group by location
order by 2 desc


-- Continent death count

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'Indonesia'
where continent = ''
group by location
order by 2 desc


-- Showing continents 

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'Indonesia'
where continent != ''
group by continent
order by 2 desc


-- Global numbers

Select date,
	sum(new_cases) as total_cases,
	sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent != ''
group by date
order by 1,2

Select --date,
	sum(new_cases) as total_cases,
	sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent != ''
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations,
	sum(convert(float, vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--order by 2,3


-- Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccionations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations,
	sum(convert(float, vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
from PopvsVac
--where location like 'Indonesia'



-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population decimal,
New_Vaccinations decimal,
RollingPeopleVaccinated decimal,
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations,
	sum(convert(float, vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
from #PercentPopulationVaccinated
--where location like 'Indonesia'


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations,
	sum(convert(float, vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--order by 2,3

select * 
from PercentPopulationVaccinated