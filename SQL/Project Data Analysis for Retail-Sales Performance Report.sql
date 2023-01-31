/* Dataset yang digunakan berasal dari DQLab yang berisikan transaksi dari tahun 2009 sampai dengan tahun 2012. */

/* Data pada order_status terbagi menjadi order finished, order returned, order cancelled*/

/* Pada project ini akan melihat overall performance dan efektivitas promosi yang dilakukan oleh DQLab pada tahun 2009 - 2012. */


--1. DQLab Store Overall Performance

    --Overall Performance by Year

SELECT
	year (order_date) as years,
	SUM(sales) as sales,
	COUNT(order_status) as number_of_order
FROM
	dqlab_sales_store
WHERE
	order_status = 'Order Finished'
GROUP BY
	years
order by
    years,
    sales asc;

/* Diperoleh hasil yang fluktuatif dari hasil penjualan sales dan jumlah order yang pada setiap tahunnya.
Penjualan sales tertinggi terdapat pada tahun 2009 dan mengalami penurunan yang signifikan pada tahun 2010. Kemudian kembali meningkat pada tahun 2011 dan 2012. */


    --Overall Performance by Product Sub Category

select
    year(order_date) years,
    product_sub_category,
    sum(sales) sales
from
    dqlab_sales_store
where
    order_status = 'order finished'
    and year(order_date) in ('2011','2012')
group by
    years,
    product_sub_category
order by
    years,
    sales desc;

/*Dari data yang dihasilkan, pada tahun 2011 penjualan sales terbesar terjadi pada penjualan Chair & Chairmats, sedangkan tahun 2012 pada penjualan office machines.*/


--2. DQLab Store Promotion Effectiveness and Efficiency

    --Promotion Effectiveness and Efficiency by Years

select 
    year(order_date) as years,
    sum(sales) sales,
    sum(discount_value) promotion_value,
    round(sum(discount_value) / sum(sales) *100,2) burn_rate_percentage
from
    dqlab_sales_store
where
    order_status = 'order finished'
group by
    years
order by 
	years asc;

/* DQLab berharap burn_rate_percentage maksimum diangka 4.5% namun, diperoleh hasil burn_rate_percentage pada tahun 2009 sebesar 4.65% dan terus mengalami kenaikan sampai tahun 2011 yaitu sebesar 5.22%. 
Maka, DQLab diharuskan melakukan efesiensi pengeluaran keuangan pada perusahaannya untuk mencapai target burn_rate_percentage maksimum diangka 4.5%. */


    --Promotion Effectiveness and Efficiency by Product Sub Category

SELECT
years,
product_sub_category,
product_category,
sales,
promotion_value,
round((promotion_value/sales)*100,2) AS burn_rate_percentage
FROM (
SELECT
ROUND(AVG(EXTRACT(YEAR FROM order_date)),0) AS years,
product_category,
product_sub_category,
SUM(discount_value) AS promotion_value,
SUM(sales) AS sales
FROM dqlab_sales_store
WHERE order_status = 'Order Finished' AND EXTRACT(YEAR FROM order_date) = '2012'	
GROUP BY 2,3) a
ORDER BY 4 DESC

/* Diperoleh hasil burn_rate_percentage terbesar terdapat pada scissor rulers and trimmers sebesar 6.39% dan terkecil pada rubber bands yaitu 3.06%. Sedangkan hasil penjualan
sales terbesar terjadi pada office machines. Diharapkan DQLab dapat melakukan strategi yang lebih baik untuk promosi ditahun berikutnya agar meningkatkan hasil penjualan perusahaan. */


--3. Customer Analytics

    --Customers Transactions per Year

select
    year(order_date) years,
    count(distinct customer) number_of_customer
from
    dqlab_sales_store
where
    order_status = 'Order Finished'
group by
    years;

/* Berdasarkan hasil yang diperoleh dari tahun 2009 - 2012 DQLab memiliki jumlah customer
yang fluktuatif untuk setiap tahunnya. diharapkan DQLab dapat melakukan strategi
marketing dan promosi yang lebih efisien dan menarik suapaya jumlah customer semakin bertambah setiap tahunnya. */


/*
kesimpulan
1. DQLab diharapkan melakukan efesiensi pengeluaran perusahaan untuk menekan angka burn_rate_percentage yang terjadi setiap tahunnya.
2. DQLab diharapkan melakukan strategi yang lebih efisien dan menarik untuk promosi dan marketing supaya jumlah customer dan penjualan sales semakin bertambah setiap tahunnya.
*/

