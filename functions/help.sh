#!/usr/bin/env bash

# Catalogo auto-generado de todo lo que definen los dotfiles: funciones,
# aliases y scripts de bin/. Se actualiza solo al escanear los ficheros.
#
#   dothelp            lista todo, agrupado por fichero
#   dothelp docker     filtra por termino (nombre, descripcion o grupo)
#   dotpick            buscador interactivo (fzf) con preview del codigo

# Emite TSV: grupo <TAB> tipo <TAB> nombre <TAB> descripcion <TAB> fichero <TAB> linea
# (los nombres que empiezan por "_" se consideran internos y se omiten)
function _dothelp_list {
    local f grp
    for f in "$FUNCTIONS_DIR"/*.sh; do
        grp="${f##*/}"; grp="${grp%.sh}"
        awk -v grp="$grp" -v file="$f" '
            function emit(kind, name, desc) {
                if (name ~ /^_/) return
                printf "%s\t%s\t%s\t%s\t%s\t%d\n", grp, kind, name, desc, file, FNR
            }
            /^#!/ { next }
            /^[[:space:]]*#/ {
                l = $0; sub(/^[[:space:]]*#+[[:space:]]?/, "", l)
                if (l != "" && pend == "") pend = l
                next
            }
            /^function[[:space:]]+[A-Za-z0-9_:.-]+/ {
                n = $0; sub(/^function[[:space:]]+/, "", n); sub(/[[:space:](].*/, "", n)
                emit("func", n, pend); pend = ""; next
            }
            /^[A-Za-z0-9_:.-]+[[:space:]]*\(\)/ {
                n = $0; sub(/[[:space:]]*\(\).*/, "", n)
                emit("func", n, pend); pend = ""; next
            }
            /^alias[[:space:]]+[A-Za-z0-9_:.-]+=/ {
                n = $0; sub(/^alias[[:space:]]+/, "", n); sub(/=.*/, "", n)
                v = $0; sub(/^alias[[:space:]]+[^=]*=/, "", v)
                emit("alias", n, (pend != "" ? pend : v)); pend = ""; next
            }
            /^[[:space:]]*$/ { pend = ""; next }
            { pend = "" }
        ' "$f"
    done

    for f in "$DOTFILES_DIR"/bin/*; do
        [ -f "$f" ] || continue
        awk -v file="$f" '
            NR == 1 && /^#!/ { next }
            /^[[:space:]]*#/ {
                l = $0; sub(/^[[:space:]]*#+[[:space:]]?/, "", l)
                if (l != "") { desc = l; exit }
                next
            }
            /^[^#[:space:]]/ { exit }
            END {
                n = file; sub(/.*\//, "", n)
                printf "bin\tscript\t%s\t%s\t%s\t1\n", n, desc, file
            }
        ' "$f"
    done
}

# dothelp: lista funciones, aliases y scripts de los dotfiles (filtra con un termino).
function dothelp {
    local raw
    raw=$(_dothelp_list)
    if [ -n "$1" ]; then
        raw=$(printf '%s\n' "$raw" | grep -i -- "$1")
        if [ -z "$raw" ]; then
            echo "dothelp: sin coincidencias para '$1'"
            return 1
        fi
    fi
    printf '%s\n' "$raw" \
        | sort -t"$(printf '\t')" -k1,1 -k3,3 \
        | awk -F'\t' '
            $1 != prev { printf "\n\033[1;34m▸ %s\033[0m\n", $1; prev = $1 }
            { printf "  \033[1m%-22s\033[0m \033[2m%-6s\033[0m %s\n", $3, $2, $4 }
          ' \
        | less -RFX
}

# dotpick: buscador interactivo (fzf) de comandos con preview del codigo.
function dotpick {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "dotpick necesita fzf (brew install fzf)"
        return 1
    fi
    local prev sel
    if command -v bat >/dev/null 2>&1; then
        prev='bat --color=always --style=numbers --highlight-line {6} --line-range {6}: {5}'
    else
        prev='tail -n +{6} {5}'
    fi
    sel=$(_dothelp_list \
        | sort -t"$(printf '\t')" -k1,1 -k3,3 \
        | fzf --delimiter='\t' --with-nth='1,2,3,4' \
              --preview="$prev" --preview-window='right,60%,border-left' \
              --header='Funciones / aliases / scripts de los dotfiles')
    [ -n "$sel" ] && printf '%s\n' "$sel" | awk -F'\t' '{ print $3" — "$4 }'
}
