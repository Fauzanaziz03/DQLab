/* Database didapat dari DQLab. Database berasal dari perusahaan rintisan B2B yaitu xyz.com yang menjual berbagai produk tidak langsung kepada end user tetapi ke bisnis/perusahaan lainnya. */

/* Dari project ini akan dilihat performa yang dimiliki perushaan xyz.com pada quarter 1 dan quarter2 dan melihat bagaimana minat customer yang  melakukan transaksi di perushaan retail B2B ini. */


--1. Pengenalan Tabel

    --Memahami Tabel

SELECT * FROM orders_1 LIMIT 5;
SELECT * FROM orders_2 LIMIT 5;
SELECT * FROM customer LIMIT 5;


--2. Bagaimana Pertumbuhan Penjualan Saat Ini

    --Total Penjualan dan Revenue pada Quarter-1 dan Quarter-2

SELECT
 sum(quantity) AS total_penjualan,
 sum(quantity * priceeach) AS revenue
FROM
 orders_1
WHERE
 status = 'Shipped';
SELECT
 sum(quantity) AS total_penjualan,
 sum(quantity * priceeach) AS revenue
FROM
 orders_2
WHERE
 status = 'Shipped';

/*Berdasarkan hasil yang diperoleh, total penjualan dan revenue pada quarter 1 lebih besar daripada quarter 2.*/


    --Menghitung Persentasi Keseluruhan Penjualan

SELECT
    quarter,
    sum(quantity) total_penjualan,
    sum(quantity*priceeach) revenue
FROM
    (
        SELECT
            orderNumber,
            status,
            quantity,
            priceeach,
            '1' quarter
        FROM
            orders_1
        UNION
        SELECT
            orderNumber,
            status,
            quantity,
            priceeach,
            '2' quarter
        FROM
            orders_2
    ) tabel_a
WHERE
    status = "Shipped"
GROUP BY
    quarter;

/*Dari hasil yang diperoleh, persentasi keseluruhan penjualan dan revenue pada quarter 1 lebih tinggi daripada quarter 2*/


--3. Customer Analytics

    --Apakah jumlah customers xyz.com semakin bertambah?

SELECT
	quarter,
	count(distinct customerid) as total_customers
FROM
	(SELECT
		customerID,
		createDate,
		quarter(createDate) as quarter	
FROM
		customer 
	WHERE 
		 createdate between '2004-01-01' and '2004-06-30'
	) as tabel_b
GROUP BY quarter

/*Dari hasil yang diperoleh, jumlah customer pada quarter 1 lebih tinggi daripada quarter 2 yaitu 43 dan 35. ini menandakan adanya penuurunan jumlah customer*/


    --Seberapa banyak customers tersebut yang sudah melakukan transaksi?

SELECT
	quarter, count(distinct customerid) as total_customers
FROM
	(SELECT
		customerid, createdate, quarter(createdate) as quarter
FROM
		customer
WHERE
		createdate between '2004-01-01' and '2004-06-30') as tabel_b
WHERE
customerid IN( SELECT distinct customerid
FROM
			orders_1
UNION
SELECT
			distinct customerid
FROM
			orders_2)
GROUP BY quarter

/*Total customer yang telah bertransaksi pada quarter 1 sebanyak 25 customer sedangkan pada quarter 2 sebanyak 19 customer*/ 


    --Category produk apa saja yang paling banyak di-order oleh customers di Quarter-2?

SELECT * 
FROM (SELECT categoryID, COUNT(DISTINCT orderNumber) AS total_order, SUM(quantity) AS total_penjualan 
      FROM ( 
       SELECT 
       productCode, 
       orderNumber, 
       quantity,
       status, 
       LEFT(productCode,3) AS categoryID
FROM orders_2
WHERE status = "Shipped") tabel_c
GROUP BY categoryID ) a 
ORDER BY total_order DESC

/*CategoryID 518 merupakan category product yang paling banyak di-order pada quarter 2*/

    --Seberapa banyak customers yang tetap aktif bertransaksi setelah transaksi pertamanya?

SELECT
COUNT(DISTINCT customerid) as total_customers 
FROM orders_1 ;
SELECT
	'1' as quarter,
	(COUNT(DISTINCT customerid)/25)*100 as Q2
FROM
	orders_1
WHERE customerid IN(
  SELECT 
  	distinct customerid
  FROM
  	orders_2)

/*Untuk mengetahui seberapa banyak customer yang aktif bertransaksi di xyz.com, maka menggunakan metrik retention cohort.
Hasil yang diperoleh sebesar 24%.*/


/*
Kesimpulan
1. perusahaan retail B2B xyz.com mengalami penurunan secara signifikan  di quarter 2.
2. ketertarikan customer untuk melakukan transaksi masih kurang.
3. Produk kategori S18 dan S24 berkontribusi sekitar 50% dari total order dan 60% dari total penjualan, sehingga xyz.com sebaiknya fokus untuk pengembangan category S18 dan S24.
4. retention cohort yang dimiliki yaitu sebesar 24% yang artinya banyak customer yang tidak melakukan repeat order
4. nilai retention cohort yang rendah  yang dimiliki perusahaan xyz.com dapat dijadikan masukan agar perusahaan retail b2b ini melakukan promosi untuk menarik customer baru atau membuat customer di quarter 1 agar tetap loyal dan selalu bertransaksi di perusahaan xyz.com.
*/