--
-- This file conains SQL/JSON examples over the JSON "cart" collection
-- used by the MuShop shopping cart service.
--
-- The full documentation for SQL/JSON can be found here:
--    https://docs.oracle.com/en/database/oracle/oracle-database/19/adjsn/

-- You can execute these queries in any Oracle SQL client but SQL Developer Web
-- is a convienent when using the autonomous database:
--    https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/user/sql-developer-web.html


-- Example 1:
--   JSON document collections are backed by a special type of table with a
--   primary key column corresponding to the document id, a JSON column
--   corresponding to the document, and some additional metadata columns.
--   This first query selects the document id and the document in a SQL
--   SELECT query.  The json_serialize converts the document to JSON text so
--   that it may be viewed by the client.

SELECT c.id, json_serialize(c.json_document)
FROM carts c;

-- Example 2:
--   Simple dot notation can be used to select values from within JSON.  The following
--   query returns the document id, the customer id, the number of distinct items
--   for each cart, and the total price of the items in the cart.

SELECT c.id,
       c.json_document.customerId,
       c.json_document.items.count() totItems,
       c.json_document.items.unitPrice.sum() totPrice
FROM cart c;


-- Example 3:
--   Aggregate queries can also be used over JSON data.  The next example
--   groups carts by the total number of items in each cart.

SELECT count(*) numCarts, c.json_document.items.quantity.sum() itemCount
FROM cart c
GROUP BY c.json_document.items.quantity.sum()

-- Example 4:
--  Nested arrays of data can be mapped to rows using the SQL NESTED clause
--  (a short-hand syntax for the JSON_TABLE() operator).  See:
--  https://docs.oracle.com/en/database/oracle/oracle-database/19/adjsn/function-JSON_TABLE.html
--  The query returns a row for each cart and each item.

SELECT c.*
FROM cart
   NESTED json_document
   COLUMNS (customerId, NESTED items[*] COLUMNS (quantity NUMBER, itemId, unitPrice NUMBER)) c;

-- Example 5:
--  Relational views can be created using SQL/JSON operators.

CREATE VIEW items AS
  SELECT c.*
  FROM cart
     NESTED json_document
     COLUMNS (customerId, NESTED items[*] COLUMNS (quantity NUMBER, itemId, unitPrice NUMBER)) c;

SELECT * FROM items;

-- Example 6:
--   JSON and relational data can be queried together.  The following multimodel
--   query joins carts with the user tables.  It selects the name
--   and email of customers with a cart total greater than 10 dollars.   Note
--   that MuShop only assigns a customerId to a cart if the user is logged in.

SELECT u."firstName", u."email"
FROM "user" u, cart c
WHERE u."id" = c.json_document.customerId AND
      c.json_document.items.unitPrice.sum() > 10;

-- Example 7:
--   The next example does a 3-way join between users, products, and cart items.

SELECT u."firstName", u."email", p.title, c.quantity, p.qty
FROM products p,
     "user" u,
     cart NESTED json_document COLUMNS(customerId, NESTED items[*] COLUMNS(itemId, quantity)) c
WHERE u."id" = customerId AND
      itemId = p.sku AND p.qty > 10;
