#!/bin/bash



keys="fullname type date_creation status fields president secretary charter_hash"


for keyname in $keys; do
    printf '\\providecommand{\\uninctomldataAT%s}{%s}\n' "$(tr -d '_' <<< "$keyname")" "$(tomlq -r ".$keyname" .workdir/UNINC.toml)"
done

### Make array of \item
for keyname in addresses witness; do
    printf '\\providecommand{\\uninctomldataAT%sITEM}{%s}\n' "$keyname" "$(
        tomlq -r ".$keyname[]" .workdir/UNINC.toml | sed 's|^|\\item |'
    )"
    printf '\\providecommand{\\uninctomldataAT%sFIRST}{%s}\n' "$keyname" "$(
        tomlq -r ".$keyname[0]" .workdir/UNINC.toml
    )"
done


