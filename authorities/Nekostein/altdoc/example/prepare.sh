#!/bin/bash

# How to use:
# ./make alt example db/1970/unincdb-tutorial/UNINC.toml





(
    echo '\par Business Name:'
    tomlq -r .fullname $toml
    echo '\par President:'
    tomlq -r .president $toml
    echo '\par Secretary:'
    tomlq -r .secretary $toml
) > .workdir/example.data.texpart


(
    echo '\begin{verbatim}'
    echo ./make.sh alt example "$ORGDIR"
    echo '\end{verbatim}'
) > .workdir/example.cmd.texpart

(
    echo '\begin{verbatim}'
    # sed 's/_/\\_/g' <<< "$PDFPATH_DEST"
    echo "$PDFPATH_DEST"
    echo '\end{verbatim}'
) > .workdir/example.pdfpath.texpart
