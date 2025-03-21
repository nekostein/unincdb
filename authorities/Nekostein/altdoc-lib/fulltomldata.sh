#!/bin/bash



tomlkeyi18nprefix="."
if [[ -n "$TOML_I18N_PREFER" ]]; then
    if [[ "$(tomlq -r ".i18n.$TOML_I18N_PREFER" "$toml")" != null ]]; then
        tomlkeyi18nprefix=".i18n.$TOML_I18N_PREFER."
    fi
fi


tomlq -r '[paths | map(tostring) | join(".")][]' "$toml" | grep -vE '[0-9]' > .workdir/tomlkeys.txt
while read -r tomlkey; do
    tomlkey_flat="$(sed 's|\.|DOT|g' <<< "$tomlkey" | sed 's|_||g')"
    toml_value="$(tomlq -r "${tomlkeyi18nprefix}${tomlkey}" "$toml")"
    case "$(tomlq -r "${tomlkeyi18nprefix}${tomlkey} | type" "$toml")" in
        'object')
            printf ''
            ;;
        'array')
            printf '\\providecommand{\\fulltomldataAT%s}[0]{%s}\n' "$tomlkey_flat" "$(tomlq -r "${tomlkeyi18nprefix}${tomlkey}[]" "$toml")"
            ;;
        'string')
            printf '\\providecommand{\\fulltomldataAT%s}[0]{%s}\n' "$tomlkey_flat" "$toml_value"
            ;;
    esac
done < .workdir/tomlkeys.txt

printf '\\providecommand{\\unincdbaltdocprefix}[0]{https://unincdb.nekostein.com/id/%s}\n' "$(grep "^$ORGDIR;" "authorities/$OFFICE/witnesslist.txt" | cut -d';' -f2)"

itr=1
for coldef in path regno; do
    printf '\\providecommand{\\witnesslistkeyname%s}[0]{%s}' "$coldef" "$(grep "^$ORGDIR;" "authorities/$OFFICE/witnesslist.txt" | cut -d';' -f$itr)"
    itr=$((itr+1))
done
