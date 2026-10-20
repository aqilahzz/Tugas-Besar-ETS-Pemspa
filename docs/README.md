# WebGIS Leaflet — Klasifikasi Tutupan Lahan Purworejo

Project ini membuat peta web interaktif dari raster klasifikasi tutupan lahan yang dihasilkan oleh workflow R sebelumnya.

## Isi peta
- Klasifikasi tutupan lahan: vegetasi, bangunan, perairan, awan.
- Batas administrasi kecamatan dan kabupaten.
- Basemap OpenStreetMap.
- Legenda dan kontrol untuk menyalakan/mematikan layer.

## 1. Siapkan file data
Buat folder `data/`, lalu masukkan:
- `klasifikasi_purworejo.tif` — hasil raster klasifikasi dari proses sebelumnya.
- `Batas Adm Kabupaten_Purworejo.shp`
- `Batas Adm Kecamatan_Purworejo.shp`

Sertakan juga seluruh file pendamping shapefile yang memiliki nama dasar sama, seperti `.shx`, `.dbf`, `.prj`, dan file lain yang diperlukan. File data tidak disertakan dalam paket contoh ini karena belum ada pada lampiran yang diberikan.

## 2. Jalankan di RStudio
Buka project/folder ini sebagai working directory, lalu jalankan:

```r
install.packages(c("terra", "sf", "leaflet", "htmlwidgets", "htmltools"))
source("buat_leaflet.R")
```

Script akan membuat `docs/index.html` beserta folder dependency yang dibutuhkan.

## 3. Publikasikan melalui GitHub Pages
1. Buat repository GitHub baru.
2. Unggah `buat_leaflet.R`, folder `data/` berisi data yang boleh dibagikan, dan seluruh isi folder `docs/` setelah script dijalankan.
3. Pastikan repository diatur **Public** jika ingin semua orang dapat melihat source code.
4. Buka **Settings → Pages**.
5. Pada bagian build/deployment, pilih **Deploy from a branch**.
6. Pilih branch `main` dan folder `/docs`, lalu klik **Save**.
7. Tunggu proses publikasi selesai. GitHub akan menampilkan URL Pages untuk peta.

## Catatan penting
- GitHub Pages hanya menyajikan file web statis; ia tidak menjalankan script R. Jalankan `buat_leaflet.R` di RStudio terlebih dahulu.
- Script mengagregasi raster dengan faktor 5 (misalnya 10 m menjadi sekitar 50 m) supaya peta web lebih ringan. Untuk kebutuhan detail, ubah `faktor` dengan mempertimbangkan ukuran file dan performa browser.
- Pastikan CRS data diketahui dan benar. Script mengubah tampilan peta ke EPSG:4326 untuk Leaflet.
- Jika data tidak boleh dipublikasikan, jangan unggah raster/shapefile tersebut ke repository publik. Source code dapat dibuat publik terpisah dari data.
- Jangan unggah citra Sentinel-2 mentah atau file berukuran sangat besar tanpa memeriksa ukuran dan ketentuan lisensinya.
