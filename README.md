# Covid19 Data Exploration

## Table of Content
- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Preparation](#data-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Findings](#Findings)
- [Recommendation](#recommendation)
- [Limitations](#limitations)
- [Reference](#reference)

### Project Overview
This Data Analysis project helps to provide more information on the covid19 virus that has ravaged the world in the past 4 years. By analyzing various aspects of the dataset,we will see how the cases were spread across the world, the number of deaths and the vaccination rates.


![Dashboard 1 (1)](https://github.com/SamuelChukwuji/SQL-Covid19-Data-Exploration/assets/159860622/b4d424f8-a0b0-484a-9c4c-26d8fd756a00)

### Data Sources
Covid19 : The datasets used for this analysis are "19.csv" file and "covid19_vaccination.csv" file containing 
information about the cases, deaths, vaccinations, etc.

### Tools
1. Excel - For cleaning the data [Download here](https://github.com/SamuelChukwuji/SQL-Covid19-Data-Exploration/tree/master)
2. MySQL Workbench - for analysing the data [Download here](https://github.com/SamuelChukwuji/SQL-Covid19-Data-Exploration/blob/main/sqlproject1.sql)
3. Tableau - for visualizing the data [Download here](https://public.tableau.com/app/profile/samuel.chukwuji/viz/Covid19InfectionDeath/Dashboard1?publish=yes)

 ### Data Preparation
 In the data preparation stage, i carried out the following tasks:
- Handling missing values.
- Data cleaning and formatting.
- Data loading and inspection.

### Exploratory Data Analysis
This stage involved exploring the covid19 dataset to answer key questions such as:
- Which countries have the highest infection rate per population?
- What is the likelihood of dying when infection is contacted in certain countries?
- Which countries have the highest infection rate per population?
- How did the infections progress by date?
- Which countries have the highest death count per population?
- Which continents recorded the most deaths?
- What are the global numbers in terms of cases and deaths?

### Data Analysis
Checking the total deaths by continents
```SQL
select continent, sum(new_deaths) over (partition by continent) as total_death_count 
from c19deaths
order by 2 desc;

-- using a CTE
with DeathByContinent(continent, total_death_count)
as(
select continent, sum(new_deaths) over (partition by continent) as total_death_count from c19deaths
)
select distinct total_death_count, continent from DeathByContinent order by 1 desc;
```

Joining the two tables to look at total population vs vaccinations
```SQL
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
```

###  Findings
- Global death rate due to the virus as at December 2023 stood at 0.9%
- Europe recorded the most deaths with atleast 2,087,384 peopele dying from the virus
- USA had the highest death rate of any single country, recording over 1,144,877 deaths
- San Marino had the highest infection rate with over 75% of it's population getting infected.

### Recommendation
Vaccines should be made available quicker next time as the trend showed that fewer deaths were recorded when more people got vaccinated.

### Limitations
In the original dataset, some continent names were under the location column. I had to remove every row under the location column that contained continent name rather than country name. The accuracy of my conclusion from the analysis would have been affected if I had not done this.

### Reference
[Our World in Data](https://ourworldindata.org/covid-deaths)
