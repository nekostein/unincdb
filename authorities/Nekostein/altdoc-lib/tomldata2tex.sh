#!/bin/bash


# fullname = "SAMPLE DATA FOR UNINCDB TUTORIAL"
# type = "Quasi-LLC"
# date_creation = "1970-01-01"
# status = "Active"
# fields = "Information Technology; Witness Service"
# president = "NERUTHES"
# secretary = "NERUTHES"
# charter_hash = "633251ca87f8b59d1c986eb508d9b22634dacf02"
# addresses = [
#     "https://github.com/nekostein/unincdb",
# ]
# witness = [
#     "https://unincdb.nekostein.com/1970/unincdb-tutorial.pdf"
# ]

keys="fullname type date_creation status fields president secretary charter_hash"


for keyname in $keys; do
    printf '\\providecommand{\\uninctomldataAT%s}{%s}\n' "$(tr -d '_' <<< "$keyname")" "$(tomlq -r ".$keyname" .workdir/UNINC.toml)"
done

### Make array of \item
for keyname in addresses witness; do
    printf '\\providecommand{\\uninctomldataAT%sITEM}{%s}\n' "$keyname" "$(
        tomlq -r ".$keyname[]" .workdir/UNINC.toml | sed 's|^|\\item |'
    )"
done


