#!/bin/bash

# Set the base directory
BASE_DIR="$HOME/code/WatchfulDeer"

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 coverfile text passphrase"
    exit 1
fi

# Assign arguments to variables
coverfile=$1
secret_text=$2
passphrase=$3

# Create a temporary file to hold the secret text
tempfile=$(mktemp)

# Write the secret text to the temporary file
echo "$secret_text" > "$tempfile"

# Get the common steghide password from the encrypted file
#steghide_password=$("$BASE_DIR/encrypt_decrypt.sh" -d "$passphrase")
#if [ $? -ne 0 ]; then
#   echo "Failed to decrypt the steghide password."
#    rm "$tempfile"
#    exit 1
#fi

# Embed the text into the cover file using Steghide
steghide embed -cf "$coverfile" -ef "$tempfile" -p "$passphrase"
echo "the text was embedded with the following password: $passphrase"
# Confirm the embedding process
if [ $? -eq 0 ]; then
    echo "Text embedded successfully into $coverfile."
else
    echo "Failed to embed text."
fi

# Clean up the temporary file
rm "$tempfile"

