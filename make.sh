#!/bin/bash

### Copyright (c) 2024 Neruthes. Published with the MIT license.



touch .myenv
source .env
source .myenv
mkdir -p _dist .tmp



function try_make() {
    if [[ -e "$1" ]]; then
        ./make.sh "$1"
    fi
}

function hash_compare() {
    dir="$1"
    cached_hash="$(cat "$dir/Charter.md.hash")"
    if ! grep -qs "$cached_hash" "$dir/UNINC.toml"; then
        echo "[ERROR] $dir/UNINC.toml hash is incorrect! See $dir/Charter.md.hash"
        cat "$dir/Charter.md.hash"
        [[ "$IGNOREHASHMISMATCH" != y ]] && exit 2
    fi
}

function getdblistcol() {
    (
        cat "authorities/$OFFICE/witnesslist.txt"
        [[ -e db-private/witnesslist.txt ]] && cat db-private/witnesslist.txt
    ) | cut -d';' -f"$1"
}

function altdocsrsync() {
    [[ "$WWW_INCLUDE_ALTDOC" == y ]] && rsync -av _dist/altdocs/$OFFICE/ _dist/www/$OFFICE/
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
        pdf_src="$(dirname "$1")/witness-$OFFICE.pdf"
        destfn_pref="$(bash utils/helper-transformpdfpath.sh "$pdf_src" | sed 's|.pdf$||')"
        sha1sum "$1" | cut -d' ' -f1 > "$1.hash"
        pandoc -i "$1" -f markdown+smart -t latex -o "$1.texpart"
        # dirname_dest="_dist/www/$OFFICE/$(cut -d/ -f2 <<< "$1")"
        dirname_dest="$(dirname "$destfn_pref.Charter.md")"
        mkdir -p "$dirname_dest"
        cp -a "$1" "$destfn_pref.Charter.md"
        html_header="authorities/$OFFICE/deco/Charter_header.html"
        touch "$html_header"
        pandoc --verbose -i "$1" --include-before-body="$html_header" \
            -f markdown+smart -s --number-sections -t html \
            --metadata title="$TITLE_CHARTER_BEFORE$(tomlq -r .fullname "${1/Charter.md/UNINC.toml}")$TITLE_CHARTER_AFTER" \
            -o "$destfn_pref.Charter.html"
        echo "$destfn_pref.Charter.html"
        ;;
    */Appendix.md)
        pandoc -i "$1" -f markdown+smart -t latex -o "$1.texpart"
        ;;
    db/*.tex | db-private/*.tex)
        ### Note: Should support alternative prefix 'db-private'!
        rawdir="$(dirname "$1")"
        rsync -av --delete "$rawdir"/ .workdir/
        wdtexpath=.workdir/"$(basename "$1")"
        "$LATEXBUILDCMD" -output-directory="$rawdir" -interaction=errorstopmode "$wdtexpath"
        pdf_back_path="$(sed 's|.tex$|.pdf|' <<< "$1")"
        du -h "$pdf_back_path"
        ;;
    dbindex)
        texpath="authorities/$OFFICE/dbindex.tex"
        bash utils/makedbmeta.sh
        "$LATEXBUILDCMD" -output-directory="$(dirname "$texpath")" -interaction=errorstopmode "$(basename "$texpath")"
        "$LATEXBUILDCMD" -output-directory="$(dirname "$texpath")" -interaction=errorstopmode "$(basename "$texpath")"
        pdffn="$(sed 's/.tex$/.pdf/' <<< "$texpath")"
        dest="_dist/www/$OFFICE/dbindex.pdf"
        cp -a "$pdffn" "$dest"
        realpath "$dest" | xargs du -h
        ;;
    db/*/witness-*.pdf | db-private/*/witness-*.pdf)
        destfn="$(bash utils/helper-transformpdfpath.sh "$1")"
        mkdir -p "$(dirname "$destfn")"
        cp -a "$1" "$destfn"
        du -xhd1 "$(realpath "$destfn")"
        [[ "$MAKE_PNG" == y ]] && ./make.sh "$destfn"
        ;;
    _dist/*.pdf)
        # example: _dist/www/PearInc/1970/myclub.pdf
        ### Generate a PNG for the first page
        base="$(basename "$1" | cut -d. -f1)"
        cd "$(dirname "$1")" || exit 1
        pdftoppm -png -r "$PDF_DPI" -f 1 -l 1 "$base".pdf "$base"
        pngfn="$(find . -name "${base}*.png" | sort | head -n1)"
        mv -v "$pngfn" "$base.png"
        realpath "$base".png | xargs du -h
        ;;
    gc)
        gc="$2"
        [[ -z $gc ]] && gc=png
        bash utils/gc.sh "$2"
        ;;
    deploy*)
        if [[ -e deploy.sh ]]; then
            ./deploy.sh
        else
            echo "[ERROR] Script file 'deploy.sh' is not found."
            if [[ "$PWD" == "$HOME/EWS/nekostein/unincdb" ]]; then
                ### Avoid accidentally pushing from a special fork!
                wrangler pages deploy _dist/www/Nekostein --project-name="unincdb" --commit-dirty=true --branch=main # The default deploy command
            fi
        fi
        ;;
    all)
        [[ "$WWW_ALLOW_PNG" != y ]] && ./make.sh gc png
        getdblistcol 1 | while read -r orgdir; do
            [[ -e "$orgdir" ]] && try_make "$orgdir"/UNINC.toml
        done
        ;;
    alt)
        ### Example: ./make alt example db/1970/unincdb-tutorial
        ./make.sh gc workdir
        export docname="$2"
        if [[ -n "$3" ]]; then
            bash utils/makealtdocs.sh "$3"
        else
            getdblistcol 1 | while read -r orgdir; do
                bash utils/makealtdocs.sh "$orgdir"
            done
        fi
        
        ;;
    altall)
        ./make.sh gc altdoc
        find "authorities/$OFFICE/altdoc" -maxdepth 1 -mindepth 1 -type d | cut -d/ -f4 | while read -r docname; do
            getdblistcol 1 | while read -r orgdir; do
                [[ -e "$orgdir" ]] &&  ./make.sh alt "$docname" "$orgdir"
            done
        done
        ./make.sh gc workdir
        ;;
    '')
        echo "[INFO] You should specify a build target (a relative path)."
        echo "[INFO] Non-path targets:  all alt altall dbindex gc"
        ;;
    *)
        [[ -e "$1"/UNINC.toml ]] && ./make.sh "$1"/UNINC.toml
        ;;
esac
