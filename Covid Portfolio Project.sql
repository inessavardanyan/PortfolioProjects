SELECT *
FROM [PortfolioProject_Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM [PortfolioProject_Data Exploration]..CovidVaccinations
--order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject_Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, 
	(total_deaths/total_cases) * 100 AS DeathPercentage    
FROM [PortfolioProject_Data Exploration]..CovidDeaths
WHERE location like 'Armenia'
	AND continent IS NOT NULL
ORDER BY 1, 2 


-- Looking at Total Cases vs Population
-- Shows what percentage of popuplation got Covid

SELECT Location, date, Population, total_cases, 
	(total_cases/population) * 100 AS InfectedPopulationPerentage
FROM [PortfolioProject_Data Exploration]..CovidDeaths
WHERE location like 'Armenia'
	AND continent IS NOT NULL
ORDER BY 1, 2 


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, 
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM [PortfolioProject_Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Looking at Countries with Highest Death Count per Population

SELECT Location,
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [PortfolioProject_Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC



-- Let's break down by continent

-- Showing continents with the Highest Death Count

SELECT location,
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [PortfolioProject_Data Exploration]..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent,
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [PortfolioProject_Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases) AS death_percentage
FROM [PortfolioProject_Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2 


-- Looking at Total Population vs Vaccinations

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	SUM(CONVERT(INT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM [PortfolioProject_Data Exploration]..CovidDeaths AS Dea
JOIN [PortfolioProject_Data Exploration]..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2, 3


-- USING CTE

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	SUM(CONVERT(INT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM [PortfolioProject_Data Exploration]..CovidDeaths AS Dea
JOIN [PortfolioProject_Data Exploration]..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
-- ORDER BY 2, 3
) 
SELECT *, 
	(RollingPeopleVaccinated/Population) * 100 AS VacPeoplePercentage
FROM PopVsVac


-- USING TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	SUM(CONVERT(INT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM [PortfolioProject_Data Exploration]..CovidDeaths AS Dea
JOIN [PortfolioProject_Data Exploration]..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *, 
	(RollingPeopleVaccinated/Population) * 100 AS VacPeoplePercentage
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	SUM(CONVERT(INT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM [PortfolioProject_Data Exploration]..CovidDeaths AS Dea
JOIN [PortfolioProject_Data Exploration]..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL



SELECT *
FROM PercentPopulationVaccinated



CREATE VIEW DeathsLikelihood AS
SELECT Location, date, total_cases, total_deaths, 
	(total_deaths/total_cases) * 100 AS DeathPercentage    
FROM [PortfolioProject_Data Exploration]..CovidDeaths
WHERE location like 'Armenia'
	AND continent IS NOT NULL


