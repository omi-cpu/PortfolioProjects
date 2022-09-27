select * from coviddeaths c 
where continent is not null and continent <> ''
order by 3, 4


--select * from covidvaccinations c2  
--order by 3, 4

--select location, date, total_cases, new_cases , total_deaths , population 
--from coviddeaths c 
--order by 1, 2

-- Total cases vs Total deaths
-- shows the likelihood of occupants of Africa that have contracted covid
/*select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as death_percentage
from coviddeaths c 
where location ilike '%afri%'
and continent is not null and continent <> ''
order by 1, 2*/

-- Total cases vs Population
-- shows what percentage of population has got covid
/*select location, date, total_cases, population, cast((total_cases/population) as int) * 100 as infected_pop_percentage
from coviddeaths c 
where location ilike '%afri%'
and continent is not null and continent <> ''
order by 1, 2*/

-- Countries with highest infection rate compared to population
select location, population, max(total_cases) as highest_infection_count, max((total_cases/population)) * 100 as infected_pop_percentage
from coviddeaths c 
group by "location", population 
order by infected_pop_percentage desc



-- continents with the highest death count per population
select continent , max(total_deaths) as total_Death_count 
from coviddeaths c 
where continent is not null and continent <> ''
group by continent  
order by total_Death_count desc
limit 100

-- countries with the highest death count per population
select location, max(total_deaths) as total_Death_count 
from coviddeaths c 
where continent is not null and continent <> ''
group by location 
order by total_Death_count desc
limit 100

-- global numbers
select date, sum(new_deaths)/sum(new_cases) * 100 as death_percentage, sum(new_cases) as cases, sum(new_deaths) as deaths
from coviddeaths c 
where continent is not null and continent <> ''
group by 1
order by 1,2

select sum(new_deaths)/sum(new_cases) * 100 as death_percentage, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths
from coviddeaths c 
where continent is not null and continent <> ''
order by 1,2

-- total pop vs vaccinations -- likkle problem with the data type conversion
select 
c.continent, c.location, c.date, c.population, c2.new_vaccinations, 
sum(c2.new_vaccinations) OVER (PARTITION BY c.location order by c.location, c.date) as rolling_no_Ppl_vaccinated
from coviddeaths c 
join covidvaccinations c2 
	on c.location = c2.location
	and c.date  = c2.date 
where c.continent is not null and c.continent <> ''
order by 2,3


-- using cte
with pop_vs_vac(continent, location, date, population, rolling_no_Ppl_vaccinated, new_vaccinations) as (
	select 
		c.continent, c.location, c.date, c.population, c2.new_vaccinations, 
		sum(c2.new_vaccinations) OVER (PARTITION BY c.location order by c.location, c.date) as rolling_no_Ppl_vaccinated
	from coviddeaths c 
	join covidvaccinations c2 
		on c.location = c2.location
		and c.date  = c2.date 
	where c.continent is not null and c.continent <> ''
	--order by 2,3
	)
select *,
(rolling_no_Ppl_vaccinated/population) * 100 as vaccinated_ppl_percentage
from pop_vs_vac






-- temp table
--drop table people_vaccinated_pop

create table IF NOT EXISTS people_vaccinated_pop
	(
	continent varchar(255),
	location varchar(255),
	date datemultirange,
	population numeric,
	new_vaccinations numeric,
	rolling_no_Ppl_vaccinated numeric
	)
	
insert into people_vaccinated_pop
	select 
		c.continent, c.location, c.date, c.population, c2.new_vaccinations, 
		sum(c2.new_vaccinations) OVER (PARTITION BY c.location order by c.location, c.date) as rolling_no_Ppl_vaccinated
	from coviddeaths c 
	join covidvaccinations c2 
		on c.location = c2.location
		and c.date  = c2.date 
	--where c.continent is not null and c.continent <> ''
	--order by 2,3
		
select *,
(rolling_no_Ppl_vaccinated/population) * 100 as vaccinated_ppl_percentage
from people_vaccinated_pop



-- creating view to store data for later visualizations
create view people_vaccinated_pop as
 select 
		c.continent, c.location, c.date, c.population, c2.new_vaccinations, 
		sum(c2.new_vaccinations) OVER (PARTITION BY c.location order by c.location, c.date) as rolling_no_Ppl_vaccinated
	from coviddeaths c 
	join covidvaccinations c2 
		on c.location = c2.location
		and c.date  = c2.date 
	where c.continent is not null and c.continent <> ''
	--order by 2,3

	
	
select * from people_vaccinated_pop
