# Credit_Card_Transactions

📊 **A PostgreSQL-based SQL Analysis Project on Credit Card Transactions**

This project involves in-depth analysis of credit card transaction data using **Common Table Expressions (CTEs)** and advanced SQL techniques in **PostgreSQL**. The goal is to uncover meaningful insights about spending behavior across different cities, card types, expense categories, and demographics.

## 📥 Dataset Overview

The dataset contains the following columns:

| Column Name       | Description                      |
|-------------------|----------------------------------|
| `transaction_id`  | Unique ID for each transaction   |
| `city`            | City where the transaction occurred |
| `transaction_date`| Date of the transaction          |
| `card_type`       | Type of credit card used         |
| `exp_type`        | Expense type (e.g., Fuel, Bills) |
| `gender`          | Gender of the cardholder         |
| `amount`          | Amount spent in the transaction  |

## 🔧 Technologies Used

- **PostgreSQL** – For database management and query execution
- **SQL** – Advanced querying using CTEs, window functions, and recursive logic
- **Data Analysis Techniques**: Aggregation, filtering, grouping, cumulative sums, ranking, and date manipulation

## 🧠 Key Analyses & Insights

The following business questions were addressed using SQL queries with a focus on **CTEs** and performance optimization:

1. ✅ **Top 5 Cities by Spend**
   - Identified the top 5 cities based on total spends.
   - Calculated their percentage contribution to overall credit card spending.

2. ✅ **Highest Spend Month per Card Type**
   - Found the month with the highest spending for each card type.

3. ✅ **First Transaction Where Each Card Type Crosses ₹1,000,000 Total Spend**
   - Retrieved the exact transaction record when each card type reached or exceeded a cumulative spend of ₹1,000,000.

4. ✅ **City with Lowest Gold Card Spend Percentage**
   - Determined which city had the lowest percentage of spending done using Gold cards.

5. ✅ **City-wise Highest and Lowest Expense Types**
   - Listed each city along with its highest and lowest spending categories.

6. ✅ **Female Spending Contribution by Expense Type**
   - Calculated the percentage of total spending by females across various expense types.

7. ✅ **Highest MoM Growth in Jan-2014**
   - Identified the card and expense type combination that saw the highest month-over-month growth in January 2014.

9. ✅ **Weekend Spend-to-Transaction Ratio**
   - Found the city with the highest ratio of total weekend spending to number of weekend transactions.

10. ✅ **Fastest City to Reach 500 Transactions**
    - Determined which city reached its 500th transaction the quickest after its first transaction.

## 📁 Project Structure
