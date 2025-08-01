# 🍽️ Food Delivery Insights

This project simulates a real-world analytics workflow for a food delivery company using SQL and Python. The goal is to uncover actionable insights around customer behavior, delivery efficiency, and regional demand patterns using a relational data model.

---

## 📊 Project Objectives

- Mimic an industry-level delivery analytics pipeline
- Load correlated datasets into a relational database (MySQL)
- Answer critical business questions using SQL
- Practice integrating AWS S3, Python scripting, and RDBMS concepts

---

## 🗂️ Dataset Overview

The dataset consists of 5 interrelated CSV files representing core operations of a food delivery company:

- `customers.csv`
- `drivers.csv`
- `restaurants.csv`
- `orders.csv`
- `order_items.csv`

The data was generated to simulate real-world patterns like order frequencies, delivery regions, cuisine preferences, etc., while maintaining referential integrity across tables.

---

## 🛠️ Tech Stack

| Tool        | Purpose                                   |
|-------------|-------------------------------------------|
| **Python**  | Data ingestion from AWS S3 to MySQL       |
| **MySQL**   | Relational database for analytics         |
| **SQL**     | Business logic and insights generation    |
| **AWS S3**  | Cloud storage for raw datasets            |

### Important Python Libraries Used:
- `pandas`
- `boto3`
- `s3fs`
- `SQLAlchemy`

---

## 🔁 Project Workflow

1. **Data Preparation**  
   - Designed relational schema with primary & foreign key constraints
   - Ensured no orphan records, duplicate IDs, or mismatched dates

2. **Data Hosting**  
   - Uploaded CSV files to AWS S3 bucket

3. **Data Ingestion**  
   - Pulled data from S3 to local system using Python
   - Loaded into MySQL database using `pandas` and `SQLAlchemy`

4. **Data Analysis**  
   - Performed analysis via SQL scripts using joins, aggregates, window functions, and date/time logic

---

## ❓ Business Questions Answered

1. **What is the average delivery time across different regions?**
2. **Who are the top 5 most frequent customers by order count or spending?**
3. **What are the peak hours for food orders?**
4. **Which restaurants have the highest failure/cancellation rates?**
5. **What cuisines are most popular based on number of delivered orders or items sold?**
6. **What is the customer retention rate or re-order behaviour over months or CLV?**
7. **Are there specific regions or restaurants driving unusually high demand in recent months (demand spikes)?**

---

## 📂 Project Structure

```
Food-Delivery-Insights/
│
├── data/
│   └── (raw CSVs stored in AWS S3)
│
├── src/
│   ├── python
│         ├── extract_and_load.py           
│   └── sql           
│         ├── DDL.sql
│         ├── DML.sql
│         ├── analysis.sql
├── README.md
└── requirements.txt
└── BRD.pdf
```

---

## 🚀 How to Reproduce

1. Clone the repository

 ```bash
   git clone https://github.com/HeatTransfer/food-delivery-insights.git
 ```

2. Upload the provided CSVs to your own AWS S3 bucket

3. Set up your MySQL database (locally or hosted)

4. Run extract_and_load.py to extract and ingest the data

5. Run analysis.sql in MySQL to generate insights

--- 

## 📌 Key Learnings

* Hands-on experience with cloud data ingestion

* Designed a normalized relational schema

* Practiced real-world SQL analytics with joins, aggregates, and window functions

* Understood business-driven questions from operational data

## 🧠 Future Enhancements

* Migrate to Snowflake or Amazon Redshift

* Automate the data pipeline using Airflow

* Add data visualizations using Power BI or Tableau

* Build a dashboard or report layer for stakeholders

---

## 📌 Author

**Shreyajyoti Dutta**
🔗 [LinkedIn Profile](https://www.linkedin.com/in/shreyajyoti-dutta)
📫 Open to opportunities in Data Analytics, Data Engineering, and BI

---

## 🏷️ Tags

`SQL` `Python` `Cloud Data Engineering` `Data Engineering` `ETL` `Business Insights` `Data Analytics` `Amazon S3`
