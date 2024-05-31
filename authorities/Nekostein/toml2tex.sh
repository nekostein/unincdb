#!/bin/bash


### Copyright (c) 2024 Nekostein (https://nekostein.com/). All rights reserved.
### Redistribution is permitted as part of the "unincdb" repository. Do not use otherwise.




### Using 'Format Nekostein' to render UNINC.toml into LaTeX
### Similar scripts may coexist in parallel as tools of different witness agencies


tomlpath="$1"
workdir="$(dirname "$tomlpath")"
outfn="$1.$OFFICE.1.texpart"
echo '' > "$outfn"

workdir_alt="$(cut -d/ -f2- <<< "$workdir")"
printf -- '\href{https://unincdb.nekostein.com/%s.pdf}{https://unincdb.nekostein.com/%s.pdf}' \
    "$workdir_alt" "$workdir_alt" | tr -d '\n' \
    > "$1.Nekostein.2.texpart"

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


charter_md_url="https://unincdb.nekostein.com/$workdir_alt.md633251ca87f8b59d1c986eb508d9b22634dacf02633251ca87f8b59d1c986eb508d9b22634dacf02"

(
    printf '\\renewcommand{\\cachedunincname}[0]'
    printf '{%s}\n' "$(tomlq -r .fullname "$tomlpath")"
    printfield 'Business Name' fullname manifestfieldbig
    echo '\manifestfield{Date of Issue}{'"$(TZ=UTC date +%Y-%m-%d)"'}'
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

echo "$charter_md_url" | makehreflinks > "$1.Nekostein.101.texpart"


# Make sure that the smaller version exists
if which timegate; then
    timegate=timegate
else
    timegate=''
fi
export src="_dist/libvi/patterns/p02.js.png"
export dst="_dist/libvi/patterns/p02.js.small.png"
# command "$timegate" convert "$src" -colors 40 -scale '75%' -quality 80 -background white -alpha remove -alpha off "$dst"
# du -xhd1 "$dst"
