SELECT location, date, total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2


-- looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY DeathPercentage DESC


--looking at Total cases vs Population
-- Show what percentage of population got Covid

SELECT location, date, total_cases,population,(total_cases/population)*100 AS PopulationPercentageInfected
FROM CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2



-- Looking at Countries with Highest infection Rate Compared to Population

SELECT location,population , MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PopulationPercentageInfected
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY location,population
ORDER BY  PopulationPercentageInfected DESC 


-- countries with highest death count per population

SELECT location,population, MAX(cast(total_deaths AS INT)) AS Total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY  Total_death_count DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths AS INT)) AS Total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  Total_death_count DESC


-- showing continents with highest death count per population

SELECT continent, MAX(cast(total_deaths AS INT)) AS Total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  Total_death_count DESC


-- GLOBAL NUMBERS

SELECT  SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS INT)) AS total_deaths,SUM(CAST(new_deaths AS INT))/SUM(New_cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

SELECT date, SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS INT)) AS total_deaths,SUM(CAST(new_deaths AS INT))/SUM(New_cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- showing total population vs Vaccinations

SELECT  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
      SUM(Convert(int,vac.new_vaccinations )) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/POPULATION)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- USE CTE

WITH PopVsVac (Continent,location,date,population,New_Vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
      SUM(Convert(int,vac.new_vaccinations )) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/POPULATION)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

)

SELECT *,(RollingPeopleVaccinated/population)*100 FROM  PopVsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population  numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO  #PercentPopulationVaccinated
SELECT  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
      SUM(Convert(int,vac.new_vaccinations )) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/POPULATION)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;


SELECT *,(RollingPeopleVaccinated/population)*100
FROM   #PercentPopulationVaccinated



-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS


CREATE VIEW PercentPopulationVaccinated AS
SELECT  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
      SUM(Convert(int,vac.new_vaccinations )) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/POPULATION)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;


SELECT * FROM PercentPopulationVaccinated

