
--I examined the data set.
select * from e_commerce_data

--here I am looking at the last ordered date based on the customer. 

select 
 	distinct customer_id,
 	max(invoice_date) as max_date from e_commerce_data
where customer_id != 'NULL'
group by 1;

--I am looking at the date of the last order.

select 
	max(invoice_date) as max_date 
from e_commerce_data;

--last invoice date "2011-12-09 12:50:00"



--Recency Query

with recency_1 as 
(
select 
	distinct customer_id, 
	max(invoice_date) as max_date from e_commerce_data
where customer_id != 'NULL' and invoice_no not like 'C%' and quantity > 0
group by 1

)

select 
	  customer_id,
	  max_date,
	  extract (day from('2011-12-09 12:50:00'-max_date)) as recency
from recency_1
order by 3 desc;




--Frequency Query 

select 
	distinct customer_id,
	count(customer_id) as frequency
from e_commerce_data 
where customer_id != 'NULL' and invoice_no not like 'C%' and quantity > 0
group by 1 
order by 2 desc;



--Monetary Query 

select 
	distinct customer_id,
	sum(quantity*unit_price) as monetary 
from e_commerce_data 
where customer_id != 'NULL' and invoice_no not like 'C%' and quantity > 0
group by 1 
order by 2 desc;



--RFM QUERY

with rfm  as 
(
with recency_1 as 
(
	select 
		distinct customer_id, 
		max(invoice_date) as max_date
from e_commerce_data
where customer_id != 'NULL' and invoice_no not like 'C%' and quantity > 0
group by 1
)
select 
	  customer_id,
	  max_date,
	  extract (day from('2011-12-09 12:50:00'-max_date)) as recency
from recency_1
order by 3 desc
), frequency_ as 
(
select  
	customer_id,
	count(customer_id) as frequency
from e_commerce_data 
where customer_id != 'NULL' and invoice_no not like 'C%' and quantity > 0
group by 1 
order by 2 desc
),monetary_ as
(
select 
	customer_id,
	sum(quantity*unit_price) as monetary 
from e_commerce_data 
where customer_id != 'NULL' and invoice_no not like 'C%' and quantity > 0
group by 1 
order by 2 desc
)
select 
	rfm.customer_id,
	rfm.recency,
	ntile(5) over (order by recency desc) as R,
	f.frequency,
	ntile(5) over (order by frequency asc) as F,
	m.monetary,
	ntile(5) over (order by monetary asc) as M,
	concat(concat(ntile(5) over (order by recency desc), ntile(5) over (order by frequency asc)),
		   ntile(5) over (order by monetary asc)) as RFM
from rfm 
inner join frequency_ as f 
	on f.customer_id=rfm.customer_id
inner join monetary_ as m 
	on m.customer_id=rfm.customer_id
order by 2 desc;








