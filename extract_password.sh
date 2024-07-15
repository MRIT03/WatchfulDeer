#!/bin/bash

# Path to the password list file
password_file="passwords"

# Function to initialize the password file if it doesn't exist
initialize_file() {
    if [[ ! -f $password_file ]]; then
        touch $password_file
    fi
}

# Function to extract the password for a given application
extract_password() {
    initialize_file

    local app_name="$1"
    local app_name_lower=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | xargs)

    # Find the entry in the passwords file
    local entry=$(grep -i "^$app_name_lower:" $password_file)

    if [[ -z "$entry" ]]; then
        echo "Application '$app_name' not found in the passwords file."
        exit 1
    fi

    # Extract the file and expiration date from the entry
    local file_where_password_is_stored=$(echo "$entry" | cut -d':' -f2)
    local expiration_date=$(echo "$entry" | cut -d':' -f3)

    # Prompt the user for the steghide password
    read -sp "Enter the steghide password for $file_where_password_is_stored: " steghide_password

    # Extract the password using extract.sh
    extracted_password=$(./extract.sh "$HOME/Pictures/Harhour_and_chase/$file_where_password_is_stored" "$steghide_password")

    if [[ $? -eq 0 ]]; then
        echo "Extracted password for '$app_name': $extracted_password"
    else
        echo "Failed to extract the password. Please check the steghide password and try again."
        exit 1
    fi
}

# Main script logic
if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 app_name"
    exit 1
fi

extract_password "$1"

