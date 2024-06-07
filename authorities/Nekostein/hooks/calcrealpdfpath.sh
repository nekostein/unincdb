#!/bin/bash

ORGDIR="$1"

touch db-private/witnesslist.txt
regno="$(grep "$ORGDIR" "authorities/$OFFICE/witnesslist.txt" db-private/witnesslist.txt | cut -d';' -f2)"

echo -n "_dist/www/$OFFICE/id/$regno.pdf"
