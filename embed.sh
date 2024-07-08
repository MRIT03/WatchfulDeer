#!/bin/bash

# Prompt the user for input
echo "Enter the cover file (e.g., coverfile.jpg):"
read coverfile

echo "Enter the text you want to embed:"
read secret_text

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

