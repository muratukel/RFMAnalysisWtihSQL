## 🛒 E-Commerce Data (Online Retail II)
![img](https://hivemarketingcloud.com/media/zphnp5zi/rfm-analysis-blog-graphic-01.png)
# I analyzed the data of this dataset between 2009 and 2010 with Python. If you want to examine the RFM analysis in Python, you can click on the link below.
[RFMwithPythonE-CommmerceData](https://github.com/muratukel/RFMwithPython-online_retail_II-/blob/main/RFM%C4%B0ntroAndCommentary.md.md)

## Dataset Link : https://archive.ics.uci.edu/dataset/502/online+retail+ii

# 📊 I did RFM analysis in PostgeSQL by taking the data between 2010-2011 in our dataset.

🖍️ I examined the data set.

🖍️ This query retrieves all the data from the e_commerce_data table.
````sql
select 
      *
 from e_commerce_data;
````

🖍️ Here I am looking at the last ordered date based on the customer.

🖍️ This query calculates the maximum invoice date for each distinct customer.
````sql
select 
 	distinct customer_id,
 	max(invoice_date) as max_date from e_commerce_data
where customer_id != 'NULL'
group by 1;
````

🖍️ I am looking at the date of the last order.

🖍️This query calculates the maximum invoice date in the entire dataset.
````sql
select 
	max(invoice_date) as max_date 
from e_commerce_data;
````
| max_date            |
|---------------------|
| 2011-12-09 12:50:00 |

❗ Last invoice date: "2011-12-09 12:50:00"

# 📅 Recency Query

🖍️ This section calculates the recency of each customer based on their last order date.
````sql
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
````

# 🔂 Frequency Query

🖍️ This section calculates the frequency of each customer's orders.
````sql
select 
	distinct customer_id,
	count(customer_id) as frequency
from e_commerce_data 
where customer_id != 'NULL' and invoice_no not like 'C%' and quantity > 0
group by 1 
order by 2 desc;
````

# 💰 Monetary Query

🖍️ This section calculates the monetary value of each customer's purchases.
````sql
select 
	distinct customer_id,
	sum(quantity*unit_price) as monetary 
from e_commerce_data 
where customer_id != 'NULL' and invoice_no not like 'C%' and quantity > 0
group by 1 
order by 2 desc;
````

## RFM QUERY 🕒🔄💲
🖍️ Here I have segmented it according to specific RFM code ranges.

````sql

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

),rfm_segmented as 

(select 
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
order by 2 desc
)
select
    rfm_segmented.*,
   case
    when r = 5 and f = 5 and m = 5 then 'Champions'
    when r = 4 and f >= 4 and m >= 4 then 'Loyal customers'
    when r = 4 and f = 5 and m < 4 then 'High Recency, High Frequency'
    when r <= 2 and f >= 3 and m >= 3 then 'Potential Loyalists'
    when r = 1 then 'New Customers'
    when r >= 3 and f <= 2 and m >= 3 then 'Need Attention'
    when r >= 3 and f >= 3 and m <= 2 then 'At Risk'
    else 'Others'
		end as RFM_Segment
from rfm_segmented;
````
🖍️ I segmented many RFM code combinations to better understand customers and develop more effective marketing strategies.
````sql
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

),rfm_segmented as 

(select 
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
order by 2 desc
)
select
    rfm_segmented.*,
   case
    when rfm in ('555', '554', '544', '545', '454', '455', '445') then 'Champions'
    when rfm in ('543', '444', '435', '355', '354', '345', '344', '335') then 'Loyal'
    when rfm in ('553', '551', '552', '541', '542', '533', '532', '531', '452', '451', '442', '441',
				 '431', '453', '433', '432', '423', '353', '352', '351', '342', '341', '333', '323') then 'Potential Loyalists'
    when rfm in ('512', '511', '422', '421', '412', '411', '311') then 'New Customers'
    when rfm in ('525', '524', '523', '522', '521', '515', '514', '513', '425', '424', '413', '414',
				 '415', '315', '314', '313') then 'Promising'
    when rfm in ('535', '534', '443', '434', '343', '334', '325', '324') then 'Need Attention'
    when rfm in ('331', '321', '312', '221', '213', '231', '241', '251') then 'About To Sleep'
    when rfm in ('255', '254', '245', '244', '253', '252', '243', '242', '235', '234', '225', '224',
				 '153', '152', '145', '143', '142', '135', '134', '133', '125', '124') then 'At Risk'
    when rfm in ('155', '154', '144', '214', '215', '115', '114', '113') then 'Cannot Lose Them'
    when rfm in ('332', '322', '233', '232', '223', '222', '132', '123', '122', '212', '211') then 'Hibernating Customers'
    when rfm in ('111', '112', '121', '131', '141', '151') then 'Lost Customers'
    else 'Other'
	end as rfm_segment
from rfm_segmented;
````
