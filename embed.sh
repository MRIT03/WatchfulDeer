#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 coverfile text password"
    exit 1
fi

# Assign arguments to variables
coverfile=$1
secret_text=$2
password=$3
# Check if the cover file exists
if [ ! -f "$coverfile" ]; then
    echo "The cover file '$coverfile' does not exist."
    exit 1
fi
# Create a temporary file to hold the secret text
tempfile=$(mktemp)

# Write the secret text to the temporary file
echo "$secret_text" > "$tempfile"

# Embed the text into the cover file using Steghide
steghide embed -cf "$coverfile" -ef "$tempfile" -p "Riad"

# Confirm the embedding process
if [ $? -eq 0 ]; then
    echo "Text embedded successfully into $coverfile."
else
    echo "Failed to embed text."
fi

# Clean up the temporary file
rm "$tempfile"

