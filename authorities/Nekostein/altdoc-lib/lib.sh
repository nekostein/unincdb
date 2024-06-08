#!/bin/bash

function get_regno() {
    ORGDIR="$1"
    outpath="$2"
    regno="N/A"
    regno_candidate="$(grep "^$ORGDIR;" "authorities/$OFFICE/witnesslist.txt" | cut -d';' -f2)"
    if [[ -n "$regno_candidate" ]]; then
        regno="$regno_candidate"
    fi
    pdfurl_prefix="https://unincdb.nekostein.com/id/$regno"
    regnourlhref='\href'"{$pdfurl_prefix.pdf}{$pdfurl_prefix.pdf}"
    (
        printf '\\providecommand{\\unincregno}[0]{%s}\n' "$regno"
        printf '\\providecommand{\\unincregnohref}[0]{%s}\n' "$regnourlhref"
    ) > "$outpath"
}
