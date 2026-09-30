# Genera los datos simulados del curso (solo para el profesorado).
# Ejecutar desde la raíz del proyecto: source("profesor/generar_datos.R")
#
# - datos/encuesta_bruta.xlsx     Encuesta tipo Google Forms, "sucia" a propósito
# - datos/centros.csv             Información de centros (formato CSV español)
# - datos/intervencion_prepost.csv  Comprensión lectora pre/post/seguimiento (formato ancho)

library(tidyverse)
set.seed(2026)

n <- 320

# Centros ----------------------------------------------------------------
centros <- tibble(
  centro = sprintf("C%02d", 1:10),
  titularidad = c("Pública", "Pública", "Concertada", "Pública", "Concertada",
                  "Pública", "Pública", "Concertada", "Pública", "Pública"),
  zona = c("Urbana", "Urbana", "Urbana", "Rural", "Urbana",
           "Rural", "Urbana", "Urbana", "Rural", "Rural"),
  n_alumnos = c(620, 845, 510, 230, 395, 180, 710, 460, 205, 160),
  ratio_alumnos_profesor = c(11.8, 12.4, 13.1, 9.6, 12.9, 8.7, 12.0, 13.4, 9.1, 8.2)
)

# Estudiantes y factores latentes ----------------------------------------
alumnos <- tibble(
  id = sprintf("E%03d", 1:n),
  centro = sample(centros$centro, n, replace = TRUE, prob = centros$n_alumnos),
  curso = sample(c("1º ESO", "2º ESO", "3º ESO", "4º ESO"), n, replace = TRUE),
  sexo = sample(c("Chica", "Chico", "Prefiero no decirlo"), n, replace = TRUE,
                prob = c(0.49, 0.48, 0.03))
) |>
  mutate(
    nivel = as.integer(substr(curso, 1, 1)),
    edad = 11 + nivel + rbinom(n, 1, 0.5) + rbinom(n, 1, 0.12),   # 12-13 en 1º (+1 si repite)
    zona = centros$zona[match(centro, centros$centro)]
  )

# Correlaciones entre motivación, ansiedad y autoeficacia
R <- matrix(c( 1.0, -0.25,  0.50,
              -0.25,  1.0, -0.40,
               0.50, -0.40,  1.0), 3)
lat <- MASS::mvrnorm(n, mu = c(0, 0, 0), Sigma = R)
colnames(lat) <- c("mot", "anx", "ae")
alumnos <- bind_cols(alumnos, as_tibble(lat)) |>
  mutate(
    mot = mot - 0.20 * (nivel - 2.5) + if_else(zona == "Rural", 0.65, 0),
    anx = anx + if_else(sexo == "Chica", 0.30, 0)
  )

likert <- function(f, carga = 0.8) {
  x <- 3 + 1.1 * (carga * f + rnorm(length(f), sd = sqrt(1 - carga^2)))
  pmin(pmax(round(x), 1), 5)
}

items <- alumnos |>
  transmute(
    M1 = likert(mot, 0.80), M2 = likert(mot, 0.75), M3 = likert(mot, 0.70),
    M4 = 6 - likert(mot, 0.60),                                   # invertido
    A1 = likert(anx, 0.80), A2 = likert(anx, 0.80), A3 = likert(anx, 0.70),
    A4 = likert(anx, 0.65),
    AE1 = likert(ae, 0.80), AE2 = likert(ae, 0.75),
    AE3 = 6 - likert(ae, 0.65),                                   # invertido
    AE4 = likert(ae, 0.70)
  )

alumnos <- alumnos |>
  mutate(nota = round(pmin(pmax(
    6.2 + 0.9 * ae + 0.4 * mot - 0.4 * anx + rnorm(n, sd = 1.1), 1), 10), 1))

# Ensuciar los datos como en una exportación real ----------------------
etiqueta <- function(x) {
  case_when(x == 1 ~ "1 - Muy en desacuerdo",
            x == 5 ~ "5 - Muy de acuerdo",
            TRUE ~ as.character(x))
}
items_txt <- items |> mutate(across(everything(), etiqueta))
for (v in names(items_txt)) {                 # ~3 % en blanco, algún NS/NC
  items_txt[[v]][sample(n, 9)] <- NA
  items_txt[[v]][sample(n, 1)] <- "NS/NC"
}
edad_txt <- as.character(alumnos$edad)
idx <- sample(n, 12)
edad_txt[idx] <- paste(edad_txt[idx], "años")
nota <- alumnos$nota
nota[sample(n, 6)] <- NA

diccionario <- tribble(
  ~codigo, ~pregunta, ~escala, ~invertido,
  "marca_temporal", "Marca temporal", NA, NA,
  "id", "Código de participante", NA, NA,
  "centro", "Centro educativo", NA, NA,
  "curso", "Curso", NA, NA,
  "sexo", "Sexo", NA, NA,
  "edad", "Edad", NA, NA,
  "m1", "Disfruto aprendiendo cosas nuevas en clase", "Motivación", "No",
  "m2", "Me esfuerzo en las tareas aunque sean difíciles", "Motivación", "No",
  "m3", "Me interesa lo que se enseña en el instituto", "Motivación", "No",
  "m4", "Solo estudio porque me obligan", "Motivación", "Sí",
  "a1", "Me pongo muy nervioso/a antes de un examen", "Ansiedad ante exámenes", "No",
  "a2", "Durante los exámenes me quedo en blanco", "Ansiedad ante exámenes", "No",
  "a3", "Me preocupa mucho suspender", "Ansiedad ante exámenes", "No",
  "a4", "La noche antes de un examen me cuesta dormir", "Ansiedad ante exámenes", "No",
  "ae1", "Soy capaz de entender los contenidos más difíciles", "Autoeficacia académica", "No",
  "ae2", "Confío en que puedo sacar buenas notas", "Autoeficacia académica", "No",
  "ae3", "Cuando algo es difícil, me rindo enseguida", "Autoeficacia académica", "Sí",
  "ae4", "Sé organizarme para preparar los exámenes", "Autoeficacia académica", "No",
  "nota", "Nota media de la 1ª evaluación", NA, NA
)

encuesta_bruta <- tibble(
  `Marca temporal` = format(as.POSIXct("2026-10-05 09:00") +
                              sort(sample(0:(14 * 24 * 3600), n)), "%d/%m/%Y %H:%M:%S"),
  `Código de participante` = alumnos$id,
  `Centro educativo` = alumnos$centro,
  Curso = alumnos$curso,
  Sexo = alumnos$sexo,
  Edad = edad_txt
) |>
  bind_cols(setNames(items_txt, diccionario$pregunta[7:18])) |>
  mutate(`Nota media de la 1ª evaluación` = nota)

writexl::write_xlsx(
  list(respuestas = encuesta_bruta, diccionario = diccionario),
  "datos/encuesta_bruta.xlsx"
)

write.csv2(centros, "datos/centros.csv", row.names = FALSE, fileEncoding = "UTF-8")

# Intervención en comprensión lectora (6 centros, 1º y 2º ESO) -----------
interv <- alumnos |>
  filter(centro %in% c("C01", "C02", "C04", "C06", "C07", "C09"),
         curso %in% c("1º ESO", "2º ESO")) |>
  select(id, centro) |>
  mutate(
    grupo = if_else(centro %in% c("C01", "C04", "C07"), "Intervención", "Control"),
    base = rnorm(n(), 50, 10),
    comprension_pre = round(base + rnorm(n(), 0, 4)),
    comprension_post = round(base + if_else(grupo == "Intervención", 7, 1.5) + rnorm(n(), 0, 4)),
    comprension_seguimiento = round(base + if_else(grupo == "Intervención", 5, 1) + rnorm(n(), 0, 5))
  ) |>
  select(-base, -centro)
interv$comprension_seguimiento[sample(nrow(interv), 5)] <- NA

write.csv(interv, "datos/intervencion_prepost.csv", row.names = FALSE, fileEncoding = "UTF-8")
