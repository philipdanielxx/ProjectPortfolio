-- SELECT * FROM portfolio_project.covidvaccinations
-- ORDER BY 3, 4;

SELECT * FROM portfolio_project.coviddeaths
where continent is not null -- getting rid of the null that affects the location data
ORDER BY 3, 4;

UPDATE `portfolio_project`.`coviddeaths`
SET continent = NULL
WHERE continent = '';


-- Select "Key Columns" to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project.coviddeaths
ORDER BY 1, 2;

-- How many Total Deaths Vs Total Cases in percentage

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM portfolio_project.coviddeaths
ORDER BY 1, 2;

-- Picking a location to explore

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM portfolio_project.coviddeaths
WHERE location like "%States%"
ORDER BY 1, 2;  -- showing the likelihood of death if covid was contracted in that location, at that time (United States)

-- showing the likelihood of death if covid was contracted in that location, at that time (Africa)

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM portfolio_project.coviddeaths
WHERE location like "%Africa%";  -- showing the likelihood of death if covid was contracted in that location, at that time (United States)

-- exploring the total cases vs popluation to show the percentage of population that got covid

SELECT location, date, total_cases, Population, (total_cases/Population) * 100 as PopPercentageInfected
FROM portfolio_project.coviddeaths
WHERE location like "%Africa%";

SELECT location, date, Population, total_cases, (total_cases/Population) * 100 as PopPercentageInfected
FROM portfolio_project.coviddeaths
WHERE location like "Asia"
Order By 1, 2;

-- countries with highest infection rate compared to population

SELECT location, Population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/Population)) * 100 as InfectedPopPercentage
FROM portfolio_project.coviddeaths
Group by location, Population
Order By InfectedPopPercentage desc; -- i want to see the highest infectedpoppercentage

-- countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as UNSIGNED)) as TotalDeathsCounts -- changing the datatype of the column = totaldeaths
FROM portfolio_project.coviddeaths
where continent is not null
Group by location
Order By TotalDeathsCounts desc;

-- breaking it down/narrowing down the data by continents (drill down)
-- continents with the highest deaths perpopulation

SELECT continent, MAX(cast(total_deaths as UNSIGNED)) as TotalDeathsCounts -- changing the datatype of the column = totaldeaths
FROM portfolio_project.coviddeaths
where continent is not null
Group by continent
Order By TotalDeathsCounts desc;

-- global numbers of new cases around the world

SELECT date, sum(new_cases)  -- total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM portfolio_project.coviddeaths
where continent is not null
group by date
order by 1, 2;

-- global numbers of new cases and new deaths around the world

SELECT date, sum(new_cases), sum(cast(new_deaths as unsigned))
FROM portfolio_project.coviddeaths
where continent is not null
group by date
order by 1, 2;

-- global numbers of daeth percentage of new cases and new deaths around the world

SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as unsigned)) as total_deaths, sum(cast(new_deaths as unsigned))/sum(new_cases) * 100 as GlobalDeathPercentages
FROM portfolio_project.coviddeaths
where continent is not null
group by date
order by 1, 2;
-- overall across the globe
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as unsigned)) as total_deaths, sum(cast(new_deaths as unsigned))/sum(new_cases) * 100 as GlobalDeathPercentages
FROM portfolio_project.coviddeaths
where continent is not null
order by 1, 2;

-- joinig both tables together (coviddeaths and covid vaccinations)

SELECT * 
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date;

-- total population vs vaccination i.e total amount of people in the world that have been vaccinated basically

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
order by 1, 2, 3;
-- creating a rolling count kind of, so as the no. of new vaccinations increases, it adds up in a new column
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as unsigned)) OVER (partition by dea.location order by dea.location, dea.date) as RollingCountVaccinated
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
order by 1, 2, 3;

-- to find out the total pop vs vaccinated, using a CTE was needed

-- CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingCountVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as unsigned)) OVER (partition by dea.location order by dea.location, dea.date) as RollingCountVaccinated
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
order by 1, 2, 3)

select *, (RollingCountVaccinated/population) * 100
from PopvsVac;

-- View Creation
-- creating a view to store data which would be used for data visualizations

-- 1. RollingCountVaccinated
Create view RollingCountVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as unsigned)) OVER (partition by dea.location order by dea.location, dea.date) as RollingCountVaccinated
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date;
-- order by 1, 2, 3
SELECT * FROM portfolio_project.rollingcountvaccinated;

-- 2. TotalDeathsCounts
Create view TotalDeathsCounts as
SELECT continent, MAX(cast(total_deaths as UNSIGNED)) as TotalDeathsCounts -- changing the datatype of the column = totaldeaths
FROM portfolio_project.coviddeaths
where continent is not null
Group by continent
Order By TotalDeathsCounts desc;
SELECT * FROM portfolio_project.totaldeathscounts;
