#!/bin/bash

export ORGDIR="$(realpath --relative-to="$PWD" "$1")"
docprefix="authorities/$OFFICE/altdoc/$docname"
texpath=".workdir/$docname.tex"
pdfpath1=".workdir/$docname.pdf"
export PDFPATH_DEST="_dist/altdocs/$OFFICE/$ORGDIR.$docname.pdf"
rsync -a "$ORGDIR/" ".workdir/"
if ! bash "$docprefix/prepare.sh"; then
    echo "[WARNING] Cannot proceed with ./make.sh $* "
    echo "          Because the 'prepare.sh' script asked to skip it."
    exit 1
fi
cp -a "$docprefix/$docname.tex" "$texpath"
"$LATEXBUILDCMD" -output-directory=".workdir" -interaction=errorstopmode "$texpath"
dirname "$PDFPATH_DEST" | xargs mkdir -p
cp -a "$pdfpath1" "$PDFPATH_DEST"
realpath "$PDFPATH_DEST" | xargs du -h
