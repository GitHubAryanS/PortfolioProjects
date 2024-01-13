SELECT *
FROM [COVID Project]..CovidDeaths$
Where continent is not null 
Order by 3,4

--SELECT *
--FROM [COVID Project]..CovidVaccinations$
--Order by 3,4

-- Select Data that we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [COVID Project]..CovidDeaths$
Order by 1,2

--Looking for total cases vs total deaths 
--Shows likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage 
FROM [COVID Project]..CovidDeaths$
Where location = 'India'
Order by 1,2

--Looking at Total Cases VS Population 
--Shows what percentage of population got Covid

SELECT location,date,total_cases,population,(total_cases/population)*100 AS PercentOfPopulationInfected  
FROM [COVID Project]..CovidDeaths$
Where location = 'India'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) AS PercentOfPopulationInfected 
FROM [COVID Project]..CovidDeaths$
--Where location = 'India'
GROUP BY location,population
Order by PercentOfPopulationInfected Desc 

--Showing The countries with highest death count per population

SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM [COVID Project]..CovidDeaths$
--Where location = 'India'
Where continent is not null 
GROUP BY location,population
Order by TotalDeathCount Desc 

--LETS BREAK IT DOWN BY CONTINENTS 

-- SHOWING THE CONTINENTS WITH HIGHEST DEATH COUNT PER POPULSTION 

SELECT continent ,MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM [COVID Project]..CovidDeaths$
--Where location = 'India'
Where continent is not null 
GROUP BY continent
Order by TotalDeathCount Desc 


--GLOBAL NUMBERS

SELECT date,SUM(new_cases) as Total_Cases, SUM(cast(new_deaths AS int))as Total_Deaths, (SUM(cast(new_deaths AS int))/SUM(new_cases))*100 as DeathPercentage
FROM [COVID Project]..CovidDeaths$
--Where location = 'India'
Where continent is not null 
GROUP BY date
ORDER BY 1,2 

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths AS int))as Total_Deaths, (SUM(cast(new_deaths AS int))/SUM(new_cases))*100 as DeathPercentage
FROM [COVID Project]..CovidDeaths$
--Where location = 'India'
Where continent is not null 
--GROUP BY 
ORDER BY 1,2 



--Looking at total population vs vaccination 

SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) AS RollingPeopleVaccinated
	--,(RollingPeop1eVaccinated/popu1ation)*100
FROM [COVID Project]..CovidDeaths$ dea
JOIN [COVID Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

--USE CTE

with PopvsVac ( Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) AS RollingPeopleVaccinated
	--,(RollingPeop1eVaccinated/popu1ation)*100
FROM [COVID Project]..CovidDeaths$ dea
JOIN [COVID Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
	SELECT *,(RollingPeopleVaccinated/Population)*100
	FROM PopvsVac


--TEMP TAB

DROP TABLE IF Exists #PercentPopoulationVaccinated
CREATE TABLE #PercentPopoulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopoulationVaccinated
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) AS RollingPeopleVaccinate
	--,(RollingPeop1eVaccinated/popu1ation)*100
FROM [COVID Project]..CovidDeaths$ dea
JOIN [COVID Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3
	SELECT *,(RollingPeopleVaccinated/Population)*100 
	FROM #PercentPopoulationVaccinated


--Creating View to store data for later visualization 

Create View PercentPopoulationVaccinated
as
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) AS RollingPeopleVaccinate
	--,(RollingPeop1eVaccinated/popu1ation)*100
FROM [COVID Project]..CovidDeaths$ dea
JOIN [COVID Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

Select *
From PercentPopoulationVaccinated