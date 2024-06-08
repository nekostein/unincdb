#!/bin/bash


### Copyright (c) 2024 Nekostein (https://nekostein.com/). All rights reserved.
### Redistribution is permitted as part of the "unincdb" repository. Do not use otherwise.




### Using 'Format Nekostein' to render UNINC.toml into LaTeX
### Similar scripts may coexist in parallel as tools of different witness agencies



source authorities/Nekostein/altdoc-lib/lib.sh


tomlpath="$1"
workdir="$(dirname "$tomlpath")"
outfn="$1.$OFFICE.1.texpart"
echo '' > "$outfn"

workdir_alt="$(cut -d/ -f2- <<< "$workdir")"
printf -- '\href{https://unincdb.nekostein.com/%s.pdf}{https://unincdb.nekostein.com/%s.pdf}' \
    "$workdir_alt" "$workdir_alt" | tr -d '\n' \
    > "$1.Nekostein.2.texpart"




### Obtain Filing ID...
get_regno "$workdir" "$1.Nekostein.regno.texpart"



function printfield() {
    keyname="$1"
    tomlkey="$2"
    texcmdname="$3"
    if [[ -z "$3" ]]; then
        texcmdname="manifestfield"
    fi
    value="$(tomlq -r ."$tomlkey" "$tomlpath")"
    echo '\'"$texcmdname"'{'"$keyname"'}{'"$value"'}'
}


charter_md_url="https://unincdb.nekostein.com/id/$regno.Charter.html"

(
    printf '\\renewcommand{\\cachedunincname}[0]'
    printf '{%s}\n' "$(tomlq -r .fullname "$tomlpath")"
    printfield 'Business Name' fullname manifestfieldbig
    # echo '\manifestfield{Date of Issue}{'"$(TZ=UTC date +%Y-%m-%d)"'}'
    echo '\manifestfieldbig{Filing ID}{'"$regno"'}'
    printfield 'Type' type
    printfield 'Date of Creation' date_creation
    printfield 'Status' status
    printfield 'President' president
    printfield 'Secretary' secretary
    
    hash_real="$(cat "$workdir/Charter.md.hash")"
    echo '\manifestfield{Charter Hash}{'"$(
        echo -n '\href'
        printf '{%s}' "$charter_md_url"
        printf '{%s}' "$hash_real"
    )"'}'
    printfield 'Fields of Conduct' fields
) >> "$outfn"



function process_multiline_text() {
    echo -n "$(cat /dev/stdin)" | tr '\n' '|' | sed 's/|/\\par /g'
}


function makehreflinks() {
    while read -r line; do
        echo '\href{'"$line"'}''{'"$line"'}'
    done < /dev/stdin
}



echo '\manifestfield{Addresses}{'"$(tomlq -r .addresses[] "$tomlpath" | makehreflinks | process_multiline_text)"'}' >> "$outfn"

tomlq -r .witness[] "$tomlpath" | makehreflinks | sed 's/^/\\item /' > "$1.Nekostein.99.texpart"

printf '%s\n%s\n' "$charter_md_url" "${charter_md_url/.html/.md}" | makehreflinks > "$1.Nekostein.charter-href.texpart"







