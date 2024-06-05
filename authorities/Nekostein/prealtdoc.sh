#!/bin/bash

bash "authorities/$OFFICE/altdoc-lib/tomldata2tex.sh" > .workdir/tomldata2tex.texpart

tomlq -r '[paths | map(tostring) | join(".")][]' "$toml" | grep -vE '[0-9]' > .workdir/tomlkeys.txt
while read -r tomlkey; do
    tomlkey_flat="$(sed 's|\.|DOT|g' <<< "$tomlkey" | sed 's|_||g')"
    toml_value="$(tomlq -r ."$tomlkey" "$toml")"
    char0="${toml_value:0:1}"
    if [[ "$char0" != "{" ]] && [[ "$char0" != "[" ]]; then
        printf '\\providecommand{\\fulltomldataAT%s}[0]{%s}\n' "$tomlkey_flat" "$toml_value"
    fi
done < .workdir/tomlkeys.txt > .workdir/fulltomldata.texpart

