#Project kali ini ialah menganalisis performa dari cabang-cabang yang ada di DQLab Finance.


#1. Data yang Digunakan

df_loan <- read.csv('https://storage.googleapis.com/dqlab-dataset/loan_disbursement.csv', stringsAsFactors = F)
dplyr::glimpse(df_loan)

#2. Summary data bulan lalu (Mei 2020)

    #Memfilter data bulan Mei 2020, dan jumlahkan data per cabang
library(dplyr)

df_loan_mei <- df_loan %>% 
  filter(tanggal_cair >=  '2020-05-01', tanggal_cair <= '2020-05-31') %>% 
  group_by(cabang) %>% 
  summarise(total_amount = sum(amount)) 

df_loan_mei


    #Tampilkan data 5 cabang dengan total amount paling besar

library(dplyr)
library(scales)

df_loan_mei %>% 
    arrange(desc(total_amount)) %>% 
    mutate(total_amount = comma(total_amount)) %>% 
    head(5)


    #Tampilkan data 5 cabang dengan total amount paling kecil

library(dplyr)
library(scales)

df_loan_mei %>% 
    arrange(total_amount) %>% 
    mutate(total_amount = comma(total_amount)) %>% 
    head(5)

# Terjadi perbedaan yang sangat signifikan antara top 5 dengan bottom 5. Hal ini mungkin karena umur cabang yang berbeda beda karena ada pertumbuhan cabang baru setiap bulannya.


#3. Melihat hubungan umur cabang dengan total amount

    #Menghitung umur cabang (dalam bulan)

library(dplyr)
df_cabang_umur <- df_loan %>% 
    group_by(cabang) %>%
    summarise(pertama_cair = min(tanggal_cair)) %>% 
    mutate(umur = as.numeric(as.Date('2020-05-15') - as.Date(pertama_cair)) %/% 30)

df_cabang_umur


    #Gabungkan data umur dan performa mei

library(dplyr) 
df_loan_mei_umur <- df_cabang_umur %>% 
    inner_join(df_loan_mei, by = 'cabang') 

df_loan_mei_umur


    #Plot relasi umur dan performa mei

library(ggplot2)

ggplot(df_loan_mei_umur, aes(x = umur, y = total_amount)) +
  geom_point() +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Semakin berumur, perfoma cabang akan semakin baik",
       x = "Umur (bulan)",
       y = "Total Amount")

# Terlihat bahwa ada pola semakin tua cabang, maka performa nya semakin baik. Hal ini karena cabang tersebut masih berkembang sehingga belum sampai pada performa maksimal. Namun pada setiap umur itu juga ada cabang yang performanya dibawah yang lain.


#4. Cabang dengan performa rendah pada kelompok umur

    #Mencari cabang yang perfoma rendah untuk setiap umur

library(dplyr) 
library(scales) 
df_loan_mei_flag <- df_loan_mei_umur %>% 
    group_by(umur) %>% 
    mutate(Q1 = quantile(total_amount, 0.25),
           Q3 = quantile(total_amount, 0.75), 
           IQR = (Q3 - Q1)) %>% 
    mutate(flag = ifelse(total_amount < (Q1 - IQR), 'rendah', 'baik')) 

df_loan_mei_flag %>% 
  filter(flag == 'rendah') %>% 
  mutate_if(is.numeric, funs(comma))


    #Buat Scatterplot lagi dan beri warna merah pada cabang yang rendah tadi

library(ggplot2)

ggplot(df_loan_mei_flag, aes(x = umur, y = total_amount)) +
  geom_point(aes(color = flag)) +
  scale_color_manual(breaks = c("baik", "rendah"),
                     values = c("blue", "red")) +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Ada cabang berpeforma rendah padahal tidak termasuk bottom 5 nasional",
       color = "",
       x = "Umur (bulan)",
       y = "Total Amount")


#5. Analisis Cabang dengan Performa Rendah 

    #Lihat perbadingan performa cabang di umur yang sama

library(dplyr)
library(scales)

df_loan_mei_flag %>% 
  filter(umur == 3) %>% 
  inner_join(df_loan, by = 'cabang') %>% 
  filter(tanggal_cair >= '2020-05-01', tanggal_cair <= '2020-05-31') %>% 
  group_by(cabang, flag)  %>% 
  summarise(jumlah_hari = n_distinct(tanggal_cair),
            agen_aktif = n_distinct(agen),
            total_loan_cair = n_distinct(loan_id),
            avg_amount = mean(amount), 
            total_amount = sum(amount)) %>% 
  arrange(total_amount) %>% 
  mutate_if(is.numeric, funs(comma))


    #Lihat perbadingan performa agen pada cabang yang rendah

library(dplyr)
library(scales)

df_loan_mei_flag %>% 
  filter(umur == 3, flag == 'rendah') %>% 
  inner_join(df_loan, by = 'cabang') %>% 
  filter(tanggal_cair >= '2020-05-01', tanggal_cair <= '2020-05-31') %>% 
  group_by(cabang, agen) %>% 
  summarise(jumlah_hari = n_distinct(tanggal_cair),
            total_loan_cair = n_distinct(loan_id),
            avg_amount = mean(amount), 
            total_amount = sum(amount)) %>% 
  arrange(total_amount) %>% 
  mutate_if(is.numeric, funs(comma))


    #Lihat perbadingan performa agen pada cabang yang paling baik umur 3 bulan

library(dplyr)
library(scales)

df_loan %>% 
  filter(cabang == 'AH') %>% 
  filter(tanggal_cair >= '2020-05-01', tanggal_cair <= '2020-05-31') %>% 
  group_by(cabang, agen) %>% 
  summarise(jumlah_hari = n_distinct(tanggal_cair),
            total_loan_cair = n_distinct(loan_id),
            avg_amount = mean(amount), 
            total_amount = sum(amount)) %>% 
  arrange(total_amount) %>% 
  mutate_if(is.numeric, funs(comma))

#Kesimpulan

#Berdasarkan analisis tersebut, dapat disimpulkan bahwa rendahnya performa dari cabang AE adalah karena salah satu agen yang melakukan pencairan hanya 4 hari dalam 1 bulan, padahal agen lain bisa aktif 21 hari. Hal ini membuat total amount dari agen tersebut hanya 20% dibandingkan agen yang lainnya.
#Sedangkan pada cabang AH, performanya sangat baik karena ketiga agen melakukan pencairan hampir / selalu setiap hari kerja. 2 orang full 21 hari 1 orang 19 hari. Sehingga performa nya terjaga dengan baik.
