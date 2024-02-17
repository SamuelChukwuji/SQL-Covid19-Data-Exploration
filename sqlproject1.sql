use project;
show tables;
create table C19deaths
(iso_code varchar(255),	continent varchar(200),	location varchar(210),	The_date date,	population bigint, total_cases int,	new_cases int,	new_cases_smoothed int, total_deaths int,	new_deaths int,	new_deaths_smoothed int,	total_cases_per_million double,	new_cases_per_million double,	new_cases_smoothed_per_million double,	total_deaths_per_million double,	new_deaths_per_million double,	new_deaths_smoothed_per_million double,	reproduction_rate double,	icu_patients int, icu_patients_per_million double,	hosp_patients int,	hosp_patients_per_million double,	weekly_icu_admissions int,	weekly_icu_admissions_per_million double,	weekly_hosp_admissions int,	weekly_hosp_admissions_per_million double);
load data infile 'C:/19.csv' into table C19deaths
fields terminated by ','
ignore 1 lines;
desc covid_19_deaths;
select * from covid_19_deaths
where location in ('pitcairn');
select * from c19deaths where location like 'pitcairn';


create table covid19_vaccination
(iso_code varchar(100),	continent varchar(100),	location varchar(100),	the_date date,	new_tests int,	total_tests_per_thousand double,	new_tests_per_thousand double, new_tests_smoothed int,	new_tests_smoothed_per_thousand double,	positive_rate double,	tests_per_case double,	tests_units varchar(100),	total_vaccinations bigint,	people_vaccinated int,	people_fully_vaccinated int,	total_boosters int,	new_vaccinations int,	new_vaccinations_smoothed int,	total_vaccinations_per_hundred double,	people_vaccinated_per_hundred double,	people_fully_vaccinated_per_hundred double,	total_boosters_per_hundred double, new_vaccinations_smoothed_per_million double,	new_people_vaccinated_smoothed int,	new_people_vaccinated_smoothed_per_hundred double,	stringency_index double,	population_density double, median_age double, 	aged_65_older double,	aged_70_older double,	gdp_per_capita double,	extreme_poverty double,	cardiovasc_death_rate double,	diabetes_prevalence double, female_smokers double,	male_smokers double,	handwashing_facilities double,	hospital_beds_per_thousand double, life_expectancy double, human_development_index double,		excess_mortality_cumulative_absolute double, excess_mortality_cumulative double, excess_mortality double,	excess_mortality_cumulative_per_million double);
alter table covid19_vaccination
modify total_vaccinations bigint;
load data infile 'C:/covid19_vaccination.csv' into table covid19_vaccination
fields terminated by ','
ignore 1 lines;
desc covid19_vaccination;
select * from covid19_vaccination;
select count(*) from c19deaths;
select count(*) from covid19_vaccination;


select location, the_date, population, total_cases, new_cases, total_deaths from c19deaths order by 1,2;
-- Total Cases vs Total Deaths
-- showing the likelihood of dying when infection is contacted in United Kingdom
select location, the_date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from c19deaths where location like 'united kingdom' order by 1,2;
-- Total cases vs population
select location, the_date, population, total_cases, (total_cases/population)*100 as infection_rate 
from c19deaths where location like '%United Kingdom%' order by 1,2;

-- Countries with highest infection rate to population
select location, population, max(total_cases) as highest_infection_count, max(total_cases/population)*100 as population_percent_infected 
from c19deaths 
group by location, population
order by 4 desc;

-- infection rate by date 

select location, population, the_date, max(total_cases) as highest_infection_count, max(total_cases/population)*100 as population_percent_infected 
from c19deaths
group by location, population, the_date
order by the_date;


-- infection rate by date in UK

select location, population, the_date, max(total_cases) as highest_infection_count, max(total_cases/population)*100 as population_percent_infected 
from c19deaths where location = 'united kingdom' 
group by location, population, the_date
having population_percent_infected > 0
order by the_date;

-- countries with highest death count per population
select location, max(total_deaths) as total_death_count 
from c19deaths 
group by location 
order by 2 desc;

-- checking the data by continent
select continent, max(total_deaths) as total_death_count 
from c19deaths
group by continent
order by 2 desc;


-- checking the total deaths by continents
select continent, sum(new_deaths) over (partition by continent) as total_death_count 
from c19deaths
order by 2 desc;

-- using a CTE
with DeathByContinent(continent, total_death_count)
as(
select continent, sum(new_deaths) over (partition by continent) as total_death_count from c19deaths
)
select distinct total_death_count, continent from DeathByContinent order by 1 desc;



-- looking at the death percentage by dates
select the_date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from c19deaths
group by the_date
order by 1,2;

-- looking at the total world death percentage with the global numbers 
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from c19deaths
order by 1,2;


-- joining the two tables to look at total population vs vaccinations
select * from c19deaths d
join covid19_vaccination v
on d.location = v.location
and d.the_date=v.the_date;
select d.continent, d.location, d.the_date, d.population, v.new_vaccinations from c19deaths d
join covid19_vaccination v
on d.location = v.location and d.continent=v.continent
and d.the_date=v.the_date
order by 1,2,3;

select d.continent, d.location, d.the_date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over (partition by d.location) 
from c19deaths d
join covid19_vaccination v
on d.location = v.location and d.continent=v.continent
and d.the_date=v.the_date
order by 2,3;


select d.continent, d.location, d.the_date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over (partition by d.location order by d.location, d.the_date) as incremental_people_vaccinated_per_location
from c19deaths d
join covid19_vaccination v
on d.location = v.location
and d.the_date=v.the_date
order by 2,3;
-- using a CTE
with populationVSvaccination(continent, location, the_date, population, new_vaccinations, incremental_people_vaccinated_per_location)
as (
select d.continent, d.location, d.the_date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over (partition by d.location order by d.location, d.the_date) as incremental_people_vaccinated_per_location
from c19deaths d
join covid19_vaccination v
on d.location = v.location
and d.the_date=v.the_date
)
select *, (incremental_people_vaccinated_per_location/population)*100 from populationVSvaccination;


-- CREATING A VIEW FOR VISUALIZATION

create view percent_population_vaccinated as
select d.continent, d.location, d.the_date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over (partition by d.location order by d.location, d.the_date) as incremental_people_vaccinated_per_location
from c19deaths d
join covid19_vaccination vpercent_population_vaccinated
on d.location = v.location
and d.the_date=v.the_date