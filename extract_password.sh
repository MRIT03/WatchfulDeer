#!/bin/bash

# Set the base directory
BASE_DIR="$HOME/code/WatchfulDeer"
PICTURES_DIR="$HOME/Pictures/Harhour_and_chase"

# Check if the correct number of arguments is provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 app_name user_name passphrase [-c]"
    exit 1
fi

# Assign arguments to variables
app_name=$1
user_name=$2
passphrase=$3
copy_to_clipboard=false

if [ "$#" -eq 4 ] && [ "$4" == "-c" ]; then
    copy_to_clipboard=true
fi

# Find the cover file associated with the app name and user name
entry=$(grep "^$app_name:$user_name:" "$BASE_DIR/passwords")
if [ -z "$entry" ]; then
    echo "App name and user name not found."
    exit 1
fi

coverfile=$(echo $entry | cut -d':' -f3)
if [ -z "$coverfile" ]; then
    echo "Cover file not found for app name $app_name and user name $user_name."
    exit 1
fi

coverfile_path="$PICTURES_DIR/$coverfile"

# Check if the cover file exists
if [ ! -f "$coverfile_path" ]; then
    echo "Cover file '$coverfile_path' does not exist."
    exit 1
fi

# Create a temporary file to hold the extracted text
tempfile=$(mktemp)

# Get the common steghide password from the encrypted file
steghide_password=$("$BASE_DIR/encrypt_decrypt.sh" -d "$passphrase")
if [ $? -ne 0 ]; then
    echo "Failed to decrypt the steghide password."
    rm "$tempfile"
    exit 1
fi

# Extract the hidden text using Steghide
steghide extract -sf "$coverfile_path" -xf "$tempfile" -p "$steghide_password" -f

# Confirm the extraction process
if [ $? -eq 0 ]; then
    echo "Text extracted successfully."
    extracted_text=$(cat "$tempfile")
    echo "Extracted text: $extracted_text"
    combined_text="Username: $user_name\nPassword: $extracted_text"
    
    if $copy_to_clipboard; then
        echo -e "$combined_text" | wl-copy
        echo "Text copied to clipboard."
    else
        echo -e "$combined_text"
    fi
else
    echo "Failed to extract text from '$coverfile'."
fi
# Clean up the temporary file
rm "$tempfile"

