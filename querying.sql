--Selecting the data we will be working on

Select location, date, total_cases, new_cases, total_deaths, population from coviddeaths order by 1,2;

--Looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage from coviddeaths order by 1,2;

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage from coviddeaths where location like '%States%' order by 1,2;

--Looking at total cases vs population
--Shows what percentage of population in the states got covid
Select location, date, population, total_cases, (total_cases/population)*100 as percent_population_infection from coviddeaths where location like '%States%' order by 1,2;


--Looking at countries with the highest infection rate compared to population
Select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as percent_population_infection from coviddeaths group by location, population order by percent_population_infection desc;

--Showing countries with the highest death count per population

Select location, MAX(total_deaths) as max_total_death_count from coviddeaths WHERE continent IS NOT NULL and total_deaths is not null group by location order by max_total_death_count desc;


--Showing continents with the highest death count per population

Select continent, MAX(total_deaths) as max_total_death_count 
from coviddeaths
WHERE continent IS Not NULL
group by continent order by max_total_death_count desc;

--Global numbers
Select date, SUM(new_cases) as total_cases_per_day, SUM(new_deaths) total_deaths_per_day
--SUM(new_deaths)/SUM(new_cases)*100 as Deathpercentage --total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where continent is not null
group by date
order by 1,2;

--Looking at total population vs vaccinations
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covid_vaccinations vac
on dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null
order by 2,3;

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covid_vaccinations vac
on dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 from PopvsVac;

--Temp Table
CREATE TABLE PercentPopulationVaccinated (
    continent TEXT,
    location TEXT,
    date DATE,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
    coviddeaths dea
JOIN
    covid_vaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

SELECT
    *,
    (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM
    PercentPopulationVaccinated;

--Creating view for storing data for later visualizations

Create View PercentagePopulationVaccinated as 
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
    coviddeaths dea
JOIN
    covid_vaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;
