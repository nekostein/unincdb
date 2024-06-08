#!/bin/bash

### Copyright (c) 2024 Neruthes. Published with the MIT license.


# Check if the input file path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <input_file_path>"
    exit 1
fi

input_path="$1"
ORGDIR="$(dirname "$input_path")"

new_path="_dist/www/$OFFICE/$ORGDIR.pdf"

hook_sh="authorities/$OFFICE/hooks/calcrealpdfpath.sh"

if [[ -e "$hook_sh" ]]; then
    # echo "($0) debug: new_path=$new_path" > /dev/stderr # Uncomment when debugging
    bash "$hook_sh" "$ORGDIR"
else
    echo "$new_path"
fi
