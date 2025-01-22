
-- procedures and functions for an online shop 
 
 -- the main procedure under the package 

-- APEX collections are in-memory data structures used to temporarily store data during an APEX session.
-- This block checks if a collection named 'PRODUCTS' exists.
-- If it does not exist, it creates the collection with the name 'PRODUCTS' using the apex_collection.create_collection procedure.

 CREATE OR REPLACE PACKAGE BODY manage_orders 
   AS 

   PROCEDURE add_product (p_product IN NUMBER, p_quantity IN NUMBER)
   IS 
   BEGIN 
      IF NOT apex.collection.collection_exists(p_collection => 'PRODUCTS')
      THEN 
         apex_collection.create_collection(p_collection_name => 'PRODUCTS');
         END IF;

         apex_collection.add_member(p_collection_name => 'PRODUCTS',
                                    p_c001 => p_product,
                                    p_c002 => p_quantity);
   END add_product;

-- This adds a new "member" (row) to the 'PRODUCTS' collection.
-- p_collection_name: Specifies the collection name (PRODUCTS).
-- p_c001: The first column (c001) stores the product ID (p_product).
-- p_c002: The second column (c002) stores the quantity (p_quantity).

   PROCEDURE remove_product (p_product IN NUMBER)
   IS 
      l_id NUMBER;
   BEGIN 
      IF apex.collection.collection_exists(p_collection => 'PRODUCTS')
      THEN 
         SELECT seq_id 
         INTO l_id 
         FROM apex_collections a
         WHERE collection_name = 'PRODUCTS'
         AND c001 = p_product;

         apex_collection.delete_member(p_collection_name => 'PRODUCTS',
                                       p_seq => l_id);
      
   END IF;
   END remove_product;
-- The sequence ID (seq_id) is a unique identifier for rows in an APEX collection
-- Dynamic Row Identification: The seq_id ensures that the exact row associated with the product ID is deleted.
-- This procedure removes a product from the 'PRODUCTS' collection.
-- It first checks if the collection 'PRODUCTS' exists.
-- If it does, it retrieves the sequence ID of the product to be removed.
-- It then deletes the member (row) with that sequence ID from the 'PRODUCTS' collection.

 FUNCTION get_quantity
 RETURN NUMBER
   IS 
      l_quantity NUMBER := 0;
   BEGIN
        IF apex.collection.collection_exists(p_collection => 'PRODUCTS')
        THEN 
            SELECT SUM(c002) 
            INTO l_quantity
            FROM apex_collections a
            WHERE collection_name = 'PRODUCTS'
         END IF;

         RETURN l_quantity;
   END get_quantity;

-- This function calculates the total quantity of products in the 'PRODUCTS' collection.
-- It first checks if the collection 'PRODUCTS' exists.
-- If it does, it calculates the sum of the quantities (c002) of all products in the collection.

 PROCEDURE clear_cart
  IS
  BEGIN
      IF apex_collection.collection_exists (p_collection_name => 'PRODUCTS')
      THEN
        apex_collection.truncate_collection(p_collection_name => 'PRODUCTS');
      END IF;
  END clear_cart;

-- This procedure clears all products from the 'PRODUCTS' collection.
-- It first checks if the collection 'PRODUCTS' exists.
-- If it does, it truncates (empties) the collection.

FUNCTION customer_exists(product_id IN NUMBER)
RETURN NUMBER 
IS 
 l_customer customers.customer_id%TYPE;

BEGIN 
  SELECT customer_id
  INTO l_customer
  FROM customers
  WHERE email_address = p_customer_id;
  
  RETURN l_customer;

  EXCEPTION 
  WHEN NO_DATA_FOUND THEN 
    RETURN 0;
END customer_exists;

-- This function checks if a customer with the given email address exists in the 'customers' table.
-- It takes the email address as input and returns the customer ID if the customer exists.
-- If no customer is found, it returns 0.

PROCEDURE create_order(p_customer_id IN VARCHAR2,
                      p_customer_id IN NUMBER, 
                      p_store IN NUMBER,
                      p_order_id OUT NUMBER,
                      p_customer_id OUT NUMBER)

IS
BEGIN
   p_customer_id := customer_exists(p_customer_id);
   
   IF p_customer_id = 0
   THEN
      INSERT INTO customers (full_name,email_address)
      VALUES (p_customer_id,p_customer_id)
      RETURNING customer_id INTO p_customer_id;
   END IF;
   
   INSERT INTO orders (customer_id, store_id)
   VALUES (p_customer_id, p_store)
   RETURNING customer_id INTO p_customer_id;
   END IF;

-- This procedure creates a new order for a customer.
-- It first checks if the customer exists by calling the customer_exists function.

INSERT INTO orders (order_datetime,customer_id,store_id,order_status)
VALUES (SYSDATE,p_customer_id,p_store,'OPEN')
returning order_id INTO p_order_id;

IF apex_collection.collection_exists(p_collection => 'PRODUCTS')
THEN
   INSERT INTO order_items (order_id,line_item_id,product_id,unit_price,quantity)
   SELECT p_order_id,seq_id,p.product_id,p.unit_price,n002
   FROM apex_collections a, products p
   WHERE collection_name = 'PRODUCTS'
   
END IF;
apex_collection.delete_collection(p_collection_name => 'PRODUCTS');
END create_order;

-- This procedure creates a new order in the 'orders' table.
-- It first checks if the 'PRODUCTS' collection exists.
-- If it does, it inserts the order details into the 'orders' table and the order items into the 'order_items' table.
-- It then deletes the 'PRODUCTS' collection to clear the cart.

END manage_orders;
/

            

   