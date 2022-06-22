select *
from [portfolio project].dbo.[covid deaths]
where continent is not null 
order by 3,4

--select *
--from [portfolio project].dbo.[covid vaccinations]
---order by 3,4

--select data 
select location,date,total_cases,new_cases, total_deaths,population
from [portfolio project].dbo.[covid deaths]
order by 1,2

--looking at total cases vs. total deaths in terms of percentage 
--shows the likelyhood of dying if contracting the virus in Canada
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [portfolio project].dbo.[covid deaths]
where location like '%cana%'
order by 1,2

---looking the total cases vs. the population in Canada
--what percentage of the population contracted the virus
select location,date,population,total_cases,(total_cases/population)*100 as PercentofPopulationInfected 
from [portfolio project].dbo.[covid deaths]
where location like '%cana%'
order by 1,2


--what countries have the highest infection rates in comparison to the population 

select location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
from [portfolio project].dbo.[covid deaths]
group by  location,population
order by PercentofPopulationInfected desc


--showing the countries with the highest death count per population
select location,population,MAX(cast (total_deaths as int)) as totalDeathCount 
from [portfolio project].dbo.[covid deaths]
where continent is not null
group by continent,location,population
order by totalDeathCount desc

----show by continent the highest death count
select continent ,MAX(cast (total_deaths as int)) as totalDeathCount 
from [portfolio project].dbo.[covid deaths]
where continent is not null
group by continent
order by totalDeathCount desc

--global numbers 

select  sum (new_cases)as total_cases
,sum(cast( new_deaths as int))as total_deaths,
sum(cast(new_deaths as int))/sum (New_Cases)*100 as DeathPercentage
from [portfolio project].dbo.[covid deaths]
--where location like '%cana%'
where continent is not null
order by 1,2

---- join tables  
select * 
from dbo.[covid deaths] as dea
join dbo.covidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date 

--looking at total population vs vaccination
select dbo.[covid deaths].continent, dbo.[covid deaths].location, dbo.[covid deaths].date, dbo.[covid deaths].population,dbo.covidVaccinations$.new_vaccinations,
SUM (CONVERT (int,dbo.covidVaccinations$.new_vaccinations)) OVER ( Partition by dbo.[covid deaths].location, dbo.[covid deaths].date) 
 --as RollingPeopleVaccinated , 
from dbo.[covid deaths] 
join dbo.covidVaccinations$ 
on dbo.[covid deaths].location = dbo.covidVaccinations$ .location
and dbo.[covid deaths].date = dbo.covidVaccinations$.date
where dbo.[covid deaths].continent is not null
order by 2,3

--use CTE, last column show % of population vaccinated 
with PopulationVSVaccination (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
( select dbo.[covid deaths].continent, dbo.[covid deaths].location, dbo.[covid deaths].date, dbo.[covid deaths].population,dbo.covidVaccinations$.new_vaccinations,
SUM (CONVERT (bigint,dbo.covidVaccinations$.new_vaccinations)) OVER ( Partition by dbo.[covid deaths].location
order by dbo.[covid deaths].location,dbo.[covid deaths].date) as RollingPeopleVaccinated
from dbo.[covid deaths] 
join dbo.covidVaccinations$ 
on dbo.[covid deaths].location = dbo.covidVaccinations$ .location
and dbo.[covid deaths].date = dbo.covidVaccinations$.date
where dbo.[covid deaths].continent is not null)
select *, ( RollingPeopleVaccinated/population)*100
from PopulationVSVaccination

--TEMP Table, shows percent of vaccinated population 
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255),date datetime, population numeric, new_vaccinations numeric,RollingPeopleVaccinated numeric)
insert into #PercentPopulationVaccinated
select dbo.[covid deaths].continent, dbo.[covid deaths].location, dbo.[covid deaths].date, dbo.[covid deaths].population,dbo.covidVaccinations$.new_vaccinations,
SUM (CONVERT (bigint,dbo.covidVaccinations$.new_vaccinations)) OVER ( Partition by dbo.[covid deaths].location
order by dbo.[covid deaths].location,dbo.[covid deaths].date) as RollingPeopleVaccinated
from dbo.[covid deaths] 
join dbo.covidVaccinations$ 
on dbo.[covid deaths].location = dbo.covidVaccinations$ .location
and dbo.[covid deaths].date = dbo.covidVaccinations$.date
where dbo.[covid deaths].continent is not null
select *, ( RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--create views to store data for visualizations

create view PercentPopulationVaccinated as 
select dbo.[covid deaths].continent, dbo.[covid deaths].location, dbo.[covid deaths].date, dbo.[covid deaths].population,dbo.covidVaccinations$.new_vaccinations,
SUM (CONVERT (bigint,dbo.covidVaccinations$.new_vaccinations)) OVER ( Partition by dbo.[covid deaths].location
order by dbo.[covid deaths].location,dbo.[covid deaths].date) as RollingPeopleVaccinated
from dbo.[covid deaths] 
join dbo.covidVaccinations$ 
on dbo.[covid deaths].location = dbo.covidVaccinations$ .location
and dbo.[covid deaths].date = dbo.covidVaccinations$.date
where dbo.[covid deaths].continent is not null

create view DeathProbabilityInCanada as
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [portfolio project].dbo.[covid deaths]
where location like '%cana%'

create view PercentageOfCanadiansWhoCaughtVirus as
select location,date,population,total_cases,(total_cases/population)*100 as PercentofPopulationInfected 
from [portfolio project].dbo.[covid deaths]
where location like '%cana%'

create view HighestInfectionRateInComparisonToPopulation as
select location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
from [portfolio project].dbo.[covid deaths]
group by  location,population

create view CountriesWithHighestDeathRatePerPopulation as
select location,population,MAX(cast (total_deaths as int)) as totalDeathCount 
from [portfolio project].dbo.[covid deaths]
where continent is not null
group by continent,location,population
