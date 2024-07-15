#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 coverfile passphrase"
    exit 1
fi

# Assign arguments to variables
coverfile=$1
passphrase=$2

# Create a temporary file to hold the extracted text
tempfile=$(mktemp)

# Get the common steghide password from the encrypted file
steghide_password=$(./encrypt_decrypt.sh -d "$passphrase")
if [ $? -ne 0 ]; then
    echo "Failed to decrypt the steghide password."
    rm "$tempfile"
    exit 1
fi

# Extract the hidden text using Steghide
steghide extract -sf "$coverfile" -xf "$tempfile" -p "$steghide_password"

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

