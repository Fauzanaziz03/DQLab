/* Dataset yang digunakan adalah data dari DQLab Store yang merupakan e-commerce tempat pengguna dapat berada
baik pembeli maupun penjual. Jadi, pengguna dapat membeli barang dari pengguna lain yang menjual. */

/*
Ada 4 tabel yang digunakan dalam dataset ini
1. tabel users, terdiri dari user_id, nama_user, kodepos dan email.
2. tabel produks, terdiri dari product_id, desc_product, category dan base_price.
3. tabel orders, terdiri dari order_id, seller_id, buyer_id, kodepos, subtotal, discount, total,
    created_at, paid_at dan delivery_at.
4. tabel order_details, terdiri dari order_detail, order_id, product_id, price dan quantity.
*/

--1. Melengkapi SQL

    --10 Transaksi Terbesar User 12476

SELECT seller_id,buyer_id, total as nilai_transaksi, created_at as tanggal_transaksi
from orders
where buyer_id = 12476
order by 3 desc
limit 10


    --Transaksi Perbulan

select EXTRACT(YEAR_MONTH FROM created_at) as tahun_bulan, count(1) as jumlah_transaksi, sum(total) as total_nilai_transaksi
from orders
where created_at>='2020-01-01'
group by 1
order by 1


    --Pengguna dengan Rata-rata Transaksi Terbesar di Januari 2020

select buyer_id, count(1) as jumlah_transaksi, avg(total) as avg_nilai_transaksi
from orders
where created_at>='2020-01-01' and created_at<'2020-02-01'
group by 1
having count(1)>= 2 
order by 3 desc
limit 10;


    --Transaksi Besar di Desember 2019

SELECT
 nama_user AS nama_pembeli,
 total AS nilai_transaksi,
 created_at AS tanggal_transaksi
FROM
 orders
INNER JOIN
 users
 ON buyer_id = user_id
WHERE
 created_at >= '2019-12-01' AND created_at < '2020-01-01' AND total >= 20000000
ORDER BY
 1;


    --Kategori Produk Terlaris di 2020

SELECT
 category,
 sum(quantity) AS total_quantity,
 sum(price) AS total_price
FROM
 orders
INNER JOIN
 order_details
 USING(order_id)
INNER JOIN
 products
 USING(product_id)
WHERE
 created_at >= '2020-01-01' AND delivery_at IS NOT NULL
GROUP BY
 1
ORDER BY
 2 DESC
LIMIT
 5;


--2. Membuat SQL

    --Mencari Pembeli High Value

SELECT
 nama_user AS nama_pembeli,
 count(1) AS jumlah_transaksi,
 sum(total) AS total_nilai_transaksi,
 min(total) AS min_nilai_transaksi
FROM
 orders
INNER JOIN
 users
 ON buyer_id = user_id
GROUP BY
 user_id,
 nama_user
HAVING
 count(1) > 5 AND min(total) > 2000000
ORDER BY
 3 DESC;


    --Mencari Dropshipper

SELECT
 nama_user AS nama_pembeli,
 count(1) AS jumlah_transaksi,
 count(DISTINCT orders.kodepos) AS distinct_kodepos,
 sum(total) AS total_nilai_transaksi,
 avg(total) AS avg_nilai_transaksi
FROM
 orders 
INNER JOIN
 users
 ON buyer_id = user_id
GROUP BY
 user_id,
 nama_user
HAVING
 count(1) >= 10 AND count(1) = count(DISTINCT orders.kodepos)
ORDER BY
 2 DESC;


    --Mencari Reseller Offline

SELECT
 nama_user AS nama_pembeli,
 count(1) AS jumlah_transaksi,
 sum(total) AS total_nilai_transaksi,
 avg(total) AS avg_nilai_transaksi,
 avg(total_quantity) AS avg_quantity_per_transaksi
FROM
 orders
INNER JOIN
 users
 ON buyer_id = user_id
INNER JOIN
 (
  SELECT order_id, sum(quantity) AS total_quantity
  FROM order_details
  GROUP BY 1
 ) AS summary_order
 USING(order_id)
WHERE
 orders.kodepos = users.kodepos
GROUP BY
 user_id,
 nama_user
HAVING
 count(1) >= 8 AND avg(total_quantity) > 10
ORDER BY
 3 DESC;


    --Pembeli Sekaligus Penjual

SELECT
 nama_user AS nama_pengguna,
 jumlah_transaksi_beli,
 jumlah_transaksi_jual
FROM
 users
INNER JOIN
 (
  SELECT buyer_id, count(1) AS jumlah_transaksi_beli
  FROM orders
  GROUP BY 1
 ) AS buyer
 ON buyer_id = user_id
INNER JOIN
 (
  SELECT seller_id, count(1) AS jumlah_transaksi_jual
  FROM orders
  GROUP BY 1
 ) AS seller
 ON seller_id = user_id
WHERE
 jumlah_transaksi_beli >= 7
ORDER BY
 1;


    --Lama Transaksi dibayar

select
 EXTRACT(YEAR_MONTH from created_at) as tahun_bulan,
 count(1) as jumlah_transaksi,
 avg(datediff(paid_at,created_at)) as avg_lama_dibayar,
 min(datediff(paid_at,created_at)) min_lama_dibayar,
 max(datediff(paid_at,created_at)) max_lama_dibayar
from orders 
where paid_at IS NOT NULL 
group by 1 
order by 1