import os
import pandas as pd
import s3fs
from dotenv import load_dotenv
from sqlalchemy import create_engine
import pymysql

# Load credentials from .env
load_dotenv()

# Configs
target_bucket = 'food-delivery-bucket-20250730'
folder = 'food_delivery_dataset'

try:
    fs = s3fs.S3FileSystem()
    file_paths = fs.ls(f"{target_bucket}/{folder}/")
    print("Connected to S3.")
except Exception as e:
    print(f"Failed to connect to S3: {e}")
    exit(1)

try:
    engine = create_engine(
        f"mysql+pymysql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}@{os.getenv('DB_HOST')}/{os.getenv('DB_NAME')}"
    )
    print("Connected to MySQL database.")
except Exception as e:
    print(f"MySQL connection FAILED: {e}")
    exit(1)

# S3 Object -> DB Table mapping for specific insertion
s3_db_mapping = {
    'customers.csv': 'customer',
    'drivers.csv': 'driver',
    'restaurants.csv': 'restaurant',
    'orders.csv': 'orders',
    'order_items.csv': 'order_item'
}

# Process each file
ordered_files = ['customers.csv', 'drivers.csv', 'restaurants.csv', 'orders.csv', 'order_items.csv']

for file_name in ordered_files:
    file_path = f"{target_bucket}/{folder}/{file_name}"
    sql_tbl_name = s3_db_mapping[file_name]

    if fs.exists(file_path):
        try:
            for chunk in pd.read_csv(f"s3://{file_path}", chunksize=10000): # future-proof, if and when file size is large
                chunk.to_sql(sql_tbl_name, engine, if_exists='append', index=False)
            
            print(f"Loaded {file_name} -> {sql_tbl_name}")
        except Exception as e:
            print(f"Failed to load {file_name}: {e}")