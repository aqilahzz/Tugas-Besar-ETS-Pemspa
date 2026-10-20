
# =====================================================
# LEAFLET INTERAKTIF KABUPATEN PURWOREJO
# =====================================================

library(terra)
library(sf)
library(leaflet)
library(htmlwidgets)
library(htmltools)

# 1. Lokasi file
folder_data <- "C:/Users/HP/Downloads"
folder_output <- "C:/Users/HP/Documents/TUBES ETS PEMSPA/Output"
folder_web <- file.path(folder_output, "GitHub Pages")

dir.create(folder_web, recursive = TRUE, showWarnings = FALSE)

file_raster <- file.path(
  folder_output, "klasifikasi_purworejo.tif"
)

file_kab <- file.path(
  folder_data, "Batas Adm Kabupaten_Purworejo.shp"
)

file_kec <- file.path(
  folder_data, "Batas Adm Kecamatan_Purworejo.shp"
)

stopifnot(file.exists(file_raster))
stopifnot(file.exists(file_kab))
stopifnot(file.exists(file_kec))

# 2. Membaca data
kelas <- terra::rast(file_raster)
kabupaten <- sf::st_read(file_kab, quiet = TRUE)
kecamatan <- sf::st_read(file_kec, quiet = TRUE)

# Pastikan CRS raster terdefinisi.
# Raster dari workflow utama seharusnya EPSG:32749.
if (is.na(terra::crs(kelas))) {
  stop("CRS raster tidak diketahui. Periksa CRS pada file GeoTIFF.")
}

# 3. Transformasi batas ke WGS 84
kabupaten <- sf::st_transform(kabupaten, 4326)
kecamatan <- sf::st_transform(kecamatan, 4326)

# 4. Proyeksi raster untuk tampilan Leaflet
# Klasifikasi merupakan data kategori, sehingga gunakan nearest neighbour.
kelas_web <- terra::project(
  kelas,
  "EPSG:3857",
  method = "near"
)

# Kurangi ukuran raster jika diperlukan agar lebih ringan.
faktor <- max(
  1,
  ceiling(max(ncol(kelas_web), nrow(kelas_web)) / 1800)
)

if (faktor > 1) {
  kelas_web <- terra::aggregate(
    kelas_web,
    fact = faktor,
    fun = "modal",
    na.rm = TRUE
  )
}

# 5. Warna kelas tutupan lahan
warna <- c(
  "1" = "#329447",  # Vegetasi
  "2" = "#D96050",  # Bangunan
  "3" = "#3589CD",  # Perairan
  "4" = "#D9D9D9"   # Awan
)

label <- c(
  "Vegetasi",
  "Bangunan",
  "Perairan",
  "Awan"
)

pal <- leaflet::colorFactor(
  palette = unname(warna),
  domain = 1:4,
  levels = 1:4,
  na.color = "transparent"
)

# 6. Membuat peta
peta <- leaflet(
  options = leafletOptions(preferCanvas = TRUE)
) |>
  addProviderTiles(
    providers$CartoDB.Positron,
    group = "Peta dasar"
  ) |>
  addRasterImage(
    x = kelas_web,
    colors = pal,
    opacity = 0.72,
    project = FALSE,
    group = "Klasifikasi tutupan lahan",
    maxBytes = 12 * 1024^2
  ) |>
  addPolygons(
    data = kecamatan,
    group = "Batas kecamatan",
    color = "#555555",
    weight = 1,
    fill = FALSE,
    label = ~as.character(
      if ("NAMOBJ" %in% names(kecamatan)) {
        kecamatan$NAMOBJ
      } else {
        seq_len(nrow(kecamatan))
      }
    )
  ) |>
  addPolygons(
    data = kabupaten,
    group = "Batas kabupaten",
    color = "#222222",
    weight = 2,
    fill = FALSE,
    label = "Kabupaten Purworejo"
  ) |>
  addLegend(
    position = "bottomright",
    colors = unname(warna),
    labels = label,
    title = "Tutupan lahan",
    opacity = 1
  ) |>
  addLayersControl(
    overlayGroups = c(
      "Klasifikasi tutupan lahan",
      "Batas kecamatan",
      "Batas kabupaten"
    ),
    options = layersControlOptions(collapsed = FALSE)
  ) |>
  addScaleBar(
    position = "bottomleft",
    options = scaleBarOptions(metric = TRUE)
  ) |>
  fitBounds(
    lng1 = unname(st_bbox(kabupaten)["xmin"]),
    lat1 = unname(st_bbox(kabupaten)["ymin"]),
    lng2 = unname(st_bbox(kabupaten)["xmax"]),
    lat2 = unname(st_bbox(kabupaten)["ymax"])
  ) |>
  addControl(
    html = HTML(
      paste0(
        "<div style='background:white;padding:10px;",
        "border-radius:5px;box-shadow:0 1px 5px #999;'>",
        "<b>Peta Klasifikasi Tutupan Lahan</b><br>",
        "Kabupaten Purworejo, Jawa Tengah<br>",
        "<small>Sentinel-2 Level-2A, 26 Juli 2026</small>",
        "</div>"
      )
    ),
    position = "topright"
  )

# 7. Menyimpan peta menjadi HTML
# Folder index_files wajib ikut diunggah ke GitHub.
htmlwidgets::saveWidget(
  widget = peta,
  file = file.path(folder_web, "index.html"),
  selfcontained = FALSE,
  title = "Peta Interaktif Tutupan Lahan Purworejo"
)

message(
  "Selesai! Buka file index.html di folder GitHub Pages."
)
