#!/bin/bash

ORGDIR="$1"

regno="$(grep "^$ORGDIR;" "authorities/$OFFICE/witnesslist.txt" | cut -d';' -f2)"

echo -n "_dist/www/$OFFICE/id/$regno.pdf"
