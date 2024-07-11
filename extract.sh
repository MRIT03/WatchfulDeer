#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 coverfile"
    exit 1
fi

# Assign arguments to variables
coverfile=$1

# Create a temporary file to hold the extracted text
tempfile=$(mktemp)

# Extract the hidden text using Steghide
steghide extract -sf "$coverfile" -xf "$tempfile"

# Confirm the extraction process
if [ $? -eq 0 ]; then
    echo "Text extracted successfully."
    echo "Extracted text:"
    cat "$tempfile"
else
    echo "Failed to extract text."
fi

# Clean up the temporary file
rm "$tempfile"

