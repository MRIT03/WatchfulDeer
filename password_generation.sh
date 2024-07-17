#!/bin/bash

# Set the base directories
BASE_DIR="$HOME/code/WatchfulDeer"
PICTURES_DIR="$HOME/Pictures/Harhour_and_chase"

# Function to generate an expiration date based on security level
generate_expiration_date() {
    case $1 in
        1) days="+60 days" ;;
        2) days="+90 days" ;;
        3) days="+180 days" ;; # 6 months
        4) days="+270 days" ;; # 9 months
        *) echo "Invalid security level"; exit 1 ;;
    esac
    date -d "$days" +"%Y-%m-%d"
}

# Function to generate a random password
generate_random_password() {
    tr -dc 'A-Za-z0-9!?%=' < /dev/urandom | head -c 10
}

# Function to get a random picture from available_pictures
get_random_picture() {
    local picture=$(shuf -n 1 "$BASE_DIR/available_pictures")
    echo "$PICTURES_DIR/$picture"
}

# Function to remove a picture from available_pictures
remove_picture_from_list() {
    local picture=$1
    grep -v "^$picture$" "$BASE_DIR/available_pictures" > "$BASE_DIR/available_pictures.tmp"
    mv "$BASE_DIR/available_pictures.tmp" "$BASE_DIR/available_pictures"
}

# Function to add a picture back to available_pictures
add_picture_to_list() {
    local picture=$1
    echo $picture >> "$BASE_DIR/available_pictures"
}

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

# Function to generate a password and embed it in a picture
generate_password() {
    local app_name=$1
    local security_level=$2
    local passphrase=$3
    local expiration_date=$(generate_expiration_date $security_level)
    local password=$(generate_random_password)
    local picture=$(get_random_picture)
    local embed_password=$(read_steghide_password "$passphrase") # Use the decrypted steghide password

    # Check if an entry already exists for the app name
    local entry=$(grep "^$app_name:" "$BASE_DIR/passwords")
    if [ -n "$entry" ]; then
        local old_picture=$(echo $entry | cut -d':' -f2)
        # Add the old picture back to the available list
        add_picture_to_list "$old_picture"
        # Remove the old entry
        grep -v "^$app_name:" "$BASE_DIR/passwords" > "$BASE_DIR/passwords.tmp"
        mv "$BASE_DIR/passwords.tmp" "$BASE_DIR/passwords"
    fi

    # Embed the password in the picture using the embed_password
    "$BASE_DIR/embed.sh" "$picture" "$password" "$embed_password"
    if [ $? -eq 0 ]; then
        # Remove the used picture from the list
        remove_picture_from_list "$(basename $picture)"
        # Output the result
        local output="$app_name:$(basename $picture):$expiration_date"
        echo "$output" >> "$BASE_DIR/passwords"
        # Send the result to track_expirations.sh
        "$BASE_DIR/track_expirations.sh" add "$output"
        echo "Generated: $output"
    else
        echo "Failed to embed password in picture."
        exit 1
    fi
}

# Function to add or change a password
add_or_change_password() {
    local app_name=$1
    local password=$2
    local security_level=$3
    local passphrase=$4
    local expiration_date=$(generate_expiration_date $security_level)
    local picture=$(get_random_picture)
    local embed_password=$(read_steghide_password "$passphrase") # Use the decrypted steghide password

    # Check if an entry already exists for the app name
    local entry=$(grep "^$app_name:" "$BASE_DIR/passwords")
    if [ -n "$entry" ]; then
        local old_picture=$(echo $entry | cut -d':' -f2)
        # Add the old picture back to the available list
        add_picture_to_list "$old_picture"
        # Remove the old entry
        grep -v "^$app_name:" "$BASE_DIR/passwords" > "$BASE_DIR/passwords.tmp"
        mv "$BASE_DIR/passwords.tmp" "$BASE_DIR/passwords"
    fi

    # Embed the password in the picture using the embed_password
    "$BASE_DIR/embed.sh" "$picture" "$password" "$embed_password"
    if [ $? -eq 0 ]; then
        # Remove the used picture from the list
        remove_picture_from_list "$(basename $picture)"
        # Output the result
        local output="$app_name:$(basename $picture):$expiration_date"
        echo "$output" >> "$BASE_DIR/passwords"
        # Send the result to track_expirations.sh
        "$BASE_DIR/track_expirations.sh" add "$output"
        echo "Added/Changed: $output"
    else
        echo "Failed to embed password in picture."
        exit 1
    fi
}

# Function to change an existing password
change_password() {
    local app_name=$1
    local new_password=$2
    local passphrase=$3
    local entry=$(grep "^$app_name:" "$BASE_DIR/passwords")
    if [ -z "$entry" ]; then
        echo "App name not found."
        exit 1
    fi

    local picture=$(echo $entry | cut -d':' -f2)
    local embed_password=$(read_steghide_password "$passphrase") # Use the decrypted steghide password

    # Extract the old password
    "$BASE_DIR/extract.sh" "$PICTURES_DIR/$picture" "$embed_password"

    # Add the picture back to the available list
    add_picture_to_list "$picture"

    # Generate new password and embed it in a picture
    generate_password "$app_name" "$new_password" "$passphrase"
}

# Function to delete an entry
delete_entry() {
    local app_name=$1
    local passphrase=$2
    local entry=$(grep "^$app_name:" "$BASE_DIR/passwords")
    if [ -z "$entry" ]; then
        echo "App name not found."
        exit 1
    fi

    local picture=$(echo $entry | cut -d':' -f2)

    # Add the picture back to the available list
    add_picture_to_list "$picture"

    # Remove the entry from passwords
    grep -v "^$app_name:" "$BASE_DIR/passwords" > "$BASE_DIR/passwords.tmp"
    mv "$BASE_DIR/passwords.tmp" "$BASE_DIR/passwords"
}

# Main script logic
case "$1" in
    -g)
        if [ "$#" -ne 4 ]; then
            echo "Usage: $0 -g app_name security_level passphrase"
            exit 1
        fi
        generate_password "$2" "$3" "$4"
        ;;
    -a)
        if [ "$#" -ne 5 ]; then
            echo "Usage: $0 -a app_name password security_level passphrase"
            exit 1
        fi
        add_or_change_password "$2" "$3" "$4" "$5"
        ;;
    -c)
        if [ "$#" -ne 4 ]; then
            echo "Usage: $0 -c app_name new_password passphrase"
            exit 1
        fi
        change_password "$2" "$3" "$4"
        ;;
    -d)
        if [ "$#" -ne 3 ]; then
            echo "Usage: $0 -d app_name passphrase"
            exit 1
        fi
        delete_entry "$2" "$3"
        ;;
    *)
        echo "Usage: $0 {-g app_name security_level passphrase | -a app_name password security_level passphrase | -c app_name new_password passphrase | -d app_name passphrase}"
        exit 1
        ;;
esac

