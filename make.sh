#!/bin/bash

### Copyright (c) 2024 Neruthes. Published with the MIT license.



touch .myenv
source .env
source .myenv
mkdir -p _dist .tmp



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
        [[ "$IGNOREHASHMISMATCH" != y ]] && exit 2
    fi
}





echo "[INFO] Working on make target: $1"

case "$1" in
    */UNINC.toml | */UNINC.*.toml)
        dir="$(dirname "$1")"
        try_make "$dir/Charter.md" # Get hash file and LaTeX code
        try_make "$dir/Appendix.md" # Get hash file and LaTeX code
        texsrc="authorities/$OFFICE/witness.tex"
        ln -svf "$(realpath --relative-to="$dir" "$texsrc")" "$dir/witness-$OFFICE.tex" # Put code into workdir
        bash "authorities/$OFFICE/toml2tex.sh" "$1" # Render TOML into LaTeX
        ### Compare hash
        hash_compare "$dir"
        try_make "$dir/witness-$OFFICE.tex" # Create PDF letter
        try_make "$dir/witness-$OFFICE.pdf" # Put PDF to _dist
        for suffix in log out; do
            find "$dir" -name 'witness*'."$suffix" -delete
        done
        for namespec in 'texput.log' 'UNINC.*.texpart' '*.pdf'; do
            find "$dir" -name "$namespec" -delete
        done
        ;;
    */Charter.md)
        sha1sum "$1" | cut -d' ' -f1 > "$1.hash"
        pandoc -i "$1" -f markdown+smart -t latex -o "$1.texpart"
        ;;
    */Appendix.md)
        pandoc -i "$1" -f markdown+smart -t latex -o "$1.texpart"
        ;;
    *.tex)
        cd "$(dirname "$1")" || exit 1
        "$LATEXBUILDCMD" -interaction=batchmode "$(basename "$1")"
        ;;
    db/*/witness-*.pdf)
        destfn="$(bash utils/helper-transformpdfpath.sh "$1")"
        mkdir -p "$(dirname "$destfn")"
        cp -a "$1" "$destfn"
        du -xhd1 "$(realpath "$destfn")"
        ;;
    _dist/*.pdf)
        # example: _dist/www/PearInc/1970/myclub.pdf
        # Get script: https://github.com/neruthes/NDevShellRC/blob/master/bin/pdftoimg
        # pdftoimg "$1" '' png
        # echo rm "$1-*"
        base="$(basename "$1" | cut -d. -f1)"
        cd "$(dirname "$1")"
        pdftoppm -png -r 300 -f 1 -l 1 "$base".pdf "$base"
        mv "$base-1.png" "$base.png"
        realpath "$base".png | xargs du -h
        ;;
    deploy*)
        if [[ -e deploy.sh ]]; then
            exec ./deploy.sh
        else
            echo "[ERROR] Script file 'deploy.sh' is not found."
            wrangler pages deploy _dist/www/Nekostein --project-name="unincdb" --commit-dirty=true --branch=main # The default deploy command
        fi
        ;;
    all)
        while read -r line; do
            try_make "$line" &
        done < "authorities/$OFFICE/witnesslist.txt"
        wait
        ;;
esac
