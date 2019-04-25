use sakila;

select * from actor;

-- 1a. Display the first and last names of all actors from the table actor. --

select first_name, last_name
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. --

select upper(concat(first_name,' ' ,last_name)) as 'actor_name'
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

select first_name, last_name, actor_id from actor
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:

select first_name, last_name, actor_id from actor
where last_name like '%GEN%';

-- 2c Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

select first_name, last_name, actor_id from actor
where last_name like '%LI%'
order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

select country, country_id from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. 
--     You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
--     as the difference between it and VARCHAR are significant).

alter table actor add column Description varchar(30) after first_name;
select * from actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

alter table actor modify column Description blob;
alter table actor drop column Description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

select last_name, count(last_name) as 'last_name_count' from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

select last_name, count(last_name) as 'last_name_count' from actor
group by last_name
having last_name_count >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

update actor
set first_name = "HARPO"
where first_name = "GROUCHO"
and last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, 
--      change it to GROUCHO.

update actor
set first_name = 
 case
	 when first_name = 'HARPO'
		 then 'GROUCHO'
	 end
where actor_id = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

select a.first_name, a.last_name, b.address from staff a
inner join address b
on (a.address_id = b.address_id);
  
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

select a.first_name, a.last_name, sum(b.amount) from staff as a
inner join payment as b
on b.staff_id = a.staff_id
where month(b.payment_date) = 08 and year(b.payment_date) = 2005
group by a.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

select b.title, count(a.actor_id) as 'Actors' from film_actor as a
inner join film as b
on b.film_id = a.film_id
group by b.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select * from film;
select * from inventory;
select title, count(inventory_id) as 'total copies' from film
inner join inventory
using (film_id)
where title = 'Hunchback Impossible'
group by title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

select cs.first_name, cs.last_name, sum(py.amount) as 'Total Paid Amount' from payment as py  join customer as cs
on py.customer_id = cs.customer_id
group by cs.customer_id
order by cs.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
--      As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
--      Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select title from  film
where title like 'K%'
or  title like 'Q%'
and language_id IN
  (
   select language_id from language
   where name = 'English'
  );

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select first_name, last_name from actor 
 where actor_id in 
  (select actor_id from film_actor
    where film_id = 
    (select film_id from film
       where title = 'Alone Trip')
   );

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
--     Use joins to retrieve this information.

select first_name, last_name, email, country from customer cs 
join  address ad on (cs.address_id = ad.address_id)
join city ct on (ad.city_id = ct.city_id)
join country cn on (ct.country_id = cn.country_id)
where cn.country = 'canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
--     Identify all movies categorized as family films.

select title, cs.name from film fm
join film_category fc on (fm.film_id = fc.film_id)
join category cs on (cs.category_id = fc.category_id)
where name = 'family';

-- 7e. Display the most frequently rented movies in descending order.

select title, count(title) as 'Rentals' from film fm
join inventory inv on (fm.film_id = inv.film_id)
join rental rn on (inv.inventory_id = rn.inventory_id)
group by title
order by rentals desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

select st.store_id, sum(amount) as Gross from payment py
join rental rn on (py.rental_id = rn.rental_id)
join inventory inv on (inv.inventory_id = rn.inventory_id)
join store st on (st.store_id = inv.store_id)
group by st.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

select s.store_id, cty.city, country.country 
from store s
join address a 
on (s.address_id = a.address_id)
join city cty
on (cty.city_id = a.city_id)
join country
ON (country.country_id = cty.country_id);


--  7h. List the top five genres in gross revenue in descending order. 
--      (**Hint**: you may need to use the following tables: category,
--       film_category, inventory, payment, and rental.)

select c.name as 'Genre', sum(p.amount) as 'Gross' 
from category c
join film_category fc 
on (c.category_id=fc.category_id)
join inventory i 
on (fc.film_id=i.film_id)
join rental r 
on (i.inventory_id=r.inventory_id)
join payment p 
on (r.rental_id=p.rental_id)
group by c.name order by Gross  limit 5;

--  8a. In your new role as an executive, you would like to have an easy 
--      way of viewing the Top five genres by gross revenue. Use the solution
--      from the problem above to create a view. If you haven't solved 7h, you
--      can substitute another query to create a view.

create view genre_revenue as
select c.name as 'Genre', sum(p.amount) as 'Gross' 
from category c
join film_category fc 
on (c.category_id=fc.category_id)
join inventory i 
on (fc.film_id=i.film_id)
join rental r 
on (i.inventory_id=r.inventory_id)
join payment p 
on (r.rental_id=p.rental_id)
group by c.name order by Gross  limit 5;
  	
--  8b. How would you display the view that you created in 8a?

select * from genre_revenue;

--  8c. You find that you no longer need the view `top_five_genres`. 
--      Write a query to delete it.

drop view genre_revenue;
