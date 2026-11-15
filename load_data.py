import sqlite3
import pandas as pd
from pathlib import Path

files = {
    "olist_customers_dataset.csv": "customers",
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "payments",
    "olist_order_reviews_dataset.csv": "reviews",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "product_category_name_translation.csv": "category_translation",
}

conn = sqlite3.connect("olist.db")
for fname, table in files.items():
    df = pd.read_csv(Path("data/raw") / fname)
    df.to_sql(table, conn, if_exists="replace", index=False)
    print(table, len(df))
conn.close()