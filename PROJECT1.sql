select * FROM Project_1.dbo.Data1 ;
select * FROM Project_1.dbo.Data2 ;

-- Number of rows into our dataset --

select count(*) from project_1.dbo.data1;
select count(*) from project_1.dbo.data2;

-- Dataset for Jharkhand and Bihar --

select * from project_1.dbo.data1 where state in ('Jharkhand' , 'Bihar');

-- Population of India --

select sum(population) as 'Population of India' from project_1.dbo.data2;

-- Avg Growth of India --

select avg(growth)*100 as 'Avg Growth' from project_1.dbo.data1;

-- Avg Growth by State --

select state, avg(growth)*100 as 'Avg Growth' from project_1.dbo.data1 group by state;

-- Avg sex ratio --

select state, round(avg(sex_ratio),0) as 'Avg Sex Ratio' from project_1.dbo.data1 group by state order by 'avg sex ratio';

-- Avg Literacy Rate --

select state, round(avg(literacy),0) as 'Avg Literacy' from project_1.dbo.data1 group by state order by 'avg Literacy' desc;

-- Avg Literacy Rate above 90 --

select state, round(avg(literacy),0) as 'Avg Literacy' from project_1.dbo.data1 group by state having round(avg(literacy),0) >90 order by 'avg Literacy';

-- Top 3 state showing highest growth ratio --
 
 select top 3 state, avg(growth)*100 as 'Avg Growth' from project_1.dbo.data1 group by state order by 'avg growth' desc ;

 -- Bottom 5 state showing lowest growth ratio --

 select top 5 state, avg(growth)*100 as 'Avg Growth' from project_1.dbo.data1 group by state order by 'avg growth' asc ;

 -- top and bottom 3 state in literacy state --

 drop table if exists #topstates;
 create table #topstates
 ( state nvarchar(255),
   topstate float )
   insert into #topstates
   select state, round(avg(literacy),0) as 'Avg Literacy' from project_1.dbo.data1 group by state order by 'avg Literacy' desc;

   select top 3 * from #topstates order by #topstates.topstate desc; 

 drop table if exists #Bottomstates;
 create table #Bottomstates
 ( state nvarchar(255),
  Bottomstate float )
   insert into #Bottomstates
   select state, round(avg(literacy),0) as 'Avg Literacy' from project_1.dbo.data1 group by state order by 'avg Literacy' desc;

   select top 3 * from #Bottomstates order by #Bottomstates.bottomstate asc; 

   -- State starting with letter a --

   select * from project_1.dbo.Data1 where lower(state) like 'a%';

    -- State starting with letter a or b --

	select * from project_1.dbo.Data1 where lower(state) like 'a%' or lower(state) like 'b%';

	-- Join both table on District --

	select a.District , a.State , a.Sex_Ratio , b.Population from project_1.dbo.data1 a inner join project_1.dbo.data2 b on a.district = b.District;

	-- Find total number of male and female state wise --

	-- female/male = sex_ratio ...... 1
	-- Males + females = population ...... 2
	-- females = population - males ...... 3
	-- (population - males) = (sex_ratio)*males
	-- population = male(sex_ratio + 1)
	-- Males = population/(sex_ratio + 1) ...... males
	-- female = population - population/(sex_ratio + 1) ...... females
	-- female = (population*(sex_ratio))/(sex_ratio+1) ...... females

	select d.state , sum(d.male) as Total_Male , sum(d.female) as Total_Female from
	(select c.district, c.state, round(c.population/(c.sex_ratio+1),0) as Male, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) as Female from
		(select a.District , a.State , a.Sex_Ratio , b.Population from project_1.dbo.data1 a inner join project_1.dbo.data2 b on a.district = b.District) c) d
		group by d.state;

		-- Total Literacy Rate --

		select a.District , a.State , a.literacy , b.Population from project_1.dbo.data1 a inner join project_1.dbo.data2 b on a.district = b.District;


		-- Total Literate_People vs Illiterate_People state wise --

		-- Total literate people/population = literacy_ratio
		-- total litrate people = literacy_ ratio*population
		-- total illiterate people = (1-literacy_ratio)*population

		select d.state, sum(Literate_People) as Total_Literate_People , sum(Illiterate_People) as Total_Illiterate_People from
		(select c.district, c.state, round((c.literacy_ratio*c.population),0) as Literate_People , round(((1-c.literacy_ratio)*c.population),0) as Illiterate_People from
		(select a.District , a.State , a.literacy/100 as literacy_ratio , b.Population from project_1.dbo.data1 a inner join project_1.dbo.data2 b on a.district = b.District) c)d
		group by d.state;

-- Growth rate --

		select a.District , a.State , a.growth , b.Population from project_1.dbo.data1 a inner join project_1.dbo.data2 b on a.district = b.District;

-- previous_census+growth*previous_census=population
-- previous_census=population/(1+growth)

-- Total Current and Previous Population state wise --

select e.state, sum(e.Previous_Census_Population) as Total_Previous_Census_Population, sum(e.Current_Census_Population) as Total_Current_Census_Population from
(select d.district, d.state, round(d.population/(1+d.growth),0) as Previous_Census_Population, d.population as Current_Census_Population from
(select a.District , a.State , a.growth , b.Population from project_1.dbo.data1 a inner join project_1.dbo.data2 b on a.district = b.District) d) e
group by e.state;

-- Total Current and Previous Population --

select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.District , a.State , a.growth , b.Population from project_1.dbo.data1 a inner join project_1.dbo.data2 b on a.district = b.District) d) e
group by e.state)m


-- population vs area

select (g.total_area/g.previous_census_population) as previous_census_population , (g.total_area/g.current_census_population) as current_census_population from
(select q.* , r.total_area from (
select '1' as keyy, n.*from (
select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.District , a.State , a.growth , b.Population from project_1.dbo.data1 a inner join project_1.dbo.data2 b on a.district = b.District) d) e
group by e.state)m) n) q inner join (

select '1' as keyy, z.*from (
select sum(area_km2) as Total_Area from project_1.dbo.Data2) z) r on q.keyy=r.keyy) g;

-- window 

-- output top 3 districts from each state with highest literacy rate

select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from project_1.dbo.data1) a

where a.rnk in (1,2,3) and state is not null order by state;