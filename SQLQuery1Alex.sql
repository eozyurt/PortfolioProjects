--TEST
SELECT *
FROM [Portfolio Project]..CovidDeaths$


--SELECT DATA THAT WE ARE GOING TO BE USING and use "SELECT","FROM" and "ORDER BY "

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [Portfolio Project]..CovidDeaths$
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATH WHERE USING "Calculated Fields", "AS function" and "WHERE function".

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE location like '%kingdom%'
AND continent is not null
ORDER BY 1,2

--LOOKING AT TOTAL CASES AND POPULATION-what percentage of population got covid?
SELECT location,date,population,total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths$
WHERE location like '%kingdom%'
ORDER BY 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION USING MIN()- MAX() - ascending or descending orders in  "GROUP BY" Functions
SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%kingdom%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--LOOKING AT COUNTRIES WITH HIGHEST DEATH COUNT per population changing DATA type from VAR to Int using "CAST"  AND "IS NOT NULL" functions.

SELECT location,MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--BREAKING THINGS DOWN BY Location & Continent 

SELECT location,MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC 



--SHOWING THE CONTINTENTS WITH THE HIGHEST DEATH COUNT PER POPULATION.


SELECT continent,MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS PER DAYS
SELECT date,SUM(new_cases) AS TotalCASES,SUM(CAST(new_deaths as INT)) AS TotalDEATHS,SUM(CAST (new_deaths as INT))/Sum(new_cases)*100 As DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--GLOBAL NUMBERS PER DAYS
SELECT SUM(new_cases) AS TotalCASES,SUM(CAST(new_deaths as INT)) AS TotalDEATHS,SUM(CAST (new_deaths as INT))/Sum(new_cases)*100 As DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--VACCINATION TABLE TEST for JOINS
SELECT *
From [Portfolio Project]..CovidVaccinations$

--JOINING THESE TABLES TOGETHER AND LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Looking at Total Population vs Vaccinations using Joins using Convert and Over functions
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location,dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
WITH PopVsVac (Continent,location,date,population,New_vaccinations,RollingPeopleVaccinated)
as 
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location,dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,(RollingPeopleVaccinated/population)*100
From PopVsVac

--Subquary creation with temp table
DROP Table if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location,dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--CREATING VIEWS to Store table FOR TABLEAU Visualizations
Create View PercentPopulationVaccinated as

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location,dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

--TEST the WORK VIEW TABLE Created.
Select *
FROM PercentPopulationVaccinated