########## Nivell 1
### Exercici 1
SELECT * FROM company;
SELECT * FROM transaction;

### Exercici 2 Utilitzant JOIN
# 1.2.1 Llistat dels països que estan fent compres.
SELECT DISTINCT country
FROM transaction AS t
INNER JOIN company AS c
ON t.company_id = c.id
WHERE declined = 0;

# 1.2.2 Des de quants països es realitzen les compres.
SELECT COUNT(distinct country) AS country_number
FROM transaction AS t
INNER JOIN company AS c
ON t.company_id = c.id
WHERE declined = 0;

# 1.2.3 Identifica la companyia amb la mitjana més gran de vendes.
SELECT c.company_name
FROM transaction AS t
INNER JOIN company AS c
ON t.company_id = c.id
WHERE declined = 0
GROUP BY company_name
ORDER BY AVG(t.amount) DESC
LIMIT 1;

### Exercici 3 Utilitzant només subconsultes (sense utilitzar JOIN):
# 1.3.1 Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT * FROM transaction AS t
WHERE EXISTS (SELECT * FROM company AS c
			  WHERE t.company_id = c.id
              AND c.country = "Germany"
              #AND t.declined = 0
              );

# 1.3.2 Llista les empreses que han realitzat transaccions per un amount
# superior a la mitjana de totes les transaccions.
SELECT DISTINCT company_name FROM company
WHERE company.id IN
    (SELECT DISTINCT company_id FROM transaction
    WHERE declined = 0
    AND amount >
        (SELECT AVG(amount)
        FROM transaction
        WHERE declined = 0));

# 1.3.3 Eliminaran del sistema les empreses que no tenen transaccions registrades,
# entrega el llistat d'aquestes empreses.
SELECT DISTINCT company_name FROM company
WHERE NOT EXISTS
    (SELECT * FROM transaction
    WHERE company.id = transaction.company_id);



########## Nivell 2
### Exercici 1
# Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa
# per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.
SELECT DATE(timestamp) AS date, SUM(amount) AS daily_sale
FROM transaction
WHERE declined = 0
GROUP BY date
ORDER BY daily_sale DESC
LIMIT 5;

### Ejercicio 2
# ¿Cuál es la media de ventas por país?
# Presenta los resultados ordenados de mayor a menor medio.
SELECT c.country, AVG(t.amount) AS average_sale
FROM transaction AS t
INNER JOIN company AS c
ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY c.country
ORDER BY average_sale DESC;

### Exercici 3
### En la teva empresa, es planteja un nou projecte per a llançar algunes
### campanyes publicitàries per a fer competència a la companyia "Non Institute".
### Per a això, et demanen la llista de totes les transaccions realitzades
### per empreses que estan situades en el mateix país que aquesta companyia.
# 2.3.1 Mostra el llistat aplicant JOIN i subconsultes.
SELECT t.*
FROM transaction AS t
INNER JOIN company AS c
ON t.company_id = c.id
WHERE t.declined = 0
AND company_name != "Non Institute"
AND c.country = (SELECT country
				 FROM company
				 WHERE company_name = "Non Institute");

# 2.3.2 Mostra el llistat aplicant solament subconsultes.
SELECT *
FROM transaction AS t 
WHERE t.declined = 0
AND EXISTS
    (SELECT *
     FROM company AS c
     WHERE t.company_id = c.id
     AND company_name != "Non Institute"
     AND (c.country = (SELECT country
                       FROM company
                       WHERE company_name = "Non Institute"))
     );



########## Nivell 3
### Exercici 1
### Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar
### transaccions amb un valor comprès entre 100 i 200 euros i en alguna d'aquestes dates:
### 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022.
### Ordena els resultats de major a menor quantitat.
SELECT c.company_name, c.phone, c.country, t.amount, DATE(t.timestamp) as date
FROM transaction AS t
INNER JOIN company AS c
ON t.company_id = c.id
WHERE t.declined = 0
AND t.amount BETWEEN 100 AND 200
AND DATE(t.timestamp) IN ("2021-04-29", "2021-07-20", "2022-03-13")
ORDER BY amount DESC;

### Exercici 2
### Necessitem optimitzar l'assignació dels recursos i dependrà de la
### capacitat operativa que es requereixi, per la qual cosa et demanen
### la informació sobre la quantitat de transaccions que realitzen les empreses,
### però el departament de recursos humans és exigent i vol un llistat de 
### les empreses on especifiquis si tenen més de 4 transaccions o menys.
SELECT c.company_name, COUNT(IFNULL(t.id, 0)) AS number_tansactions,
IF(COUNT(IFNULL(t.id, 0)) > 4, ">4", "<=4") as number_transactions_4
FROM transaction AS t
RIGHT JOIN company AS c
ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY t.company_id;
