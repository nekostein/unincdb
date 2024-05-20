#!/bin/bash

### Copyright (c) 2024 Neruthes. Published with the MIT license.


# Check if the input file path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <input_file_path>"
    exit 1
fi

# Parse Word1 and Word2 from the input file path
input_path=$1
Word1="$(dirname "$input_path" | cut -d/ -f2-)"
Word2="$(basename "$input_path" | sed 's/^witness-//' | sed 's/\.pdf$//')"

# Construct the new file path
new_path="_dist/www/$Word2/$Word1.pdf"

echo "$new_path"
