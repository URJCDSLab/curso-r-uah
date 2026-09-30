#!/bin/sh
# Regenera los datos, los puntos de control y las dos versiones del curso.
# Ejecutar desde la raíz del proyecto: sh profesor/render_todo.sh
#   _output/alumnado/  apuntes sin soluciones
#   _output/profesor/  apuntes con soluciones
set -e

Rscript profesor/generar_datos.R
quarto render
quarto render --profile profesor
