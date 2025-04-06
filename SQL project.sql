drop table if exists transactions;
create table transactions(
			transaction_id INT PRIMARY KEY,	
			city VARCHAR(65),
			transaction_date DATE,	
			card_type VARCHAR(55),
			exp_type VARCHAR(45),
			gender VARCHAR(10),
			amount FLOAT
)

select count(*) from transactions;

-- DATA CLEANING
select *
from transactions
where transaction_id is null
		or
		city is null
		or 
		transaction_date is null
		or 
		card_type is null
		or
		exp_type is null
		or 
		gender is null
		or 
		amount is null;

-- Exploratory Data

 -- How many cities we have?

 select count(distinct city) 
 from transactions;

 -- What are the types of cards we have?

  select 
		distinct card_type
 from transactions;
 
-- Which cities have the highest spending?

select city,
		sum(amount) as total_spending
from transactions
group by city
order by 2 desc;

-- Which card type generates the highest total spend?

select card_type,
		count(transaction_id) as total_transactions,
        sum(amount) as total_spend,
        avg(amount) as avg_spend_per_transaction
from transactions
group by card_type
order by sum(amount) desc;


-- DATA ANALYSIS

-- Q1 -write a query to print top 5 cities with highest spends 
-- and their percentage contribution of total credit card spends 

with CitySpends as (
		select city,
				sum(amount) as total_spend
		from transactions
		group by city
),
TotalSpends as (
		select 
				sum(amount) as overall_total_spend
		from transactions
)
select cs.city,
		cs.total_spend,
		round((cs.total_spend::NUMERIC / NULLIF(ts.overall_total_spend::NUMERIC, 0)) * 100, 2) as percentage_contribution
from CitySpends cs,
	TotalSpends ts
order by cs.total_spend desc
limit 5;

-- Q2 -Write a query to print highest spend month and  
-- amount spent in that month for each card type

with MonthlySpends as (
	select card_type,
			date_trunc('month', transaction_date) as year_month,
			sum(amount) as total_spend
	from transactions
	group by card_type, date_trunc('month', transaction_date)
),
RankedSpends as (
	select card_type,
			year_month,
			total_spend,
			row_number() over(partition by card_type order by total_spend desc) as rank
	from MonthlySpends 
)
select card_type,
		to_char(year_month, 'YYYY-MM') as highest_spend_month,
		total_spend as amount_spend
from RankedSpends
where rank = 1;

-- Q3 -Write a query to print the transaction details(all columns from the table)
-- for each card type when it reaches a cumulative of 1000000 total spends(we should have 4 rows
-- in the o/p one for each card type)

with CumulativeSpends as (
	select *,
			sum(amount) over(partition by card_type order by transaction_date) as cumulative_spend
	from transactions
),
FilteredTransactions as (
	select *,
			row_number() over(partition by card_type order by transaction_date) as rank
	from CumulativeSpends
	where cumulative_spend >= 1000000
)
select *
from FilteredTransactions
where rank = 1;


-- Q4 -Write a query to find city which had lowest
-- percentage spend for gold card type

with GoldCardSpend as (
	select city,
			sum(amount) as total_spend
	from transactions
	where card_type = 'Gold'
	group by city
),
TotalGoldSpend as (
	select 
			sum(amount) as overall_total_spend
	from transactions
	where card_type = 'Gold' 
),
CityPercentage as (
	select gcs.city,
			(gcs.total_spend::NUMERIC/ NULLIF(tgs.overall_total_spend::NUMERIC, 0)) * 100 as percentage_spend
	from GoldCardSpend gcs
	cross join TotalGoldSpend tgs
)
select city,
		round(percentage_spend, 2) as lowest_percentage_spend
from CityPercentage
where percentage_spend = (select 
								min(percentage_spend)
								from CityPercentage
							);


-- Q5 -Write a query to print 3 columns: city, highest_expense_type,
-- lowest_expense_type (example: Delhi, bills, fuel).

with CityExpenseTotals as (
	select city,
			exp_type,
			sum(amount) as total_spend
	from transactions
	group by city, exp_type
),
RankedExpenses as (
	select city,
			exp_type,
			total_spend,
			row_number() over(partition by city order by total_spend desc) as highest_rank,
			row_number() over(partition by city order by total_spend asc) as lowest_rank
	from CityExpenseTotals
)
select distinct
		city,
		max(case when highest_rank = 1 then exp_type end) as highest_expense_type,
		max(case when lowest_rank = 1 then exp_type end) as lowest_expense_type
from RankedExpenses
group by city
order by city;

-- Q6 -Write a query to find percentage contribution of spends
-- by females for each expense type

with TotalSpends as (
	select exp_type,
			sum(amount) as total_spend
	from transactions
	group by exp_type
),
FemaleSpends as (
	select exp_type,
			sum(amount) as female_spend
	from transactions
	where gender = 'F'
	group by exp_type
)
select fs.exp_type,
		round((fs.female_spend::NUMERIC) / NULLIF(ts.total_spend::NUMERIC, 0) * 100, 2) as percentage_female_contribution
from FemaleSpends fs
join TotalSpends ts
on fs.exp_type = ts.exp_type
order by fs.exp_type;

-- Q7 -Which card and expense type combination saw highest month
-- over month growth in jan-2014.

with MonthlySpends as (
	select card_type,
			exp_type,
			date_trunc('month', transaction_date) as year_month,
			sum(amount) as total_spend
	from transactions 
	where transaction_date >= '2013-12-01' and transaction_date < '2014-02-01'
	group by card_type, exp_type, date_trunc('month', transaction_date)
),
MonthOverMonthGrowth as (
	select ms1.card_type,
			ms1.exp_type,
			ms1.year_month as jan_2014,
			ms1.total_spend as jan_spend,
			ms2.year_month as dec_2013,
			ms2.total_spend as dec_spend,
			(ms1.total_spend - COALESCE(ms2.total_spend, 0)) as growth
	from MonthlySpends ms1
	left join MonthlySpends ms2
	on ms1.card_type = ms2.card_type
		and	ms1.exp_type = ms2.exp_type
		and ms2.year_month = '2013-12-01'::DATE
	where ms1.year_month = '2014-01-01'::DATE
)
select card_type,
		exp_type,
		jan_spend,
		dec_spend,
		growth
from MonthOverMonthGrowth
where growth = (select max(growth) from MonthOverMonthGrowth);

-- Q8 -During weekends which city has highest total spend
-- to total no of transactions ratio

with WeekendTransactions as (
	select city,
			sum(amount) as total_spend,
			count(transaction_id) as total_transactions
	from transactions 
	where extract(DOW from transaction_date) in (0, 6)
	group by city
),
CityRatios as (
	select city,
			total_spend,
			total_transactions,
			(total_spend::NUMERIC / NULLIF(total_transactions::NUMERIC, 0)) as spend_ratio
	from WeekendTransactions
)
select city,
		total_spend,
		total_transactions,
		round(spend_ratio, 2) as highest_spend_ratio
from CityRatios
where spend_ratio = (select max(spend_ratio) from CityRatios);

-- Q9 -Which city took least number of days to reach its 500th
-- transaction after the first transaction in that city

with CityTransactions as (
	select city,
			transaction_date,
			row_number() over(partition by city order by transaction_date) as transaction_rank
	from transactions 
),
FirstAnd500th as (
	select ct1.city,
			ct1.transaction_date as first_transaction_date,
			ct2.transaction_date as five_hundredth_transaction_date
	from CityTransactions ct1
	join CityTransactions ct2
	on ct1.city = ct2.city
	where ct1.transaction_rank = 1
			and ct2.transaction_rank = 500
)
select city,
		first_transaction_date,
		five_hundredth_transaction_date,
		(five_hundredth_transaction_date - first_transaction_date) as days_to_reach_500
from FirstAnd500th
where (five_hundredth_transaction_date - first_transaction_date) = (
									select 
									min((five_hundredth_transaction_date - first_transaction_date))
									from FirstAnd500th
									);



	




