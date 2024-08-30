# 1
SELECT category.name as Category_name, count(film_category.film_id) as Count_of_film
    FROM film_category
    JOIN category
    ON category.category_id = film_category.category_id
    GROUP BY category.name
    ORDER BY Count_of_film DESC;

#2
SELECT
    a.actor_id,
    a.first_name || ' '|| a.last_name AS name_of_actor,
    COUNT(r.rental_id) AS rental_counter
FROM actor a
JOIN
    film_actor film_actor ON a.actor_id = film_actor.actor_id
JOIN
    film film ON film_actor.film_id = film.film_id
JOIN
    inventory i on film.film_id = i.film_id
JOIN
    rental r ON i.inventory_id = r.inventory_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY
    rental_counter DESC
LIMIT 10;

#3
SELECT
    category.name, sum(payment.amount) AS spent
FROM category
JOIN film_category ON
    category.category_id = film_category.category_id
JOIN inventory ON
    film_category.film_id = inventory.film_id
JOIN rental ON
    inventory.inventory_id = rental.inventory_id
JOIN payment ON
    rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY spent DESC
LIMIT 1;

#4
SELECT film.title
FROM film
LEFT JOIN
    inventory ON film.film_id = inventory.film_id
WHERE inventory.film_id IS NULL;

#5
WITH  actor_film_count AS (
    SELECT
        actor.first_name || ' ' || actor.last_name AS actor_name,
        count(film_category.film_id) AS film_count
    FROM actor
    JOIN film_actor
        ON actor.actor_id = film_actor.actor_id
    JOIN film_category
        ON film_category.film_id = film_actor.film_id
    Join category
        ON film_category.category_id = category.category_id
    WHERE category.name = 'Children'
    GROUP BY actor.first_name, actor.last_name
    ),
top3_actor AS (
    SELECT actor_name, film_count
    FROM actor_film_count
    ORDER BY film_count DESC
    LIMIT 3)

SELECT actor_name, film_count
    FROM actor_film_count
        WHERE film_count>=(SELECT min(film_count)
                           FROM top3_actor)
ORDER BY film_count DESC;

#6
SELECT city.city,
       SUM(CASE WHEN customer.active = 1 THEN 1 ELSE 0 END) AS Active_customers,
       SUM(CASE WHEN customer.active = 0 THEN 1 ELSE 0 END) AS Inactive_customers
FROM city
    JOIN address  ON city.city_id = address.city_id
    JOIN customer ON address.address_id = customer.address_id
GROUP BY city.city
ORDER BY Inactive_customers DESC;

# 7
SELECT category.name, city.city,
       SUM(EXTRACT(HOUR FROM(rental.return_date-rental.rental_date))) AS rental_hours
FROM category
    JOIN film_category ON category.category_id = film_category.category_id
    JOIN inventory  ON film_category.film_id = inventory.film_id
    JOIN rental  ON  inventory.inventory_id = rental.inventory_id
    JOIN customer ON rental.customer_id = customer.customer_id
    JOIN address ON address.address_id = customer.address_id
    JOIN city  ON city.city_id = address.city_id
 WHERE
        city.city ILIKE 'A%' OR city.city LIKE '%-%'
GROUP BY category.name, city.city
ORDER BY rental_hours DESC
LIMIT 1;

