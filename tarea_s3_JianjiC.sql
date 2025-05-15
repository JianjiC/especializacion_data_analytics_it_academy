########## Nivell 1
### Exercici 1
# La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi
# detalls crucials sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar
# de manera única cada targeta i establir una relació adequada amb les altres dues taules
# ("transaction" i "company"). Després de crear la taula serà necessari que ingressis
# la informació del document denominat "dades_introduir_credit".
# Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.

USE transactions;
## relacionar a la tabla "transaction"
CREATE INDEX idx_credit_card_id ON transaction(credit_card_id);
## el esquema de la tabla
CREATE TABLE credit_card(
    id VARCHAR(100) PRIMARY KEY, #CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci PRIMARY KEY,
    iban VARCHAR(100) NULL,
    pan VARCHAR(100) NULL,
    pin VARCHAR(100) NULL,
    cvv VARCHAR(100) NULL,
    expiring_date VARCHAR(100) NULL,
    FOREIGN KEY(id) REFERENCES transaction(credit_card_id));
## importar los datos del archivo: ejecutar todos los codigos en "datos_introducir_credit.sql"

### Exercici 2
# El departament de Recursos Humans ha identificat un error en el número de compte
# de l'usuari amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és:
# R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.

## mostrar el original
SELECT id, iban FROM credit_card
WHERE id = "CcU-2938";
## modificar
UPDATE credit_card
SET iban = "R323456312213576817699999"
WHERE id = "CcU-2938";
## mostrar el nuevo
SELECT id, iban FROM credit_card
WHERE id = "CcU-2938";


### Ejercicio 3 En la tabla "transaction" ingresa un nuevo usuario

## (1) añadir un registro de "id" a la tabla "company", porque el nuevo registro en la tabla
## "transaction" tiene una "company_id" (foreign key) que no está en la tabla "company",
## y causaría un error de constraints por la foreign key conectada
INSERT INTO
    company(id)
	VALUES("b-9999");
## (2) añadir el registro a la tabla "transaction"
INSERT INTO
    transaction(id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
	VALUES("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", "9999",
           "829.999", "-117.999", "111.11", "0");
## (3) igual el "credit_card_id" al "id" en la tabla "credit_card"
INSERT INTO
    credit_card(id)
	VALUES("CcU-9999");
## (4) mostrar
SELECT * FROM transaction
WHERE id = "108B1D1D-5B23-A76C-55EF-C568E49A99DD";


### Exercici 4
# Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card.
# Recorda mostrar el canvi realitzat.

## mostrar la original
SELECT * FROM credit_card;
## modificar
ALTER TABLE credit_card
DROP pan;
## mostrar el nuevo
SELECT * FROM credit_card;



########## Nivell 2
### Exercici 1
# Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.

## mostrar el original
SELECT * FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";
## eliminar
## antes de todo, quitar el foreign key para poder modificar; después recrear la foreign key
LOCK TABLES
    transaction WRITE,
    credit_card WRITE;
ALTER TABLE credit_card
    DROP FOREIGN KEY credit_card_ibfk_1;
DELETE FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";
ALTER TABLE credit_card
    ADD FOREIGN KEY(id) REFERENCES transaction(credit_card_id); 
UNLOCK TABLES;
## mostrar el nuevo
SELECT * FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

### Exercici 2
# La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi
# i estratègies efectives. S'ha sol·licitat crear una vista que proporcioni detalls clau sobre
# les companyies i les seves transaccions. Serà necessària que creïs una vista anomenada
# VistaMarketing que contingui la següent informació: Nom de la companyia. Telèfon de contacte.
# País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada,
# ordenant les dades de major a menor mitjana de compra.
CREATE VIEW `VistaMarketing` AS
SELECT s.company_name, s.phone, s.country, AVG(t.amount) AS mean_purchase
FROM transaction t
INNER JOIN
    (SELECT id, company_name, phone, country FROM company) s
ON t.company_id = s.id
WHERE t.declined = 0
GROUP BY t.company_id
ORDER BY mean_purchase DESC;
## mostrar la vista del esquema
SELECT * FROM transactions.vistamarketing;


### Exercici 3
# Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
SELECT * FROM transactions.vistamarketing
WHERE country = "Germany";



########## Nivell 3
### Exercici 1
# La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip
# va realitzar modificacions en la base de dades, però no recorda com les va realitzar.
# Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:

## (1) crear la tabla "user"
## crear la estructura de la tabla con los codigos en el archivo "estructura_datos_user.sql"
## importar los datos a la tabla con los codigos en el archivo "datos_introducir_user.sql"
## cambiar el nombre de la tabla: de “user” a “data_user”;
## cambiar el nombre de la columna “email” a “personal email”.
ALTER TABLE user RENAME data_user,
RENAME COLUMN email TO personal_email;

## (2) modificar la tabla "credit_card"
## modificar tipo de datos para las columnas, y añadir una columna de la fecha actual
## antes de todo, quitar el foreign key para poder modificar la tabla
LOCK TABLES
    transaction WRITE,
    credit_card WRITE;
ALTER TABLE credit_card
    DROP FOREIGN KEY credit_card_ibfk_1,
    MODIFY id VARCHAR(20),
    MODIFY iban VARCHAR(50),
    MODIFY pin VARCHAR(4),
    MODIFY cvv INT,
    MODIFY expiring_date VARCHAR(20),
    ADD COLUMN fecha_actual DATE DEFAULT (CURRENT_DATE);
ALTER TABLE credit_card
    ADD FOREIGN KEY(id) REFERENCES transaction(credit_card_id); 
UNLOCK TABLES;

## (3) crear un diagrama del modelo entre las tablas
## realizar en el panel de MySQL Workbench "Database" -- "Reverse engineer"


### Exercici 2
/* L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:
ID de la transacció
Nom de l'usuari/ària
Cognom de l'usuari/ària
IBAN de la targeta de crèdit usada.
Nom de la companyia de la transacció realitzada.
Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.
Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.
*/
CREATE VIEW `InformeTecnico` AS
SELECT t.id AS id_transaction,
       u.name AS user_name,
       u.surname AS user_surname,
       ca.iban AS credit_card_iban,
       c.company_name
FROM transaction as t
INNER JOIN data_user AS u ON t.user_id = u.id
INNER JOIN credit_card AS ca ON t.credit_card_id = ca.id
INNER JOIN company AS c ON t.company_id = c.id
ORDER BY id_transaction DESC;
## mostrar la vista
SELECT * FROM transactions.informetecnico;