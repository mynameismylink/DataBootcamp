SELECT * FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,5

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
and continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total cases vs Population
SELECT location, date, population, total_cases,(total_cases/population)*100 as InfectionRate
FROM CovidDeaths
WHERE location like '%states%'
and continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, ((MAX(total_cases))/population)*100 as HighestInfectionRate
FROM CovidDeaths
WHERE continent IS NOT NULL
Group by location, population
ORDER BY HighestInfectionRate DESC

-- Looking at Countries with Highest Death Rate compared to Population
SELECT location, population, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
Group by location, population
ORDER BY TotalDeathCount DESC

-- Break things down by continent
SELECT location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null
Group by location
ORDER BY TotalDeathCount DESC

--------
-- USE CTE

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)

SELECT Location, Population, MAX(RollingPeopleVaccinated/population)*100 as RollingVacRate
From PopvsVac
WHERE Location = 'Albania'
GROUP BY Location, Population

-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT Location, Population, MAX(RollingPeopleVaccinated/population)*100 as RollingVacRate
From #PercentPopulationVaccinated
--WHERE Location = 'Albania'
GROUP BY Location, Population


CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

Select *
from PercentPopulationVaccinated
