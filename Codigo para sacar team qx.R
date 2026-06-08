library(googlesheets4)
library(janitor)
library(dplyr)
library(stringr)

# GENERALES UAS -----------------------------------------------------------
gs4_auth(
  email = "lia.pereo@ciencias.unam.mx",
  scopes = "https://www.googleapis.com/auth/spreadsheets.readonly"
)

url_sheet <- "https://docs.google.com/spreadsheets/d/1Axj6z0U1odyFcdDz7Rjdv2jOZgnh9yIxKAXiWzvXKW4/edit?gid=0#gid=0"

catalogos_clues <- arrow::read_parquet(
  "C:/Users/brittany.pereo/OneDrive - IMSS-BIENESTAR/División de Procesamiento de información - Repositorio de Datos/CLUES/clues.parquet"
)

df_registros_completos <- read_sheet(
  ss = url_sheet,
  sheet = "Registros_completos"
) 

df_registros_completos <- df_registros_completos %>% 
  janitor::clean_names() %>% 
  filter(revision_uas == "APROBADO") %>% 
  left_join(catalogos_clues %>% select(clues = clues_imb,
                                       categoria_gerencial))

clues_mal <- df_registros_completos %>% 
  filter(is.na(categoria_gerencial))

primer_nivel <- df_registros_completos %>% 
  filter(categoria_gerencial %in% c("Núcleos", "Unidades moviles"))

df_registros_completos  <- df_registros_completos %>% 
  filter(!is.na(categoria_gerencial),
         !categoria_gerencial %in% c("Núcleos", "Unidades moviles"))

# UAS TEAM QX SIN TURNO ---------------------------------------------------
df_clues <- df_registros_completos %>% 
  mutate(
    revision_uas = str_to_upper(str_squish(revision_uas)),
    turno = str_to_lower(str_squish(turno)),
    turno = case_when(
      turno == "noturno b" ~ "nocturno b",
      turno == "jornada acumulada" ~ "jornada acumulado",
      TRUE ~ turno
    ),
    cnpm = str_to_upper(str_squish(cnpm)),
    clave_puesto = str_to_upper(str_squish(clave_puesto)),
    clave_puesto = stringi::stri_trans_general(clave_puesto, "Latin-ASCII")
  ) %>% 
  filter(revision_uas == "APROBADO") %>% 
  group_by(clues) %>% 
  summarise(
    me001 = sum(cnpm == "ME001"),
    me002 = sum(cnpm == "ME002"),
    me003 = sum(cnpm == "ME003"),
    en001 = sum(cnpm == "EN001"),
    en_aux = sum(cnpm %in% c("EN002", "EN005")),
    # chof = sum(str_detect(clave_puesto, "CHOF")),
    
    team_qx = pmin(
      me001,
      me002,
      me003,
      en001,
      en_aux
      # chof
    ),
    
    .groups = "drop"
  ) %>% 
  select(
    clues,
    team_qx
  )

writexl::write_xlsx(
  df_clues,
  "C:/Users/brittany.pereo/Downloads/team uas con turno.xlsx"
)

# UAS TEAM QX CON TURNO ---------------------------------------------------
df_clues_turno <- df_registros_completos %>% 
  mutate(
    revision_uas = str_to_upper(str_squish(revision_uas)),
    turno = str_to_lower(str_squish(turno)),
    turno = case_when(
      turno == "noturno b" ~ "nocturno b",
      turno == "jornada acumulada" ~ "jornada acumulado",
      TRUE ~ turno
    ),
    cnpm = str_to_upper(str_squish(cnpm)),
    clave_puesto = str_to_upper(str_squish(clave_puesto)),
    clave_puesto = stringi::stri_trans_general(clave_puesto, "Latin-ASCII")
  ) %>% 
  filter(revision_uas == "APROBADO") %>% 
  group_by(clues, turno) %>% 
  summarise(
    me001 = sum(cnpm == "ME001"),
    me002 = sum(cnpm == "ME002"),
    me003 = sum(cnpm == "ME003"),
    en001 = sum(cnpm == "EN001"),
    en_aux = sum(cnpm %in% c("EN002", "EN005")),
    # chof = sum(str_detect(clave_puesto, "CHOF")),
    
    team_qx = pmin(
      me001,
      me002,
      me003,
      en001,
      en_aux
      # chof
    ),
    
    .groups = "drop"
  ) %>% 
  select(
    clues,
    turno,
    team_qx
  )

writexl::write_xlsx(
  df_clues_turno,
  "C:/Users/brittany.pereo/Downloads/team uas sin turno.xlsx")

# UPE ---------------------------------------------------------------------
gs4_deauth()

gs4_auth(
  email = "lia.pereo@ciencias.unam.mx",
  scopes = "https://www.googleapis.com/auth/spreadsheets.readonly"
)

url_sheet_upe <- "https://docs.google.com/spreadsheets/d/1iSEdYOU1uDF7Gwnu0o9ABR9hv3pI1INnrJv2Yt9jbN0/edit?gid=0#gid=0"

df_upe <- read_sheet(
  ss = url_sheet_upe,
  sheet = "Hoja 1"
) %>% 
  janitor::clean_names()

df_upe_limpia <- df_upe %>% 
  filter(upe == "Aceptado") %>% 
  left_join(catalogos_clues %>% select(clues = clues_imb,
                                       categoria_gerencial))

clues_mal <- df_registros_completos %>% 
  filter(is.na(categoria_gerencial))

primer_nivel <- df_registros_completos %>% 
  filter(categoria_gerencial %in% c("Núcleos", "Unidades moviles"))

df_registros_completos  <- df_registros_completos %>% 
  filter(!is.na(categoria_gerencial),
         !categoria_gerencial %in% c("Núcleos", "Unidades moviles"))


df_registros_completos <- df_registros_completos %>% 
  transmute(clues, candidato = curp, puesto = cnpm, fase)

writexl::write_xlsx(
  df_registros_completos,
  "C:/Users/brittany.pereo/Downloads/base armando.xlsx")
