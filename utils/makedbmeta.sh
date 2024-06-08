#!/bin/bash

touch .myenv

source .env
source .myenv



function process_toml_path() {
    toml_path="$1/UNINC.toml"
    local tomlkeyi18nprefix="."
    if [[ -n "$TOML_I18N_PREFER" ]]; then
        if [[ "$(tomlq -r ".i18n.$TOML_I18N_PREFER" "$toml_path")" != null ]]; then
            tomlkeyi18nprefix=".i18n.$TOML_I18N_PREFER."
        fi
    fi
    URL="$(bash utils/helper-transformpdfpath.sh "$1/witness-$OFFICE.pdf" | cut -d/ -f4-)"
    [[ ! -e "$toml_path" ]] && return 0

    echo -n '\bizinfo'

    fields1="fullname type status president secretary"
    for ff in $fields1; do
        printf '{%s}' "$(tomlq -r "${tomlkeyi18nprefix}${ff}" "$toml_path")"
    done
    fields2="date_creation charter_hash"
    for ff in $fields2; do
        printf '{%s}' "$(tomlq -r ".${ff}" "$toml_path")"
    done
    printf '{%s}\n\n' "$URL"
}




LIST="authorities/$OFFICE/witnesslist.txt"
OUT="authorities/$OFFICE/dblist.texpart"





years="$(cut -d/ -f2 "$LIST" | sort -ru)"

echo "years=$years"

for year in $years; do
    printf '\n\n\\thisyear{%s}\n\n' "$year"
    grep "/$year/" "$LIST" | cut -d';' -f1 | while read -r line; do
        process_toml_path "$line"
    done
done > "$OUT"


