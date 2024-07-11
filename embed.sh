#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 coverfile text"
    exit 1
fi

# Assign arguments to variables
coverfile=$1
secret_text=$2

# Create a temporary file to hold the secret text
tempfile=$(mktemp)

# Write the secret text to the temporary file
echo "$secret_text" > "$tempfile"

# Embed the text into the cover file using Steghide
steghide embed -cf "$coverfile" -ef "$tempfile"

# Confirm the embedding process
if [ $? -eq 0 ]; then
    echo "Text embedded successfully into $coverfile."
else
    echo "Failed to embed text."
fi

# Clean up the temporary file
rm "$tempfile"

