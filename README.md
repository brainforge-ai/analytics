# dummyclient dbt code repository

## Setup Project

Run the following commands to clone the project and then create virtual enviroment

```bash
git clone git@github.com:brainforge-ai/analytics.git
cd analytics
make dev-env
```

Please use below given template to create a .env file
dot_env is dummy file, please use same env variables but remember to update the values

```bash
    dot_env -> .env
```

Run the following command to add environemtns variable to your virtual env

FOR LINUX

```bash
printf "\nexport \$(grep -v '^#' .env | xargs)" >> env/bin/activate
```

FOR WINDOWS (bash or git bash terminal )

```bash
printf "\nexport \$(grep -v '^#' .env | xargs)" >> env/Scripts/activate
```


Perfect 👍 — here’s an updated **README.md** that matches your setup (`load_data_to_duckdb.py` inside the `DATA/` folder).

---

# Shopify dbt + DuckDB Demo

This project demonstrates how to take **sample Shopify JSONL data**, load it into **DuckDB**, and then use **dbt** to build models on top of it.

---

## 📂 Project Structure

```
.
├── DATA/
│   ├── portable_shopify.customers.sample.jsonl
│   ├── portable_shopify.products.sample.jsonl
│   ├── portable_shopify.orders.sample.jsonl
│   └── load_data_to_duckdb.py     # Python loader script
├── dbt_project.yml    
│   ├── shopify.duckdb                 # DuckDB database (created by script)
│   │
├── profiles.yml                   # dbt profile for duckdb
└── models/
    ├── raw/                       # raw models (shopify source tables)
    └── intermediate/              # intermediate transformations
    └── marts/              # marts transformations
```

---

## ⚙️ Requirements

* **Python 3.9+**
* **DuckDB**

  ```bash
  pip install duckdb
  ```
* **dbt-duckdb**

  ```bash
  pip install dbt-duckdb
  ```

---

## 🚀 Workflow

### 1. Place sample data

Make sure your Shopify JSONL files are inside the `DATA/` folder:

* `portable_shopify.customers.sample.jsonl`
* `portable_shopify.products.sample.jsonl`
* `portable_shopify.orders.sample.jsonl`

### 2. Load data into DuckDB

Run the loader script from inside the `DATA/` folder:

```bash
cd DATA
python load_data_to_duckdb.py
```

This will:

* Create (or overwrite) `shopify.duckdb` in the **project root**
* Create three tables: `customers`, `products`, and `orders`
* Print row counts and sample rows for validation

### 3. Verify in DuckDB

You can connect to the database interactively:

```bash
duckdb ../shopify.duckdb
```

Run a few checks:

```sql
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
```

### 4. Configure dbt

Update your `profiles.yml` to point to DuckDB:

```yaml
dummyclient:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: shopify.duckdb
      schema: main
      threads: 4
```

In `dbt_project.yml`, define Shopify sources:

```yaml
sources:
  - name: shopify
    schema: main
    tables:
      - name: customers
      - name: products
      - name: orders
```

### 5. Run dbt models

Now you can run:

```bash
dbt run
```

This will build all the raw + intermediate Shopify models using your sample data inside DuckDB.
