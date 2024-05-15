#!/bin/bash

### Using 'Format Nekostein' to render UNINC.toml into LaTeX
### Similar scripts may coexist in parallel as tools of different notary agencies

tomlpath="$1"
workdir="$(dirname "$tomlpath")"
outfn="$1.Nekostein.1.texpart"
echo '' > "$outfn"


printf -- "https://unincdb.nekostein.com/%s.pdf" "$workdir" | tr -d '\n' > "$1.Nekostein.2.texpart"


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
    printfield 'Name' fullname manifestfieldbig
    printfield 'Type' type
    printfield 'Date of Creation' date_creation
    printfield 'Status' status
    printfield 'President' president
    printfield 'Secretary' secretary
    echo '\manifestfield{Charter Hash}{'"$(cat "$workdir/Charter.md.hash")"'}'
    printfield 'Fields' fields
) >> "$outfn"


# Iterate over all addresses
# address_arr=""
# for itr in {0..10}; do
#     value="$(tomlq -r .addresses["$itr"] "$tomlpath")"
#     if [[ "$value" != 'null' ]]; then
#         address_arr="$address_arr $value"' \\ '
#     fi
# done
addresses_lines="$()"

function process_addr() {
    # sed ':a;N;$ba;s/\n/\\n/g' /dev/stdin | sed 's/\\$//'
    echo -n $(cat /dev/stdin) | tr ' ' '|' | sed 's/|/\\\\/g'
}

echo '\manifestfield{Addresses}{'"$(tomlq -r .addresses[] "$tomlpath" | process_addr)"'}' >> "$outfn"
