-- Display the data table for covid deaths

SELECT * FROM covid_project.coviddeathss
order by 3, 4;

-- Select "Key Columns" to explore

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_project.coviddeathss
ORDER BY 1, 2;

-- How many Total Deaths Vs Total Cases in percentage

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM covid_project.coviddeathss
ORDER BY 1, 2;

-- Randomly selcting locations to explore

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM covid_project.coviddeathss
WHERE location like "%Canada%"
ORDER BY 1, 2;  -- showing the likelihood of death if covid was contracted in that location, at that time (United States)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM covid_project.coviddeathss
WHERE location like "%Benin%"
ORDER BY 1, 2;  -- showing the likelihood of death, if covid was contracted in that location, at that time (benin)

-- Randomly selecting continents to explore

SELECT continent, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM covid_project.coviddeathss
WHERE continent like "%Africa%"
ORDER BY 1, 2;  -- showing the likelihood of death if covid was contracted in that continent, at that time (Africa)

SELECT continent, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM covid_project.coviddeathss
WHERE continent like "%North America%"
ORDER BY 1, 2;  -- showing the likelihood of death if covid was contracted in that continent, at that time (North America)

-- exploring the total cases vs population, to show the percentage of population that got infected by covid - Using a canada as case study

SELECT location, date, total_cases, Population, (total_cases/Population) * 100 as InfectedPopulation
FROM covid_project.coviddeathss
WHERE location like "%Canada%"
ORDER BY InfectedPopulation DESC;

-- countries with highest infection rate compared to population - using location and population

SELECT location, Population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/Population)) * 100 as HighestInfectionPop
FROM covid_project.coviddeathss
where continent is not null
Group by location, Population
Order By HighestInfectionPop desc; -- i want to see the highest infectedpoppercentage

-- countries with highest infection rate compared to population - using location, population and date

SELECT location, Population, date, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/Population)) * 100 as HighestInfectionPop
FROM covid_project.coviddeathss
where continent is not null
Group by location, Population, date
Order By HighestInfectionPop desc; -- i want to see the highest infectedpoppercentage

-- continents with the highest death count per perpopulation

SELECT continent, sum(cast(total_deaths as SIGNED)) as HighestDeathCount -- changed the datatype of the column = totaldeaths
FROM covid_project.coviddeathss
where trim(continent) is not null
And trim(continent) <> ""
Group by continent
Order By HighestDeathCount desc;

-- breaking it down/narrowing down the data by continents (drill down)
-- countries with the highest death count per population

SELECT location, Max(cast(total_deaths as SIGNED)) as HighestDeathCount -- changing the datatype of the column = totaldeaths
FROM covid_project.coviddeathss
where continent is not null
and location not in ("Europe", "Asia", "Africa")
Group by location
Order By HighestDeathCount desc;

-- global numbers of new cases around the world

SELECT date, sum(new_cases) as TotalNewCases
FROM covid_project.coviddeathss
where continent is not null
group by date
order by date Desc;

-- global numbers of new cases and new deaths around the world, for comparison purposes

SELECT date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as signed)) as TotalNewDeaths
FROM covid_project.coviddeathss
where continent is not null
group by date
order by date Desc;

-- global numbers of daeth percentage of new cases and new deaths around the world

SELECT date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as signed)) as TotalNewDeaths, sum(cast(new_deaths as signed))/sum(new_cases) * 100 as GlobalDeathPercentage
FROM covid_project.coviddeathss
where continent is not null
group by date
order by date Desc;

-- Overall numbers across the globe
SELECT sum(new_cases) as TotalNewCases, sum(cast(new_deaths as signed)) as TotalNewDeaths, sum(cast(new_deaths as signed))/sum(new_cases) * 100 as GlobalDeathPercentage
FROM covid_project.coviddeathss
where continent is not null;

-- Performed a join for both tables
-- joinig both tables together (coviddeaths and covidvaccinations)

SELECT * 
FROM covid_project.coviddeathss deat
JOIN covid_project.covidvaccinationss vacs
ON deat.location = vacs.location
AND deat.date = vacs.date;

-- total population vs vaccination i.e total amount of people in the world that have been vaccinated basically

SELECT deat.continent, deat.location, deat.date, deat.population, vacs.new_vaccinations
FROM covid_project.coviddeathss deat
JOIN covid_project.covidvaccinationss vacs
ON deat.location = vacs.location
AND deat.date = vacs.date
order by 1, 2, 3;

-- creating a rolling count kind of, so as the no. of new vaccinations increases, it adds up in a new column - using azerbaijan
SELECT deat.continent, deat.location, deat.date, deat.population, vacs.new_vaccinations,
sum(cast(vacs.new_vaccinations as signed)) OVER (partition by deat.location order by deat.location, deat.date) as RollingCountsVaccinated
FROM covid_project.coviddeathss deat
JOIN covid_project.covidvaccinationss vacs
ON deat.location = vacs.location
AND deat.date = vacs.date
WHERE deat.location like "%Azerbaijan%"
order by 1, 2, 3;

-- to find out the total pop vs vaccinated, using a CTE was needed

-- CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingCountsVaccinated)
as
(SELECT deat.continent, deat.location, deat.date, deat.population, vacs.new_vaccinations,
sum(cast(vacs.new_vaccinations as signed)) OVER (partition by deat.location order by deat.location, deat.date) as RollingCountsVaccinated
FROM covid_project.coviddeathss deat
JOIN covid_project.covidvaccinationss vacs
ON deat.location = vacs.location
AND deat.date = vacs.date
WHERE deat.location like "%Azerbaijan%"
order by 1, 2, 3)
select *, (RollingCountsVaccinated/population) * 100 as TotalPopVaccinated
from PopvsVac;

-- View Creation
-- creating a view to store data which would be used for data visualizations

-- 1. RollingCountsVaccinated
Create view RollingCountsVaccinated as
SELECT deat.continent, deat.location, deat.date, deat.population, vacs.new_vaccinations,
sum(cast(vacs.new_vaccinations as signed)) OVER (partition by deat.location order by deat.location, deat.date) as RollingCountsVaccinated
FROM covid_project.coviddeathss deat
JOIN covid_project.covidvaccinationss vacs
ON deat.location = vacs.location
AND deat.date = vacs.date;
-- order by 1, 2, 3
SELECT * FROM covid_project.rollingcountsvaccinated;

-- 2. TotalDeathsCounts
Create view TotalDeathsCounts as
SELECT location, max(cast(total_deaths as SIGNED)) as TotalDeathsCounts -- changing the datatype of the column = totaldeaths
FROM covid_project.coviddeathss
where continent is not null
Group by location
Order By TotalDeathsCounts desc;
SELECT * FROM covid_project.totaldeathscounts
where location not in ("World","Europe", "Asia", "Africa");

-- 3. countries with highest infection rate compared to population
Create view HighestInfectionPop as
SELECT location, Population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/Population)) * 100 as HighestInfectionPop
FROM covid_project.coviddeathss
where continent is not null
Group by location, Population
Order By HighestInfectionPop desc;
SELECT * FROM covid_project.highestinfectionpop;

-- 4. overall across the globe - Global Numbers
Create view GlobalDeathPercentage as
SELECT sum(new_cases) as TotalNewCases, sum(cast(new_deaths as signed)) as TotalNewDeaths, sum(cast(new_deaths as signed))/sum(new_cases) * 100 as GlobalDeathPercentage
FROM covid_project.coviddeathss
where continent is not null;
SELECT * FROM covid_project.globaldeathpercentage;

-- 5. DeathToll
Create view DeathToll as
SELECT continent, max(cast(total_deaths as SIGNED)) as DeathToll -- changing the datatype of the column = totaldeaths
FROM covid_project.coviddeathss
where trim(continent) is not null
And trim(continent) <> ""
Group by continent
Order By DeathToll desc;
SELECT * FROM covid_project.deathtoll;