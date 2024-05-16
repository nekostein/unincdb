#!/bin/bash

### Using 'Format Nekostein' to render UNINC.toml into LaTeX
### Similar scripts may coexist in parallel as tools of different notary agencies

tomlpath="$1"
workdir="$(dirname "$tomlpath")"
outfn="$1.Nekostein.1.texpart"
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



(
    printfield 'Business Name' fullname manifestfieldbig
    printfield 'Type' type
    printfield 'Date of Creation' date_creation
    printfield 'Status' status
    printfield 'President' president
    printfield 'Secretary' secretary
    echo '\manifestfield{Charter Hash}{'"$(cat "$workdir/Charter.md.hash")"'}'
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



echo '\manifestfield{Date of Issue}{'"$(TZ=UTC date +%Y-%m-%d)"'}' >> "$outfn"
echo '\manifestfield{Addresses}{'"$(tomlq -r .addresses[] "$tomlpath" | makehreflinks | process_multiline_text)"'}' >> "$outfn"
echo '\manifestfield{Notary Witness}{'"$(tomlq -r .notary[] "$tomlpath" | makehreflinks | process_multiline_text)"'}' >> "$outfn"
