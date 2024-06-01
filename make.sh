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
    */UNINC.toml)
        dir="$(dirname "$1")"
        try_make "$dir/Charter.md" # Get hash file and LaTeX code
        try_make "$dir/Appendix.md" # Get hash file and LaTeX code
        texsrc="authorities/$OFFICE/witness.tex"
        # ln -svf "$(realpath --relative-to="$dir" "$texsrc")" "$dir/witness-$OFFICE.tex" # Put code into workdir
        cp -a "$texsrc" "$dir/witness-$OFFICE.tex" # Put code into workdir
        bash "authorities/$OFFICE/toml2tex.sh" "$1" # Render TOML into LaTeX
        ### Compare hash
        hash_compare "$dir"
        try_make "$dir/witness-$OFFICE.tex" # Create PDF letter
        try_make "$dir/witness-$OFFICE.pdf" # Put PDF to _dist
        ### Purge intermediate byproducts
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
        dirname="_dist/www/$OFFICE/$(cut -d/ -f2 <<< "$1")"
        mkdir -p "$dirname"
        cp -a "$1" "$dirname/$(cut -d/ -f3 <<< "$1").md"
        ;;
    */Appendix.md)
        pandoc -i "$1" -f markdown+smart -t latex -o "$1.texpart"
        ;;
    db/*.tex)
        rawdir="$(dirname "$1")"
        rsync -av --delete --mkpath "$rawdir"/ .workdir/
        "$LATEXBUILDCMD" -output-directory="$rawdir" -interaction=errorstopmode .workdir/"$(basename "$1")"
        ;;
    dbindex)
        texpath="authorities/$OFFICE/dbindex.tex"
        bash utils/makedbmeta.sh
        # cd "$(dirname "$1")" || exit 1
        "$LATEXBUILDCMD" -output-directory="$(dirname "$texpath")" -interaction=batchmode "$(basename "$texpath")"
        pdffn="$(sed 's/.tex$/.pdf/' <<< "$texpath")"
        dest="_dist/www/$OFFICE/dbindex.pdf"
        cp -a "$pdffn" "$dest"
        realpath "$dest" | xargs du -h
        ;;
    db/*/witness-*.pdf)
        destfn="$(bash utils/helper-transformpdfpath.sh "$1")"
        mkdir -p "$(dirname "$destfn")"
        cp -a "$1" "$destfn"
        du -xhd1 "$(realpath "$destfn")"
        [[ "$MAKE_PNG" == y ]] && bash "$0" "$destfn"
        ;;
    _dist/*.pdf)
        # example: _dist/www/PearInc/1970/myclub.pdf
        ### Generate a PNG for the first page
        base="$(basename "$1" | cut -d. -f1)"
        [[ -z "$DPI" ]] && DPI=150
        cd "$(dirname "$1")" || exit 1
        pdftoppm -png -r "$DPI" -f 1 -l 1 "$base".pdf "$base"
        pngfn="$(find . -name "${base}*.png" | head -n1)"
        mv "$pngfn" "$base.png"
        realpath "$base".png | xargs du -h
        ;;
    gc)
        gc="$2"
        [[ -z $gc ]] && gc=png
        bash utils/gc.sh "$2"
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
        [[ "$WWW_ALLOW_PNG" != y ]] && ./make.sh gc png
        while read -r line; do
            try_make "$line"/UNINC.toml
        done < "authorities/$OFFICE/witnesslist.txt"
        ;;
    meta|meta/)
        bash utils/makedbmeta.sh
        ;;
    *)
        [[ -e "$1"UNINC.toml ]] && ./make.sh "$1"UNINC.toml
        ;;
esac
