#!/usr/bin/env bash

# optimize-images: optimiza imagenes por lote (reemplazo de imageoptim-cli).
#
# Un solo comando que elige la herramienta segun el formato:
#   PNG  -> oxipng   (sin perdida, rapido y multihilo)
#   JPEG -> jpegoptim (sin perdida, quita metadatos)
#   GIF  -> gifsicle  (sin perdida)
#
# Uso:
#   optimize-images                 # directorio actual, recursivo
#   optimize-images ./assets        # un directorio, recursivo
#   optimize-images foto.png a.jpg  # archivos sueltos
#
# Modifican los archivos EN SITIO (como hacia imageoptim).
function optimize-images {
    if [ "$#" -eq 0 ]; then set -- .; fi

    local target
    for target in "$@"; do
        if [ ! -e "$target" ]; then
            echo "no existe: $target"
            continue
        fi
        find "$target" -type f -iname '*.png' -exec oxipng -o max --strip safe {} +
        find "$target" -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) -exec jpegoptim --strip-all {} +
        find "$target" -type f -iname '*.gif' -exec gifsicle --batch -O3 {} +
    done
}

# optimize-png-lossy: PNG con perdida (reduce mucho mas, tipo ImageAlpha).
# Uso: optimize-png-lossy imagen.png [...]
function optimize-png-lossy {
    if [ "$#" -eq 0 ]; then
        echo "Uso: optimize-png-lossy <archivo.png> [...]"
        return 1
    fi
    pngquant --force --skip-if-larger --strip --ext .png "$@"
}
