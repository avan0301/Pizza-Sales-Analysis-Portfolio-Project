create database pizza_sales;
use pizza_sales;

create table orders (
	order_id int primary key,
    date text,
    time text
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\orders.csv'
INTO TABLE orders 
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

create table order_details (
	order_details int primary key,
    order_id int,
    pizza_id text,
    quantity int
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\order_details.csv'
INTO TABLE order_details 
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

select * from orders;
select * from order_details;
select * from pizzas;
select * from pizza_types;

create view pizza_details as
select p.pizza_id,p.pizza_type_id,pt.name,pt.category,p.size,p.price,pt.ingredients
from pizzas p
join pizza_types pt
on pt.pizza_type_id = p.pizza_type_id;

select * from pizza_details;

alter table orders 
modify date DATE;

alter table orders
modify time TIME;

-- TOTAL REVENUE
select round(sum(od.quantity * p.price),2) as total_revenue
from order_details od
join pizza_details p
on od.pizza_id = p.pizza_id;

-- TOTAL NUMBER OF PIZZAS SOLD
select sum(od.quantity) as pizza_sold
from order_details od;

-- TOTAL ORDERS
select count(distinct(order_id)) as total_orders
from order_details;

-- AVERAGE ORDER VALUE
select sum(od.quantity * p.price) / count(distinct(od.order_id)) as avg_order_value
from order_details od
join pizza_details p
on od.pizza_id = p.pizza_id;

-- AVERAGE NUMBER OF PIZZA PER ORDER
select round(sum(od.quantity) / count(distinct(od.order_id)),0) as avg_no_pizza_per_order
from order_details od;

-- TOTAL REVENUE AND NUMBERS OF ORDER PER CATEOGARY
select p.category, sum(od.quantity * p.price) as total_revenue, count(distinct(od.order_id)) as total_orders
from order_details od
join pizza_details p
on od.pizza_id = p.pizza_id
group by p.category;

-- TOTAL REVENUUE AND NUMBER OF ORDERS PER SIZE
select p.size, sum(od.quantity * p.price) as total_revenue, count(distinct(od.order_id)) as total_orders
from order_details od
join pizza_details p
on od.pizza_id = p.pizza_id
group by p.size;

-- HOURLY, DAILY AND MONTHLY TRENDS IN ORDERS AND REVENUE OF PIZZA
select
	case
		when hour(o.time) between 9 and 12 then 'Late Morning'
        when hour(o.time) between 12 and 15 then 'Lunch'
        when hour(o.time) between 15 and 18 then 'Mid Afternoon'
        when hour(o.time) between 18 and 21 then 'Dinner'
        when hour(o.time) between 21 and 23 then 'Late Night'
        else 'others'
        end as meal_time, count(distinct(od.order_id)) as total_orders
from order_details od
join orders o on o.order_id = od.order_id
group by meal_time
order by total_orders desc;

-- WEEKDAYS TRENDS IN PIZZA ORDERS
select dayname(o.date) as day_name, count(distinct(od.order_id)) as total_orders
from order_details od
join orders o
on o.order_id = od.order_id
group by dayname(o.date)
order by total_orders desc;

-- MONTHWISE TRENDS IN ORDERS
select monthname(o.date) as month_name, count(distinct(od.order_id)) as total_orders
from order_details od
join orders o
on o.order_id = od.order_id
group by monthname(o.date)
order by total_orders desc;

-- MOST ORDERED PIZZA
select p.name, p.size, count(od.order_id) as count_pizzas
from order_details od
join pizza_details p
on od.pizza_id = p.pizza_id
group by p.name, p.size
order by count_pizzas desc;

-- TOP 5 PIZZAS BY REVENUE
select p.name, sum(od.quantity * p.price) as total_revenue
from order_details od
join pizza_details p
on od.pizza_id = p.pizza_id
group by p.name
order by total_revenue desc
limit 5;

-- TOP PIZZAS BY SALES
select p.name, sum(od.quantity) as pizzas_sold
from order_details od
join pizza_details p
on od.pizza_id = p.pizza_id
group by p.name
order by pizzas_sold desc
limit 5;

-- PIZZA ANALYSIS
select name, price
from pizza_details
order by price desc;

-- TOP USED INGREDIENTS
select * from pizza_details;

create temporary table numbers as (
	select 1 as n union all
    select 2 union all select 3 union all select 4 union all
    select 5 union all select 6 union all select 7 union all
    select 8 union all select 9 union all select 10 
);

select ingredient, count(ingredient) as ingredient_count
from (
		select substring_index(substring_index(ingredients, ',', n), ',', -1) as ingredient
        from order_details
        join pizza_details on pizza_details.pizza_id = order_details.pizza_id
        join numbers on char_length(ingredients) = char_length(replace(ingredients, ',', '')) >=n-1
        ) as subquery
group by ingredient
order by ingredient_count desc; 


    





 
 


