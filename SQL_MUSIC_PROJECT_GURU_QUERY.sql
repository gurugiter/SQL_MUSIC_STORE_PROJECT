SELECT * FROM employee;

-- Adhoc request questions

--Question 1 - Who is the senior most employee based on job title?

SELECT * FROM employee 
ORDER BY levels DESC LIMIT 1;

-- QUESTION 2 - Which country has most invoices?

SELECT billing_country as countries, count(invoice_id) as Num_of_invoices 
FROM invoice 
group by countries Order By Num_of_invoices Desc;

-- QUESTION 3 - Top three values of invoices?

SELECT total FROM invoice 
order by total desc limit 3;


-- QUESTION 4 - Which city has the best customers? We would like to throw a promotional Music 
--Festival in the city we made the most money. Write a query that returns one city that 
--has the highest sum of invoice totals. Return both the city name & sum of all invoice 
--total

SELECT billing_city as City, SUM(total) as Total_sales
FROM invoice
GROUP BY City ORDER BY Total_sales DESC
LIMIT 1;

-- Multiple Joins, Subqueries

-- QUESTION 5 - Who is the best customer? The customer who has spent the most money will be 
-- declared the best customer. Write a query that returns the person who has spent the 
-- most money

select c.Customer_id, CONCAT(c.first_name,c.last_name), Sum(i.total) as Total
from customer c 
JOIN invoice i on c.Customer_id = i.Customer_id
GROUP BY c.Customer_id
ORDER BY Total DESC;


-- Question 6 -Write query to return the email, first name, last name, & Genre of all Rock Music 
-- listeners. Return your list ordered alphabetically by email starting with A

SELECT DISTINCT c.email, c.first_name AS FirstName, c.last_name AS LastName, g.name AS genre
FROM Customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t on il.track_id = t.track_id
JOIN genre g on t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.first_name;

-- or

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

--or

SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;

-- Question 7 - Let's invite the artists who have written the most rock music in our dataset. Write a 
-- query that returns the Artist name and total track count of the top 10 rock bands

SELECT artist.name AS artist, COUNT(track.track_id) AS number_of_songs
FROM track
JOIN album ON track.album_id = album.album_id
JOIN artist ON album.artist_id = artist.artist_id
WHERE track.genre_id = 1
GROUP BY artist.artist_id
ORDER BY number_of_songs desc limit 10;

-- or another way to query the same results 
SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


/* Question 8 - Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

Note - will only be using track table since all info can be queried from track table 
average song length for given table dataset - 393599.212103910933 milliseconds*/

SELECT name AS Song_name, milliseconds AS song_length
FROM track 
WHERE milliseconds >(
	SELECT AVG(milliseconds) 
	FROM track
)
ORDER BY song_length DESC;


-- Use of Advance SQL Functions such as Window Functions, CTE etc

-- Question 9 - Find how much amount is spent by each customer on Best Selling artist? Write a query to return
-- customer name, artist name and total spent
--BEST SELLING ARTIST as CTE
WITH BESTSELLINGARTIST AS(
	select a.artist_id, a.name as artistname, SUM(il.unit_price*il.quantity) AS Total
	from invoice_line il
	JOIN Track t on t.track_id =il.track_id
	JOIN album al on al.album_id = t.album_id
	JOIN artist a on a.artist_id = al.artist_id
	GROUP BY a.artist_id
	ORDER BY total DESC
	Limit 1
)
SELECT c.customer_id, c.first_name, c.last_name, BSA.artistname, SUM(il.unit_price*il.quantity) as Total_spent_by_customer
FROM customer c
JOIN invoice i on c.customer_id = i.customer_id 
JOIN invoice_line il on i.invoice_id = il.invoice_id 
JOIN track t on il.track_id = t.track_id 
JOIN album al on t.album_id = al.album_id
JOIN BESTSELLINGARTIST BSA on al.artist_id = BSA.artist_id
GROUP BY 1,4
order by 5 desc


/* Question 10 - We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query that returns each 
country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres */

WITH P_G_E_Country AS
(
SELECT i.billing_country Country, count(il.quantity) num_of_purchases, g.name genre,
ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY (count(il.quantity)) DESC) Rownum
FROM Invoice i 
JOIN invoice_line il on i.invoice_id = il.invoice_id 
JOIN track t on il.track_id = t.track_id 
JOIN genre g on g.genre_id = t.genre_id 
GROUP BY 1, 3
ORDER BY 1
)
SELECT Country, num_of_purchases, genre
FROM P_G_E_Country
WHERE Rownum = 1;


/*Question 11 - Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount*/

WITH HIGHEST_SPENDOR AS
(
SELECT i.customer_id custid, SUM(i.total) Total_spending, i.billing_country country,
ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) rownum
FROM invoice i
GROUP BY 1, 3
ORDER BY 3, 2 DESC
)
SELECT HS.custid, c.first_name, c.last_name, HS.Total_spending, HS.country, HS.rownum
FROM customer c
JOIN HIGHEST_SPENDOR HS ON HS.custid = c.customer_id
where rownum <= 1;

/* Please note that the Data and all the files required for this project can be accessed by visitng the GIThub link: 
" https://github.com/gurugiter/SQL_MUSIC_STORE_PROJECT "*/