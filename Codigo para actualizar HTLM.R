setwd("C:/Users/brittany.pereo/OneDrive - IMSS-BIENESTAR/reporte-candidatos-uas/reporte-candidatos-uas")

system("git pull --rebase")

quarto::quarto_render("reporte_google_sheet.qmd")

system("git add reporte_google_sheet.qmd index.html")

fecha <- format(Sys.time(), "%Y-%m-%d %H:%M")

system(
  paste0(
    'git commit -m "Actualizacion automatica ',
    fecha,
    '"'
  )
)

system("git push origin main")