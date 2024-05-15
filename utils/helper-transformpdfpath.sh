#!/bin/bash

# Check if the input file path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <input_file_path>"
    exit 1
fi

# Parse Word1 and Word2 from the input file path
input_path=$1
Word1=$(dirname "$input_path")
Word2=$(basename "$input_path" | sed 's/^Witness-//' | sed 's/\.pdf$//')

# Construct the new file path
new_path="_dist/$Word2/$Word1.pdf"

echo "$new_path"
