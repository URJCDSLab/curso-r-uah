# Curso de iniciación a R

Departamento de Ciencias de la Educación (Psicología Evolutiva y de la Educación), Universidad de Alcalá.

Web del curso (apuntes, ejercicios e instalación): <https://urjcdslab.github.io/curso-r-uah/>

Curso práctico de 8 horas (2 sesiones de 4 h) para iniciarse en R, orientado a profesorado e investigadores
en educación y psicología. Prepara el terreno para formaciones más específicas (SEM, metaanálisis, etc.).

## Contenido

| Sesión | Bloques |
|---|---|
| 1. Primeros pasos con R | 1.1 RStudio, proyectos y `renv`; 1.2 Objetos, tipos y vectores; 1.3 Factores, tablas de datos y listas; 1.4 Funciones, condiciones y bucles; **Ejercicio 1**; 1.5 Importar datos; 1.6 Limpiar la encuesta (R base); 1.7 Describir los datos; 1.8 Informes reproducibles con Quarto; **Ejercicio 2** (primer informe) |
| 2. Transformar y visualizar datos | 2.1 `dplyr`; 2.2 Recodificar, puntuar escalas y resumir; **Ejercicio 1**; 2.3 `pivot_*` y _joins_; 2.4 `ggplot2`; 2.5 Correlación, prueba _t_ y regresión; 2.6 Resultados en Quarto y proyecto propio con `renv`; **Ejercicio 2** (pregunta de principio a fin en Quarto) |

Cada sesión dura 4 h: unas 3 h de demostración en directo (los apuntes llevan el tiempo aproximado de cada bloque), dos ejercicios de 15 minutos
con su puesta en común y un descanso. Cada ejercicio tiene unos pasos guiados con pistas y una ampliación; en los ficheros de ejercicios empieza con la marca `[EJERCICIO]`.
Los bloques indican también un punto de control (`checkpoints/*.rds`) desde el que continuar si alguien se ha perdido.

La sesión 1 no usa `dplyr` ni `|>`: la limpieza se hace con R base y un bucle `for`. La sesión 2 empieza rehaciendo esa limpieza con `mutate()` + `across()`.
En los recuadros "También con RStudio" se indica la alternativa con menús y paneles (importar, instalar paquetes, exportar gráficos, _Render_...).

## Estructura

```
curso_R_UAH/
├── curso_R_UAH.Rproj            # abrir siempre el proyecto desde aquí
├── _quarto.yml                  # proyecto Quarto (web): navegación, autores, opciones comunes
├── index.qmd                    # página de inicio
├── renv.lock, renv/, .Rprofile  # entorno reproducible (renv)
├── 00_preparacion/
│   └── preparacion.qmd          # instalación (obligatoria) + primeros pasos (opcional)
├── sesion1.qmd                  # apuntes de la sesión 1
├── sesion1_ejercicios.qmd       # enunciados de los ejercicios del alumnado
├── informe_ejemplo.qmd          # informe Quarto de ejemplo (bloque 1.8)
├── sesion2.qmd
├── sesion2_ejercicios.qmd
├── datos/
│   ├── encuesta_bruta.xlsx      # encuesta simulada, "sucia" a propósito (hojas: respuestas, diccionario)
│   ├── centros.csv              # CSV en formato español (; y ,)
│   └── intervencion_prepost.csv # comprensión lectora pre/post/seguimiento, formato ancho
├── checkpoints/                 # puntos de control (.rds) generados al renderizar
├── _output/                     # web generada (abrir _output/index.html)
└── profesor/                    # NO distribuir al alumnado
    ├── generar_datos.R          # simulación de los datos (semilla fija)
    └── render_todo.sh           # regenera datos, checkpoints y la web
```

## Datos

Todos los datos son **simulados** (`profesor/generar_datos.R`, semilla 2026): 320 estudiantes de ESO de 10 centros,
con 12 ítems Likert (1-5) de **motivación**, **ansiedad ante los exámenes** y **autoeficacia académica**
(`m4` y `ae3` están invertidos) y la nota media de la 1ª evaluación. La exportación imita la de un formulario en línea:
enunciados como nombres de columna, extremos de la escala con etiqueta (`"5 - Muy de acuerdo"`), edades como `"14 años"`,
`NS/NC` y celdas vacías.

Resultados que se trabajan en clase: la autoeficacia es el mejor predictor de la nota; el grupo de intervención mejora y mantiene
la mejora en el seguimiento. En el ejercicio 2 de la sesión 2, la pregunta 1 (zona rural/urbana) da un resultado significativo y la 2 (ciclo) no,
lo que permite discutir ambos casos.

## Renderizar

Es un proyecto Quarto de tipo web (`_quarto.yml`). Desde la raíz del proyecto:

```sh
quarto render     # genera la web en _output/
```

`sesion1.qmd` genera `checkpoints/encuesta_limpia.rds`, y `sesion2.qmd`, `checkpoints/encuesta_escalas.rds`; son los puntos de control que usan los ejercicios, por eso el orden de `render` en `_quarto.yml` importa.
`sh profesor/render_todo.sh` lo regenera todo: datos, puntos de control y la web.

Las soluciones de los ejercicios están en los apuntes, ocultas. Para ver las de una sesión:
`quarto render sesion1.qmd -M solucion:true`.

## Qué distribuir al alumnado

- Un `.zip` de la carpeta **sin** `profesor/` ni `renv/library/`.
- Las instrucciones de instalación (`_output/00_preparacion/preparacion.html`) una semana antes del curso.

## Origen

Adaptado del material de R de la asignatura _Programación Orientada al Análisis de Datos_ (Máster Universitario en Análisis de Datos Deportivos),
sustituyendo los ejemplos deportivos por datos del ámbito educativo. Cada bloque indica en un comentario `<!-- Fuente: ... -->` la sección de origen.
