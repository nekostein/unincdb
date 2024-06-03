#!/bin/bash

case $1 in
    png)
        find "_dist/www/$OFFICE" -name '*.pdf' | while read -r line; do
            pngpath="${line/.pdf/.png}"
            echo "pngpath=$pngpath"
            [[ -e "$pngpath" ]] && rm "$pngpath"
        done
        ;;
    workdir)
        find .workdir -type f -delete
        ;;
    db)
        find db -name '*.texpart' -type f -delete
        find db -name 'witness-*.*' -type f -delete
        ;;
    altdoc)
        find "_dist/altdocs/$OFFICE" -name '*.pdf' -type f -delete
        ;;
esac
