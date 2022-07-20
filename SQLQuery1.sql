SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccination
--ORDER BY 3,4

-- Data being used


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2


-- Total Deaths against Total Cases
-- Chances of death per day in Singapore
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Singapore%'
WHERE continent is not null
ORDER BY 1, 2


-- Total Deaths against Population
-- Pecentage of population that gotten covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Singapore%'
WHERE continent is not null
ORDER BY 1, 2


-- Countries with highest infection rates against Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Singapore%'
WHERE continent is not null
GROUP BY Location, population
ORDER BY 1, 2


-- Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_cases as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Singapore%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc


-- Continent with Highest Death Count per Population
SELECT continent, MAX(cast(total_cases as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Singapore%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Singapore%'
WHERE continent is not null
GROUP BY date 
ORDER BY 1, 2


-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location, dea.date) as PeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE (common table expression) , temp named table in this case 'PeopleVaccinated'
WITH PopvsVac(Continent, location, date, Population, new_vaccinations, PeopleVaccinated) 
AS 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location, dea.date) as PeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT *, (PeopleVaccinated/Population) *100 as percentage_pplVaccinated
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopVaccinated -- in a scenario where there's new data to insert, a drop is needed to re-create the table as the table is already in the database with old data.
CREATE TABLE #PercentPopVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)
INSERT INTO #PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location, dea.date) as PeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
SELECT *, (PeopleVaccinated/Population) *100 as percentage_pplVaccinated
FROM #PercentPopVaccinated


-- Creating View to store data for later visualizations
CREATE VIEW PercentPopVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location, dea.date) as PeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT 8
FROM PercentPopVaccinated