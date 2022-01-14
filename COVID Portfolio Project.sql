SELECT *
FROM [PortfolioProject - COVID19] .. CovidDeaths
ORDER BY 3,4;

--SELECT *
--FROM [PortfolioProject - COVID19] .. CovidVaccinations
--ORDER BY 3,4;

-- Select data that we will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject - COVID19] .. CovidDeaths
ORDER BY 1,2;

-- Looking at Total Cases VS Total Deaths
-- Shows the likeilihood of dying from getting COVID in your country
-- Conclusion: 1 out of 100 will die from COVID in the USA, but 4 out of 100 will die from COVID in Taiwan.  WHY???
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS 'Death Rate'
FROM [PortfolioProject - COVID19] .. CovidDeaths
WHERE location LIKE 'United States%' or location = 'Taiwan'
ORDER BY date DESC;

-- Looking at Total Cases VS Population
-- Shows what % of population has got COVID
-- Conclusion: 18 out of 100 people will get COVID in the USA, compared to 7 out of 10,000 people in Taiwan.
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS 'Infection Rate'
FROM [PortfolioProject - COVID19] .. CovidDeaths
WHERE location = 'United States' OR location = 'Taiwan'
ORDER BY date DESC;


--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS 'HighestInfectionCount', MAX((total_cases/population) * 100) AS 'PercPopulationInfected'
FROM [PortfolioProject - COVID19] .. CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC;


-- Showing Countries with the Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) AS 'Total Death Count' -- , MAX((total_deaths/population) * 100) AS 'Death Per Population'
FROM [PortfolioProject - COVID19] .. CovidDeaths
WHERE continent IS NOT null
GROUP BY location -- , population
ORDER BY 2 DESC;

-- Let's break things down by Continent
SELECT location as 'Region', MAX(cast(total_deaths as int)) AS 'Total Death Count' 
FROM [PortfolioProject - COVID19] .. CovidDeaths
WHERE continent IS null
GROUP BY location
ORDER BY 2 DESC;



-- Showing TOP 10 Countries in North America who is leading in COVID cases
SELECT TOP 10 location, max(total_cases) AS 'Total Case Count'
FROM [PortfolioProject - COVID19]..CovidDeaths
WHERE continent = 'North America'
GROUP BY location
ORDER BY 'Total Case Count' DESC


-- GLOBAL NUMBERS
SELECT date, sum(new_cases) AS 'Global Daily New Cases', SUM(CAST(new_deaths AS int)) AS 'Global Daily New Deaths', (SUM(CAST(new_deaths AS int))/sum(new_cases)) * 100 AS 'Global Death Percentage'
FROM [PortfolioProject - COVID19] .. CovidDeaths
WHERE continent IS NOT null 
GROUP BY date
ORDER BY 1,2




SELECT continent, date, max(cast(total_vaccinations AS bigint)) AS 'TotalVaccinations' --, people_vaccinated, total_boosters, new_vaccinations, new_vaccinations_smoothed
FROM [PortfolioProject - COVID19]..CovidVaccinations
--WHERE continent = 'North America'
GROUP BY continent, date
ORDER BY 3 DESC


-- Looking at Total Population VS Vaccinations
-- Using CTE (to create a new dataframe with new column)

With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinationsCount)
as
(
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations, SUM(CAST(Vacc.new_vaccinations as bigint)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) as RollingVaccinationsCount
FROM [PortfolioProject - COVID19]..CovidDeaths as Death
JOIN [PortfolioProject - COVID19]..CovidVaccinations as Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent is not null
-- ORDER BY 2,3 
)

SELECT *, (RollingVaccinationsCount/population * 100) AS RollingVaccinationPerc
FROM PopvsVac


-- Creating Temp Table
Drop table if exists #PercPopVacc
Create Table #PercPopVacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinationsCount numeric
)

Insert Into #PercPopVacc
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations, SUM(CAST(Vacc.new_vaccinations as bigint)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) as RollingVaccinationsCount
FROM [PortfolioProject - COVID19]..CovidDeaths as Death
JOIN [PortfolioProject - COVID19]..CovidVaccinations as Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent is not null
-- ORDER BY 2,3 


SELECT *, (RollingVaccinationsCount/population) * 100
FROM #PercPopVacc





-- Creating View

Create View PercPopVacc as
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations, SUM(CAST(Vacc.new_vaccinations as bigint)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) as RollingVaccinationsCount
FROM [PortfolioProject - COVID19]..CovidDeaths as Death
JOIN [PortfolioProject - COVID19]..CovidVaccinations as Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent is not null
-- ORDER BY 2,3 

