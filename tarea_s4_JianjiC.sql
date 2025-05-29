########## Nivell 1
###crear un esquema, tablas y introducir los datos

CREATE DATABASE tarea_s4;
USE tarea_s4;

CREATE TABLE companies(
    company_id VARCHAR(20) PRIMARY KEY,
    company_name VARCHAR(255),
	phone VARCHAR(15),
	email VARCHAR(100),
	country VARCHAR(100),
	website VARCHAR(255));
    
CREATE TABLE credit_cards(
    card_id VARCHAR(20) PRIMARY KEY,
    user_id INT REFERENCES users(id),
    iban VARCHAR(50),
    pan VARCHAR(50),
    pin VARCHAR(4),
    cvv INT,
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date VARCHAR(20));

CREATE TABLE users(
    user_id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(150),
	email VARCHAR(150),
    birth_date VARCHAR(100),
    country VARCHAR(150),
    city VARCHAR(150),
    postal_code VARCHAR(100),
    address VARCHAR(255));
    
CREATE TABLE transactions(
    transaction_id VARCHAR(255) PRIMARY KEY,
    card_id VARCHAR(15) REFERENCES credit_cards(id),
    company_id VARCHAR(20) REFERENCES companies(company_id),
    timestamp TIMESTAMP,
    amount DECIMAL(10, 2),
    declined BOOLEAN,
    product_ids VARCHAR(255),
    user_id INT REFERENCES users(id),
    lat FLOAT,
    longitude FLOAT,
    FOREIGN KEY (company_id) REFERENCES companies(company_id),
    FOREIGN KEY (card_id) REFERENCES credit_cards(card_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id));

LOAD DATA LOCAL INFILE
"C:\\EEE\\IT Academy_Analisis de Dades\\Especialitazacio_DA\\Tasca S4.01. Creacio de Base de Dades\\companies.csv"
INTO TABLE companies
CHARACTER SET 'UTF8MB4'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE
"C:\\EEE\\IT Academy_Analisis de Dades\\Especialitazacio_DA\\Tasca S4.01. Creacio de Base de Dades\\credit_cards.csv"
INTO TABLE credit_cards
CHARACTER SET 'UTF8MB4'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE
"C:\\EEE\\IT Academy_Analisis de Dades\\Especialitazacio_DA\\Tasca S4.01. Creacio de Base de Dades\\users_ca.csv"
INTO TABLE users
CHARACTER SET 'UTF8MB4'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE
"C:\\EEE\\IT Academy_Analisis de Dades\\Especialitazacio_DA\\Tasca S4.01. Creacio de Base de Dades\\users_uk.csv"
INTO TABLE users
CHARACTER SET 'UTF8MB4'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE
"C:\\EEE\\IT Academy_Analisis de Dades\\Especialitazacio_DA\\Tasca S4.01. Creacio de Base de Dades\\users_usa.csv"
INTO TABLE users
CHARACTER SET 'UTF8MB4'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE
"C:\\EEE\\IT Academy_Analisis de Dades\\Especialitazacio_DA\\Tasca S4.01. Creacio de Base de Dades\\transactions.csv"
INTO TABLE transactions
CHARACTER SET 'UTF8MB4'
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

### Exercici 1
# Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.
SELECT u.*
FROM users u
INNER JOIN transactions t
ON u.user_id = t.user_id
GROUP BY u.user_id
HAVING COUNT(t.transaction_id) > 30;

### Exercici 2
# Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd.,
# utiliza por lo menos 2 tablas.
SELECT c.company_name, cc.iban, AVG(t.amount) AS mean_sale
FROM transactions t
INNER JOIN credit_cards cc
ON t.card_id = cc.card_id
INNER JOIN companies c
ON t.company_id = c.company_id
WHERE c.company_name = "Donec Ltd"
GROUP BY c.company_name, cc.iban;


########## Nivell 2
### crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en
### si les últimes tres transaccions van ser declinades i genera la següent consulta:
### Exercici 1 Quantes targetes estan actives?
## (1) crear la tabla
CREATE TABLE card_status
SELECT 
    CONCAT(tt.transaction_id, "_", tt.card_id) AS transaction_card_id,
    tt.transaction_id, tt.card_id,
    STR_TO_DATE(cc.expiring_date, '%m/%d/%Y') AS expiring_date,
    tt.timestamp, tt.declined
FROM credit_cards cc
JOIN (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS rn
    FROM transactions) tt
ON cc.card_id = tt.card_id
WHERE tt.rn <= 3;

ALTER TABLE card_status
	MODIFY transaction_card_id VARCHAR(255) PRIMARY KEY,
    ADD FOREIGN KEY (card_id) REFERENCES credit_cards(card_id);    
SELECT * FROM card_status;

## (2) consulta: cantidad de tarjectas activas actucalmente
SELECT COUNT(DISTINCT card_id) AS num_card_active
FROM card_status
WHERE expiring_date > NOW();



########## Nivell 3
### Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de
### dades creada, tenint en compte que des de transaction tens product_ids. Genera la següent consulta:
### Exercici 1: Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
## (1) crear la tabla "products" e introducir los datos
CREATE TABLE products(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price VARCHAR(20),
    colour VARCHAR(20),
    weight DECIMAL(10, 1),
    warehouse_id VARCHAR(20));
    
LOAD DATA LOCAL INFILE
"C:\\EEE\\IT Academy_Analisis de Dades\\Especialitazacio_DA\\Tasca S4.01. Creacio de Base de Dades\\products.csv"
INTO TABLE products
CHARACTER SET 'UTF8MB4'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

UPDATE products
SET price = REPLACE(price, "$", "")
WHERE product_id <> "";

ALTER TABLE products
MODIFY price DECIMAL(10, 2);

SELECT * FROM products;

## (2) encontrar la cantidad maxima de productos por transaction
SELECT SUM(LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ",", "")) + 1) AS num_product
FROM transactions
GROUP BY transaction_id
ORDER BY num_product DESC
LIMIT 1;

## (3) crear una tabla “numbers” de numeros de 1 hasta 10 (ser flexible), más que la cantidad maxima de productos por transaction
## para separar product_ids en la tabla transactions
CREATE TABLE numbers(
  n int);
INSERT INTO numbers VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10);

## (4) separar product_ids y crear una nueva tabla
CREATE TABLE transactions_products
SELECT
    CONCAT(t.transaction_id, "_",
        SUBSTRING_INDEX(SUBSTRING_INDEX(t.product_ids, ", ", n.n), ", ", -1))
		AS transaction_product_id,
	transaction_id,
    SUBSTRING_INDEX(SUBSTRING_INDEX(t.product_ids, ", ", n.n), ", ", -1) AS product_id
FROM transactions t
INNER JOIN numbers n
ON n.n <= LENGTH(t.product_ids) - LENGTH(REPLACE(t.product_ids, ",", "")) + 1;

ALTER TABLE transactions_products
    ADD PRIMARY KEY(transaction_product_id),
    ADD FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    MODIFY product_id INT,
    ADD FOREIGN KEY (product_id) REFERENCES products(product_id);

SELECT * FROM transactions_products;

## (5) consulta: el nombre de vegades que s'ha venut cada producte.
SELECT tp.product_id, p.product_name, COUNT(DISTINCT tp.transaction_id) AS num_transactions
FROM transactions t
JOIN transactions_products tp
ON t.transaction_id = tp.transaction_id
JOIN products p
ON tp.product_id = p.product_id
WHERE t.declined = 0
GROUP BY tp.product_id
ORDER BY num_transactions DESC;
