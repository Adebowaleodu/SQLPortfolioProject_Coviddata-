--Import CovidDeaths data
Select *
FROM PortfolioProject..CovidDeaths
Order by 3,4 

--Import CovidVaccinations data
Select *
From PortfolioProject.dbo.CovidVaccinations
Order by 3,4


--Select Data to be used
Select Distinct(Location), date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order by 1,2

--Total Cases vs Total Deaths
--Likelihood of dying if you contract covid in your country (Considering United States)

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date, population total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2


--Showing countries with highest Infection rate
Select location, MAX(total_cases) as InfectionCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not NULL
Group by location
Order by InfectionCount desc


--showing Countries with Highest Death Count
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not NULL
Group by location
Order by TotalDeathCount desc


--Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, Population
Order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population
Select Location, population, MAX(cast(total_deaths as int)) as _TotalDeathCount, MAX(cast(total_deaths as int)/population)*100 as _PercentPopulationDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, Population
Order by _PercentPopulationDeathCount desc




--BREAKING THINGS UP BY CONTINENT

--Showing Continents with Highest Infection rate
Select continent, MAX(total_cases) as SumInfectionCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not Null
Group by continent
Order by SumInfectionCount desc


--showing Continent with Highest Death Count
Select continent, MAX(cast(Total_deaths as int)) as SumDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not Null
Group by continent
Order by SumDeathCount desc



--GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
Order by 1,2

--Looking at World data(Total Cases, Total Deaths & DeathPercentage)
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date
Order by 1,2


--Joining CovidDeaths data and CovidVaccination data on Location and data 
Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	and dea.date = vac.date

--Looking at Total Population vs Vaccination (Total number of people in the world that has been vaccinated)
Select dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for visualizations

Create View PercentPopulationVaccinated_ as
Select dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated_