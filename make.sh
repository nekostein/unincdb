#!/bin/bash

touch .myenv
source .env
source .myenv

function try_make() {
    if [[ -e "$1" ]]; then
        bash "$0" "$1"
    fi
}

function hash_compare() {
    dir="$1"
    cached_hash="$(cat $dir/Charter.md.hash)"
    if ! grep -qs "$cached_hash" "$dir/UNINC.toml"; then
        echo "[ERROR] $dir/UNINC.toml has is incorrect! See $dir/Charter.md.hash"
        cat "$dir/Charter.md.hash"
        exit 2
    fi
}

case $1 in
    */UNINC.toml)
        dir="$(dirname "$1")"
        try_make "$dir/Charter.md" # Get hash file and LaTeX code
        texsrc="src/Witness-$OFFICE.tex"
        ln -svf "$(realpath --relative-to="$dir" "$texsrc")" "$dir/$(basename "$texsrc")" # Put code into workdir
        bash "utils/pretoml-$OFFICE.sh" "$1" # Render TOML into LaTeX
        ### Compare hash
        hash_compare "$dir"
        try_make "$dir/Witness-$OFFICE.tex" # Create PDF letter
        try_make "$dir/Witness-$OFFICE.pdf" # Put PDF to _dist
        for suffix in aux log out; do
            find "$dir" -name 'Witness-*'."$suffix" -delete
        done
        for namespec in 'texput.log' '*.texpart' '*.pdf'; do
            find "$dir" -name "$namespec" -delete
        done
        ;;
    */Charter.md)
        sha1sum "$1" | cut -d' ' -f1 > "$1.hash"
        pandoc -i "$1" -f gfm -t latex -o "$1.texpart"
        ;;
    *.tex)
        cd "$(dirname "$1")" || exit 1
        xelatex "$(basename "$1")"
        ;;
    vol*/Witness-*.pdf)
        destfn="$(bash utils/helper-transformpdfpath.sh "$1")"
        mkdir -p "$(dirname "$destfn")"
        cp -a "$1" "$destfn"
        ;;
    deploy*)
        if [[ -e deploy.sh ]]; then
            exec ./deploy.sh
        else
            echo "[ERROR] Script file 'deploy.sh' is not found."
        fi
        ;;
esac
