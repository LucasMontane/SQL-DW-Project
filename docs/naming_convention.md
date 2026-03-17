# Naming Conventions

---

In this document you will find the naming conventions to be used through this project for schemas, tables, views, columns and any other object in the data warehouse

---

## Table of Contents

TBD in actual md file as Notion does not support H4 nor does it understand this table should refer to all bellow H1 title.

---

## General Rules

---

- **Language:** All names should be in **ENGLISH**
- **Naming Style:** Use [snake_case](https://en.wikipedia.org/wiki/Snake_case) for all names, all lowercase and “_” to separate words
- **Don’ts:**  Do not use SQL reserved words as object names

## Naming Tables

---

### Bronze Rules

- All names must start with the source system name, and table names muest match their original names **WITHOUT RENAMING**
- `<sourcesystem>_<entity>`
    - `<sourcesystem>` : Name of the source system (e.g., `crm` ,`erp` )
    - `<entity>` : **Exact table name** from the source system
    - Example: `crm_customer_info` → Is the customer information table as exported from system

### Silver Rules

- All names must start with the source system name, and table names muest match their original names **WITHOUT RENAMING**
- `<sourcesystem>_<entity>`
    - `<sourcesystem>` : Name of the source system (e.g., `crm` ,`erp` )
    - `<entity>` : **Exact table name** from the source system
    - Example: `crm_customer_info` → Is the customer information table as exported from system

### Gold Rules

- All names must use meaningful, business-aligned names for tables, starting with the category prefix
- `<category>_<entity>`
    - `<category>` : Describes the role of the table, such as `dim` (dimesion) or `fact` (fact table)
    - `<entity>` : Descriptive name of the table, aligned with the business domain (eg, `customers` ,`products` ,`sales` , etc)
    - Examples:
        - `dim_product` → Dimension table for product data
        - `fact_sales` → Fact table containing sales transactions

#### **Glossary of category Patterns**

| Pattern | Meaning | Examples |
| --- | --- | --- |
| `dim_` | Dimension Table | `dim_product` ,`dim_stores` |
| `fact_` | Fact Table | `fact_sales` |
| `report_` | Report Table | `report_customers` ,`report_sales_montly` |

## Naming Columns

---

### Surrogate Keys

- All primary keys in dimension tables must use the suffix `_key`
- `<table_name>_key`
    - `<table_name>` : Refers to the table or entity the key belongs to.
    - `_key` : The suffix indicating the column is a surrogate key
    - Example: `store_key` → Surrogate Key in the `dim_stores` table.

### Technical Columns

- All technical columns must start with the prefix `_dwh` , followed by a descriptive name indicating the column’s purpose
- `dwh_<column_name>`
    - `dwh_` : Prefix indicating this is a system-generated column
    - `<column_name>` : Descriptive name indicating the column’s purpose
    - Example: `dwh_job_excecution_datetime` → System-generated column that stores the job execution datetime

## Naming Stored Procedures

---

- All sotred Procedures used for loading data must follow this naming pattern:
    - `load_<layer>`
        - `<layer>` : Indicates the target layer of the Stored Procedure (`bronze` ,`silver` ,`gold` )
        - Example:
            - `load_bronze` → Stored Procedure that loads data into the Bronze Layer
            - `load_silver` → Stored Procedure that loads data into the Silver Layer