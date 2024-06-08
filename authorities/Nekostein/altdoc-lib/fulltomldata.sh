#!/bin/bash

tomlq -r '[paths | map(tostring) | join(".")][]' "$toml" | grep -vE '[0-9]' > .workdir/tomlkeys.txt
while read -r tomlkey; do
    tomlkey_flat="$(sed 's|\.|DOT|g' <<< "$tomlkey" | sed 's|_||g')"
    toml_value="$(tomlq -r ."$tomlkey" "$toml")"
    char0="${toml_value:0:1}"
    if [[ "$char0" != "{" ]] && [[ "$char0" != "[" ]]; then
        printf '\\providecommand{\\fulltomldataAT%s}[0]{%s}\n' "$tomlkey_flat" "$toml_value"
    fi
done < .workdir/tomlkeys.txt

printf '\\providecommand{\\unincdbaltdocprefix}[0]{https://unincdb.nekostein.com/%s}\n' "$(grep "^$ORGDIR;" "authorities/$OFFICE/witnesslist.txt" | cut -d';' -f2)"

itr=1
for coldef in path regno; do
    printf '\\providecommand{\\witnesslistkeyname%s}[0]{%s}' "$coldef" "$(grep "^$ORGDIR;" "authorities/$OFFICE/witnesslist.txt" | cut -d';' -f$itr)"
    itr=$((itr+1))
done
