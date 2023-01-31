#Customer segmentation merupakan hal yang penting karena :
#- Dapat membuat pesan pemasaran yang lebih mengena ke tiap pelanggan
#- Bisa lebih mengenal customer / pelanggan
#- Biaya pemasaran bisa menjadi lebih rendah


#1. Persiapan Data

  #Membaca Data dengan Fungsi read.csv

pelanggan <- read.csv("https://storage.googleapis.com/dqlab-dataset/customer_segments.txt", sep="\t")
pelanggan[c("Jenis.Kelamin","Umur","Profesi","Tipe.Residen")]


  #Vector untuk Menyimpan Nama Field

#Buat variable field_yang_digunakan dengan isi berupa vector "Jenis.Kelamin", "Umur" dan "Profesi"
field_yang_digunakan <- c("Jenis.Kelamin", "Umur", "Profesi")
#Tampilan data pelanggan dengan nama kolom sesuai isi vector field_yang_digunakan
pelanggan[field_yang_digunakan]


  #Konversi Data dengan data.matrix

pelanggan_matrix <- data.matrix(pelanggan[c("Jenis.Kelamin", "Profesi", "Tipe.Residen")])


  #Menggabungkan Hasil Konversi

pelanggan <- data.frame(pelanggan, pelanggan_matrix)
#Tampilkan kembali data hasil penggabungan
pelanggan


  #Menormalisasikan Nilai Belanja

pelanggan$NilaiBelanjaSetahun <- pelanggan$NilaiBelanjaSetahun / 1000000


  #Membuat Data Master

Profesi <- unique(pelanggan[c("Profesi","Profesi.1")])
Jenis.Kelamin <- unique(pelanggan[c("Jenis.Kelamin","Jenis.Kelamin.1")])
Tipe.Residen <- unique(pelanggan[c("Tipe.Residen","Tipe.Residen.1")])


#2. Clustering dan Algoritma K-Means

  #Fungsi kmeans

#Bagian Data Preparation
pelanggan <- read.csv("https://storage.googleapis.com/dqlab-dataset/customer_segments.txt", sep="\t")
pelanggan_matrix <- data.matrix(pelanggan[c("Jenis.Kelamin", "Profesi", "Tipe.Residen")])
pelanggan <- data.frame(pelanggan, pelanggan_matrix)
Profesi <- unique(pelanggan[c("Profesi","Profesi.1")])
Jenis.Kelamin <- unique(pelanggan[c("Jenis.Kelamin","Jenis.Kelamin.1")])
Tipe.Profesi <- unique(pelanggan[c("Tipe.Residen","Tipe.Residen.1")])
pelanggan$NilaiBelanjaSetahun <- pelanggan$NilaiBelanjaSetahun/1000000
field_yang_digunakan = c("Jenis.Kelamin.1", "Umur", "Profesi.1", "Tipe.Residen.1","NilaiBelanjaSetahun")
#Bagian K-Means
set.seed(1)
#fungsi kmeans untuk membentuk 5 cluster dengan 25 skenario random dan simpan ke dalam variable segmentasi
field_yang_digunakan = c("Jenis.Kelamin.1", "Umur", "Profesi.1", "Tipe.Residen.1","NilaiBelanjaSetahun")
segmentasi <- kmeans(x=pelanggan[field_yang_digunakan], centers=5, nstart=25)
#tampilkan hasil k-means
segmentasi


  #Analisa Hasil Clustering Vector

#Bagian K-Means

set.seed(1)

segmentasi <- kmeans(x=pelanggan[field_yang_digunakan], centers=5, nstart=25)

#Penggabungan hasil cluster

segmentasi$cluster

pelanggan$cluster <- segmentasi$cluster

str(pelanggan)


  #Analisa Hasil Cluster Size

length(which(pelanggan$cluster == 2))


  #Melihat Data pada Cluster ke-N

#Melihat data cluster ke 3-5
pelanggan[which(pelanggan$cluster == 3),]
pelanggan[which(pelanggan$cluster == 4),]
pelanggan[which(pelanggan$cluster == 5),]


  #Analisa Hasil Cluster Means

#Melihat cluster means dari objek 
segmentasi$centers


  #Analisa Hasil Sum of Square
#Membandingkan dengan 2 cluster kmeans, masing-masing 2 dan 5
set.seed(1)
kmeans(x=pelanggan[field_yang_digunakan], centers=2, nstart=25)
set.seed(1)
kmeans(x=pelanggan[field_yang_digunakan], centers=5, nstart=25)


  #Available Components

segmentasi$withinss
segmentasi$cluster
segmentasi$tot.withinss


#3. Menentukan Jumlah Cluster Terbaik

  #Simulasi Jumlah Cluster dan SS

#Bagian K-Means
set.seed(1)
sse <- sapply(1:10, function(param_k) {kmeans(pelanggan[field_yang_digunakan], param_k, nstart=25)$tot.withinss})
sse


  #Grafik Elbow Effect

jumlah_cluster_max <- 10
ssdata = data.frame(cluster=c(1:jumlah_cluster_max),sse)
ggplot(ssdata, aes(x=cluster,y=sse)) +
                geom_line(color="red") + geom_point() +
                ylab("Within Cluster Sum of Squares") + xlab("Jumlah Cluster") +
                geom_text(aes(label=format(round(sse, 2), nsmall = 2)),hjust=-0.2, vjust=-0.5) +
  scale_x_discrete(limits=c(1:jumlah_cluster_max))


#4. Pemaketan Model K-Means

  #Menamakan Segmen

Segmen.Pelanggan <- data.frame(cluster = c(1,2,3,4,5),
                               Nama.Segmen = c("Silver Youth Gals", 
                                               "Diamond Senior Member", 
                                               "Gold Young Professional", 
                                               "Diamond Professional", 
                                               "Silver Mid Professional"))


  #Menggabungkan Referensi

Identitas.Cluster <- list(Profesi=Profesi, Jenis.Kelamin=Jenis.Kelamin, Tipe.Residen=Tipe.Residen, Segmentasi=segmentasi, Segmen.Pelanggan=Segmen.Pelanggan, field_yang_digunakan=field_yang_digunakan)


  #Menyimpan Object dalam Bentuk File

saveRDS(Identitas.Cluster,"cluster.rds")


#5. Mengoperasionalkan Model K-Means

  #Data Baru

databaru <- data.frame(Customer_ID="CUST-100", Nama.Pelanggan="Rudi Wilamar",Umur=20,Jenis.Kelamin="Wanita",Profesi="Pelajar",Tipe.Residen="Cluster",NilaiBelanjaSetahun=3.5)
databaru


  #Memuat Objek Clustering dari File

Identitas.Cluster <- readRDS(file="cluster.rds")
Identitas.Cluster


  #Merge dengan Data Referensi
databaru <- merge(databaru, Identitas.Cluster$Profesi)
databaru <- merge(databaru, Identitas.Cluster$Jenis.Kelamin)
databaru <- merge(databaru, Identitas.Cluster$Tipe.Residen)
databaru


  #Menentukan Cluster

Identitas.Cluster$Segmen.Pelanggan[which.min(sapply(1:5, function(x) sum(( databaru[Identitas.Cluster$field_yang_digunakan] - Identitas.Cluster$Segmentasi$centers[x,])^2))),]
