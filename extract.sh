#!/bin/bash

# Prompt the user for input
echo "Enter the cover file (e.g., coverfile.jpg):"
read coverfile

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

