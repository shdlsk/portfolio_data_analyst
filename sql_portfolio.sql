-- SQL Portfolio

SELECT *
FROM PortfolioProject..CovidDeath
ORDER BY 1,2;

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 1,2;

-- Select data that we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeath
ORDER BY 1,2;

-- Total cases vs. total deaths (can be filtered by country)
SELECT location, total_cases, total_deaths, SAFE_DIVIDE(total_death, total_cases) AS death_percentage
FROM PortfolioProject..CovidDeath
WHERE location LIKE '%states%'
--WHERE location IN ('Poland')
ORDER BY 1,2;

-- Total cases vs. population (% of population who got Covid)
SELECT location, total_cases, population, SAFE_DIVIDE(total_cases, population) AS death_percentage
FROM PortfolioProject..CovidDeath
-- WHERE location LIKE '%states%'
-- WHERE location IN ('Poland')
ORDER BY 1,2;

-- Countries with Highest infection rate compared to population
SELECT location, MAX(total_cases) AS highest_infection_count, population, MAX((total_cases, population)) AS perc_population_infected
FROM PortfolioProject..CovidDeath
GROUP BY 1,2
ORDER BY perc_population_infected DESC;

-- Countries with highest death rate compared to population
SELECT location, date, MAX(CAST(total_death AS int)) AS total_death_count
FROM PortfolioProject..CovidDeath
WHERE contintent IS NOT null
GROUP BY location
ORDER BY total_death_count DESC;

-- Continents with highest death count per population
SELECT continent, date, MAX(CAST(total_death AS int)) AS total_death_count
FROM PortfolioProject..CovidDeath
WHERE contintent IS NOT null
GROUP BY continent
ORDER BY total_death_count DESC;

-- Global numbers

SELECT date, 
  SUM(new_cases) AS total_cases, 
  SUM(CAST(new_deaths AS int)) AS total_death, 
  SAFE_DIVIDE(SUM(CAST(new_deaths AS int)), SUM(new_cases)) AS death_percentage
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2;


-- Total population vs. vaccination
SELECT dea continent, dea. location, dea date, dea population, vac. new_vaccinations,
  SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated,
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea. location = vac. location
AND dea date = vac. date
WHERE dea.continent IS NOT null
ORDER BY 2,3

-- USE CTE
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea continent, dea. location, dea date, dea population, vac. new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated,
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea. location = vac. location
AND dea date = vac. date
WHERE dea.continent IS NOT null
)
SELECT *, SAFE_DIVIDE(rolling_people_vaccinated, population) AS 
FROM pop_vs_vac

-- Temp table

DROP TABLE IF EXISTS #perc_population_vaccinated
CREATE TABLE #perc_population_vaccinated
  (continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  rolling_people_vaccinated numeric
  )

INSERT INTO #perc_population_vaccinated 
SELECT dea continent, dea. location, dea date, dea population, vac. new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated,
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea. location = vac. location
AND dea date = vac. date
WHERE dea.continent IS NOT null

SELECT *, SAFE_DIVIDE(rolling_people_vaccinated, population) AS 
FROM pop_vs_vac


-- Create view for storing data for later viz

CREATE VIEW perc_population_vaccinated AS
SELECT dea continent, dea. location, dea date, dea population, vac. new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated,
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea. location = vac. location
AND dea date = vac. date
WHERE dea.continent IS NOT null
