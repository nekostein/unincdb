#!/bin/bash

touch .myenv

source .env
source .myenv

function process_toml_path() {
    toml_path="$1/UNINC.toml"
    # URL="$(cut -d/ -f2-3 <<< "$1")"
    URL="$(bash utils/helper-transformpdfpath.sh "$1/witness-$OFFICE.pdf" | cut -d/ -f4-)"
    [[ ! -e $toml_path ]] && return 0

    echo -n '\bizinfo'

    fields="fullname date_creation type status president secretary charter_hash"
    for ff in $fields; do
        printf '{%s}' "$(tomlq -r ."$ff" "$toml_path")"
    done
    printf '{%s}' "$URL"
}


mkdir -p meta



LIST="authorities/$OFFICE/witnesslist.txt"
OUT="authorities/$OFFICE/dblist.texpart"


### Do we really need the sorting?
# sort -r "$LIST" -o "$LIST".new
# mv "$LIST".new "$LIST"



years="$(cut -d/ -f2 "$LIST" | sort -ru)"


for year in $years; do
    printf '\n\n\\thisyear{%s}\n\n' "$year"
    grep "^db/$year/" "$LIST" | cut -d';' -f1 | while read -r line; do
        process_toml_path "$line"
    done
done > "$OUT"


