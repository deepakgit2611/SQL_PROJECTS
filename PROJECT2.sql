drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'01-01-2021'),
(2,'01-03-2021'),
(3,'01-08-2021'),
(4,'01-15-2021');


drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'01-01-2021 18:15:34','20km','32 minutes',''),
(2,1,'01-01-2021 19:10:54','20km','27 minutes',''),
(3,1,'01-03-2021 00:12:37','13.4km','20 mins','NaN'),
(4,2,'01-04-2021 13:53:03','23.4','40','NaN'),
(5,3,'01-08-2021 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'01-08-2020 21:30:45','25km','25mins',null),
(8,2,'01-10-2020 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'01-11-2020 18:50:20','10km','10minutes',null);


drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','01-01-2021  18:05:02'),
(2,101,1,'','','01-01-2021 19:00:52'),
(3,102,1,'','','01-02-2021 23:51:23'),
(3,102,2,'','NaN','01-02-2021 23:51:23'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,2,'4','','01-04-2021 13:23:46'),
(5,104,1,null,'1','01-08-2021 21:00:29'),
(6,101,2,null,null,'01-08-2021 21:03:13'),
(7,105,2,null,'1','01-08-2021 21:20:29'),
(8,102,1,null,null,'01-09-2021 23:54:33'),
(9,103,1,'4','1,5','01-10-2021 11:22:59'),
(10,104,1,null,null,'01-11-2021 18:34:49'),
(10,104,1,'2,6','1,4','01-11-2021 18:34:49');

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;

-- 1. How many rolls were order ? 

select count(roll_id) from customer_orders;

-- 2. How many unique customer orders were made ?

select count(distinct customer_id) from customer_orders ;

-- 3. How many successful orders were delivered by each driver ?

select driver_id, count(distinct order_id) as order_count from driver_order where cancellation not in ('Cancellation' , 'Customer Cancellation') group by driver_id;

-- 4. How many of each type of roll was delivered ?

select roll_id, count(roll_id) from
customer_orders where order_id in (
select order_id from
(select*, case when cancellation in ('Cancellation' , 'Customer Cancellation') then 'c' else 'nc' end as order_cancel_details from driver_order)a where order_cancel_details='nc')
group by roll_id;

-- 5. How many Veg and Non Veg Rolls were ordered by each customer ?

select a.*, b.roll_name from
(select customer_id, roll_id, count(roll_id) cnt from customer_orders group by customer_id, roll_id) a inner join rolls b on a.roll_id = b.roll_id; 

-- What was the maximum number of rolls delivered in single order ?

select * from 
(
select *, rank() over(order by cnt desc) rnk from
(
select order_id, count(roll_id) cnt
from(
select * from customer_orders where order_id in (
select order_id from 
(select*, case when cancellation in ('Cancellation' , 'Customer Cancellation') then 'c' else 'nc' end as order_cancel_details from driver_order)a where order_cancel_details ='nc' ))b
group by order_id)c)d where rnk=1;


select * from (
select * , rank() over(order by cnt desc) rnk from (
select order_id, count(roll_id) cnt from
(
select * from customer_orders where order_id in (
select order_id from 
(select * , case when cancellation in ('cancellation' , 'customer cancellation') then 'c' else 'nc' end as order_cancel_details from driver_order)a where order_cancel_details ='nc'))b 
group by order_id)c)d where rnk=1;

-- For each customer, how many delivered rolls had at least 1 change and how many had no change ?

with temp_customer_orders (order_id, customer_id, roll_id, new_not_include_items, new_extra_items_included, order_date) as
(
select order_id, customer_id, roll_id,
case when not_include_items is NULL or not_include_items= ' ' then '0' else not_include_items end as new_not_include_items,
case when extra_items_included is NULL or extra_items_included = ' ' or extra_items_included = 'NaN' then '0' else extra_items_included end as new_extra_items_included,
order_date from customer_orders )

with temp_driver_orders ( order_id, driver_id, pickup_time, distance, duration, new_cancellation) as
(
select order_id, driver_id, pickup_time, distance, duration,
case when cancellation in ('cancellation' , 'customer cancellation') then 0 else 1 end as new_cancellation from driver_order
)

select customer_id, chg_no_chg, count(order_id) from
(
select *, case when not_include_items='0' and extra_items_included = '0' then 'no change' else' change' end chg_no_chg
from temp_customer_orders where order_id in(
select order_id from temp_driver_orders where new_cancellation!=0))a
group by customer_id, chg_no_chg;

-- What was the total number of rolls ordered for each hour of the day ?

select
hour_bucket, count(hour_bucket) count from
(select *, concat(cast(datepart(hour, order_date) as varchar), '-' , cast(datepart(hour, order_date)+1 as varchar)) as hour_bucket from customer_orders)a 
group by hour_bucket;


-- What was the number of orders for each day of the week ?

select DOW , count(distinct order_id) from
(
select *, datename(dw, order_date) DOW from customer_orders)a
group by DOW;

-- What was the average time in minutes it took for each driver to arrive at the fasoos HQ to pickup the order ?

select driver_id, sum(diff)/count(order_id) avg_mins from
(select * from
(select *, row_number() over (partition by order_id order by diff) rnk from
(
select a.order_id, a.customer_id, a.roll_id, a.not_include_items, a.extra_items_included, a.order_date, b.driver_id, b.pickup_time, b.distance, b.duration, b.cancellation
, datediff(minute, a.order_date, b.pickup_time) as Diff from customer_orders a inner join driver_order b on a.order_id=b.order_id where b.pickup_time is not null)a)b where rnk=1)c
group by driver_id;

-- What was the average distance travelled for each customer ?

select customer_id, sum(distance)/count(order_id) avg_distance_cover from
(select * from
(select *, row_number() over (partition by order_id order by diff) rnk from
(
select a.order_id, a.customer_id, a.roll_id, a.not_include_items, a.extra_items_included, a.order_date, b.driver_id, b.pickup_time, 
cast(trim(replace(lower(b.distance), 'km', ' ')) as decimal(4,2)) distance,
b.duration, b.cancellation, datediff(minute, a.order_date, b.pickup_time) as Diff from customer_orders a inner join driver_order b on a.order_id=b.order_id where b.pickup_time is not null)a)b 
where rnk=1)c group by customer_id;

-- What was the diffrance betwwen the longest and the shortest delivery times for all orders ?

select max(duration)-min(duration) diff from (
select duration, cast(case when duration like '%min%' then left(duration, charindex('m', duration)-1) else duration end as integer) as duration from driver_order where duration is not null)a;

