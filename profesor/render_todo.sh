#!/bin/sh
# Regenera los datos, los puntos de control y la web del curso (en _output/).
# Ejecutar desde la raíz del proyecto: sh profesor/render_todo.sh
set -e

Rscript profesor/generar_datos.R
quarto render
