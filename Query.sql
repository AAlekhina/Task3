# 1
SELECT
    category.name AS category_name,
    count(film_category.film_id) AS Count_of_film
FROM film_category
INNER JOIN category
    ON category.category_id = film_category.category_id
GROUP BY category.name
ORDER BY count_of_film DESC;

#2
SELECT
    a.actor_id,
    a.first_name || ' '|| a.last_name AS name_of_actor,
    COUNT(r.rental_id) AS rental_counter
FROM actor a
INNER JOIN
    film_actor film_actor ON a.actor_id = film_actor.actor_id
INNER JOIN
    film film ON film_actor.film_id = film.film_id
INNER JOIN
    inventory i ON film.film_id = i.film_id
INNER JOIN
    rental r ON i.inventory_id = r.inventory_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY
    rental_counter DESC
LIMIT 10;

#3
SELECT
    category.name, sum(payment.amount) AS spent
FROM category
INNER JOIN film_category ON
    category.category_id = film_category.category_id
INNER JOIN inventory ON
    film_category.film_id = inventory.film_id
INNER JOIN rental ON
    inventory.inventory_id = rental.inventory_id
INNER JOIN payment ON
    rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY spent DESC
LIMIT 1;

#4
SELECT film.title
FROM film
WHERE NOT EXISTS (
    SELECT 1
    FROM inventory
    WHERE inventory.film_id = film.film_id
);

#5
WITH  actor_film_count AS (
    SELECT
        actor.first_name || ' ' || actor.last_name AS actor_name,
        count(film_category.film_id) AS film_count
    FROM actor
    INNER JOIN film_actor
        ON actor.actor_id = film_actor.actor_id
    INNER JOIN film_category
        ON film_category.film_id = film_actor.film_id
    INNER JOIN category
        ON film_category.category_id = category.category_id
    WHERE category.name = 'Children'
    GROUP BY actor.first_name, actor.last_name
    ),
ranked_actors AS (
    SELECT
        actor_name,
        film_count,
        RANK() OVER (ORDER BY film_count DESC) AS rank
    FROM actor_film_count
)

SELECT
    actor_name,
    film_count
FROM ranked_actors
WHERE rank <= 3
ORDER BY film_count DESC;

#6
SELECT city.city,
       SUM(CASE WHEN customer.active = 1 THEN 1 ELSE 0 END) AS active_customers,
       SUM(CASE WHEN customer.active = 0 THEN 1 ELSE 0 END) AS inactive_customers
FROM city
    INNER JOIN address  ON city.city_id = address.city_id
    INNER JOIN customer ON address.address_id = customer.address_id
GROUP BY city.city
ORDER BY inactive_customers DESC;

# 7
WITH categorized_rentals AS (SELECT category.name AS category_name,
                                    city.city AS city,
                                    SUM(EXTRACT(HOUR FROM (rental.return_date - rental.rental_date))) AS rental_hours,
                                    ROW_NUMBER() OVER (
                                        PARTITION BY CASE
                                                         WHEN city.city ILIKE 'A%' THEN 'starts_with_A'
                                                         WHEN city.city LIKE '%-%' THEN 'contains_dash'
                                            END
                                        ORDER BY SUM(EXTRACT(HOUR FROM (rental.return_date - rental.rental_date))) DESC
                                        )AS rn
                             FROM category
                                      INNER JOIN film_category ON category.category_id = film_category.category_id
                                      INNER JOIN inventory ON film_category.film_id = inventory.film_id
                                      INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
                                      INNER JOIN customer ON rental.customer_id = customer.customer_id
                                      INNER JOIN address ON address.address_id = customer.address_id
                                      INNER JOIN city ON city.city_id = address.city_id
                             WHERE city.city ILIKE 'A%'
                                OR city.city LIKE '%-%'
                             GROUP BY category.name, city.city)
SELECT category_name, city, rental_hours, rn
FROM categorized_rentals
WHERE rn<=1
ORDER BY  rental_hours DESC;

