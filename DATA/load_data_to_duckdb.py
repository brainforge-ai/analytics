"""
load_shopify_to_duckdb.py

This script loads synthetic Shopify sample data (JSONL) into DuckDB tables,
then prints 5 sample rows from each table.
"""

import os
import duckdb


def main():
    # Use current directory for locating JSONL files
    base_dir = os.path.dirname(os.path.abspath(__file__))

    # File paths
    customers_file = os.path.join(base_dir, "portable_shopify.customers.sample.jsonl")
    products_file = os.path.join(base_dir, "portable_shopify.products.sample.jsonl")
    orders_file = os.path.join(base_dir, "portable_shopify.orders.sample.jsonl")

    # Connect to DuckDB (file-backed database in current dir)
    db_path = os.path.join(os.path.dirname(base_dir), "dbt_project", "shopify.duckdb")
    con = duckdb.connect(db_path)

    # Load JSON extension
    con.execute("INSTALL json;")
    con.execute("LOAD json;")

    # Create tables from JSONL files
    print("Loading data into DuckDB...")

    # con.execute(
    #     f"CREATE OR REPLACE TABLE customers AS SELECT * FROM read_json_auto('{customers_file}')"
    # )
    # con.execute(
    #     f"CREATE OR REPLACE TABLE products AS SELECT * FROM read_json_auto('{products_file}')"
    # )
    # con.execute(
    #     f"CREATE OR REPLACE TABLE orders AS SELECT * FROM read_json_auto('{orders_file}')"
    # )

    # Show counts
    print("\nRow counts:")
    for table in ["customers", "products", "orders"]:
        count = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        print(f"  {table}: {count}")

    # Print 5 sample rows from each table
    print("\nSample rows:")
    for table in ["customers", "products", "orders"]:
        print(f"\n--- {table.upper()} ---")
        df = con.execute(f"SELECT first_name FROM customers LIMIT 5").fetchdf()
        print(df)

    # Close connection
    con.close()


if __name__ == "__main__":
    main()
