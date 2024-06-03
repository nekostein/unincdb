#!/bin/bash

export toml=".workdir/UNINC.toml"
export ORGDIR="$(realpath --relative-to="$PWD" "$1")"

docprefix="authorities/$OFFICE/altdoc/$docname"
texpath=".workdir/$docname.tex"
typstpath=".workdir/$docname.typ"
pdfpath1=".workdir/$docname.pdf"

export PDFPATH_DEST="_dist/altdocs/$OFFICE/$ORGDIR.$docname.pdf"

rsync -a "$ORGDIR/" ".workdir/"

bash "authorities/$OFFICE/prealtdoc.sh"

if ! bash "$docprefix/prepare.sh"; then
    echo "[WARNING] Cannot proceed with ./make.sh $* "
    echo "          Because the 'prepare.sh' script asked to skip it."
    exit 1
fi

echo "[INFO] Working on:  $docname ~ $ORGDIR"

if [[ -e "$docprefix/$docname.tex" ]]; then
    ### Use LaTeX
    cp -a "$docprefix/$docname.tex" "$texpath"
    mode=batchmode
    [[ "$DEBUG" == y ]] && mode="errorstopmode"
    "$LATEXBUILDCMD" -output-directory=".workdir" -interaction="$mode" "$texpath"
else
    ### Use Typst (experimental support)
    cp -a "$docprefix/$docname.typ" "$typstpath"
    typst c --input ORGDIR="$ORGDIR" "$typstpath"
fi

dirname "$PDFPATH_DEST" | xargs mkdir -p
cp -a "$pdfpath1" "$PDFPATH_DEST"
realpath "$PDFPATH_DEST" | xargs du -h
