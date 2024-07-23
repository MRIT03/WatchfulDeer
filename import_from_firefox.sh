#!/bin/bash

# Set the base directories
BASE_DIR="$HOME/code/WatchfulDeer"
CSV_FILE=$1
PASSPHRASE=$2

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 path_to_csv passphrase"
    exit 1
fi

# Function to read the common steghide password
read_steghide_password() {
    passphrase=$1
    password=$("$BASE_DIR/encrypt_decrypt.sh" -d "$passphrase")
    if [ $? -ne 0 ]; then
        echo "Failed to decrypt the steghide password."
        exit 1
    fi
    echo "$password"
}

# Read the steghide password
steghide_password=$(read_steghide_password "$PASSPHRASE")

# Parse the CSV file and add each entry
while IFS=, read -r hostname username password formSubmitURL; do
    if [ "$hostname" != "hostname" ]; then
        # Remove the "http://" or "https://" from the hostname
        app_name=$(echo "$hostname" | sed -E 's/https?:\/\///')
        
        # Generate expiration date based on a default security level
        security_level=2

        # Add the password to the system
        "$BASE_DIR/password_generation.sh" -a "$app_name" "$username" "$password" "$security_level" "$PASSPHRASE"
    fi
done < "$CSV_FILE"

echo "Passwords imported successfully."

