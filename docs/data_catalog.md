# Data Dictionary for Gold Layer

## Overview

The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of dimension tables and fact tables for specific business metrics.

---

### 1. gold.dim_customers

- **Purpose:** Stores customer details with demographic and geographic data
- **Columns:**

| Column Name     | Data Type    | Description                                                                          |
| --------------- | ------------ | ------------------------------------------------------------------------------------ |
| customer_key    | INT          | Surrogate key uniquely identifying each customer record in the dimention table       |
| customer_id     | INT          | Unique numerical identifier assigned to each customer                                |
| customer_number | NVARCHAR(50) | Alphanumeric identifier representing the customer, using for tracking and referncing |
| first_name      | NVARCHAR(50) | The customer's first name, as recorded in the system                                 |
| last_name       | NVARCHAR(50) | The customer's last name, as recorded in the system                                  |
| country         | NVARCHAR(50) | The country of recidency of the customer (eg., 'Australia')                          |
| marital_status  | NVARCHAR(50) | The marital status of the customer (eg.,'Married', 'Single')                         |
| gender          | NVARCHAR(50) | The gender of the customer (eg.,'Male')                                              |
| birthdate       | DATE         | the date of birth of the customer, formated YYYY-MM-DD (eg., 1992-09-20)             |
| create_date     | DATE         | the date when the customer was created in the system                                 |

---

### 2. gold_dim_products

- **Purpose:** Stores information about the products and their atributes. No historic product data is provided, only the current information of each product is present.
- **Columns:**

| Column Name    | Data Type    | Description                                                                                          |
| -------------- | ------------ | ---------------------------------------------------------------------------------------------------- |
| product_key    | INT          | Surrogate key uniquely identifying each product record in the product dimension table.               |
| product_id     | INT          | A unique identifier assigned to the product for internal tracking and referencing.                   |
| product_number | NVARCHAR(50) | A structured alphanumeric ocde representing the product, often used for categorization or inventory. |
| product_name   | NVARCHAR(50) | Descriptive name of the product, including details such as type, color and size.                     |
| category_id    | NVARCHAR(50) | A unique identifier for the product's category, liking to its high-level calssification.             |
| category       | NVARCHAR(50) | The broader classification of the product (e.g., 'Bikes', 'Components') to group related items.      |
| subcategory    | NVARCHAR(50) | A more detailed classification of the product within the category, such as product type.             |
| maintenance    | NVARCHAR(50) | Indicates wether the product requieres maintenance (eg.,'Yes','No').                                 |
| cost           | INT          | The cost or base price of the product, mesured in monetary units.                                    |
| product_line   | NVARCHAR(50) | The specific product line or series to wich the product belings (eg.,'Road','Mountain').             |
| start_date     | DATE         | The date when the product became available for sale or use                                           |

---

### 3.**gold.fact_sales**

- **Purpose:** Stores transactional sales data for analytical purposes.
- **Columns:**

| Column Name   | Data Type    | Description                                                                                                                              |
| ------------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| order_number  | NVARCHAR(50) | A unique alphanumeric identifier for each sales order (eg.,'SO54496').                                                                   |
| product_key   | INT          | Surrogate key linking the order to the product dimnesion table.                                                                          |
| customer_key  | INT          | Surrogate key linking the order to the customer dimension table.                                                                         |
| order_date    | DATE         | The date when the order was placed.                                                                                                      |
| shipping_date | DATE         | The date when the order was shipped to the customer.                                                                                     |
| due_date Date | DATE         | The date when the order payment was due.                                                                                                 |
| quantity      | INT          | The number of units of the product ordered for the line item (eg., 1).                                                                   |
| price         | INT          | The price per unit of the product for the line item, in whole currency units (eg., 25, 40).                                              |
| sales_amount  | INT          | The total monetary value of the sale for the line item, in whole currency item (eg.,30). It is the multiplication of Price and Quantity. |
