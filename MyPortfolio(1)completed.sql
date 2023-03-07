--Our important data

SELECT location, date, new_cases, total_cases, total_deaths, population
FROM MyPortfolio..CovidDeaths
ORDER BY 1,2

--1. Total cases vs Total deaths

--The probability of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM MyPortfolio..CovidDeaths
WHERE location = 'Spain'
ORDER BY 1,2

--2. Total cases vs population

--What percentage of population got infected by covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS CovidPercentage
FROM MyPortfolio..CovidDeaths
WHERE location = 'Spain'
ORDER BY 1,2

-- Countries with Highest Infection Rate
SELECT location, MAX(total_cases) AS HighestInfCount, population, MAX((total_cases/population))*100 AS CovidPercentage
FROM MyPortfolio..CovidDeaths
GROUP BY Location, population
ORDER BY CovidPercentage DESC 

-- Countries with Highest Death Rate and countries with the Highest Death Count
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount, population, MAX((total_deaths/total_cases))*100 AS DeathPercentage
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT Null
GROUP BY Location, population
--ORDER BY DeathPercentage DESC
ORDER BY TotalDeathCount DESC 

--Continents with Highest Death Rate and continents with the Highest Death Count
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount, population, MAX((total_deaths/total_cases))*100 AS DeathPercentage
FROM MyPortfolio..CovidDeaths
WHERE continent IS Null
GROUP BY location, population
ORDER BY DeathPercentage DESC
--ORDER BY TotalDeathCount DESC 

-- Numbers all over the world
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(New_deaths AS int))/SUM(New_cases)*100 AS DeathPercentage
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT Null
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CAST(new_vaccinations AS int)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated,
(RollingPeopleVaccinated/D.population)*100 AS VaccinatedPercentage
FROM MyPortfolio..CovidDeaths D INNER JOIN MyPortfolio..CovidVaccinations V
	ON D.location = V.location 
	and D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 2,3


WITH Pop_Vs_Vac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CAST(new_vaccinations AS int)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/D.population)*100 AS VaccinatedPercentage
FROM MyPortfolio..CovidDeaths D INNER JOIN MyPortfolio..CovidVaccinations V
	ON D.location = V.location 
	and D.date = V.date
WHERE D.continent IS NOT NULL
)
SELECT *
FROM Pop_Vs_Vac

--CREATING VIEW FOR LATER

CREATE VIEW PercentPopulationVaccinated AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CAST(new_vaccinations AS int)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/D.population)*100 AS VaccinatedPercentage
FROM MyPortfolio..CovidDeaths D INNER JOIN MyPortfolio..CovidVaccinations V
	ON D.location = V.location 
	and D.date = V.date
WHERE D.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated