#!/bin/bash

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
    local picture=$(shuf -n 1 available_pictures)
    echo "$HOME/Pictures/Harhour_and_chase/$picture"
}

# Function to remove a picture from available_pictures
remove_picture_from_list() {
    local picture=$1
    grep -v "^$picture$" available_pictures > available_pictures.tmp
    mv available_pictures.tmp available_pictures
}

# Function to add a picture back to available_pictures
add_picture_to_list() {
    local picture=$1
    echo $picture >> available_pictures
}

# Function to generate a password and embed it in a picture
generate_password() {
    local app_name=$1
    local security_level=$2
    local expiration_date=$(generate_expiration_date $security_level)
    local password=$(generate_random_password)
    local picture=$(get_random_picture)
    local embed_password=$(generate_random_password) # Password for embedding

    # Embed the password in the picture using the embed_password
    ./embed.sh $picture "$password" "$embed_password"
    if [ $? -eq 0 ]; then
        # Remove the used picture from the list
        remove_picture_from_list "$picture"
        # Output the result
        local output="$app_name:$picture:$expiration_date:$embed_password"
        echo "$output" >> passwords.txt
        # Send the result to track_expirations.sh
        ./track_expirations.sh add "$output"
        echo "Generated: $output"
    else
        echo "Failed to embed password in picture."
        exit 1
    fi
}

# Function to change an existing password
change_password() {
    local app_name=$1
    local new_password=$2
    local entry=$(grep "^$app_name:" passwords.txt)
    if [ -z "$entry" ]; then
        echo "App name not found."
        exit 1
    fi

    local picture=$(echo $entry | cut -d':' -f2)
    local expiration_date=$(echo $entry | cut -d':' -f3)
    local embed_password=$(echo $entry | cut -d':' -f4)

    # Extract the old password
    ./extract.sh "$picture" "$embed_password"

    # Add the picture back to the available list
    add_picture_to_list "$picture"

    # Generate new password and embed it in a picture
    generate_password "$app_name" "$new_password"
}

# Function to delete an entry
delete_entry() {
    local app_name=$1
    local entry=$(grep "^$app_name:" passwords.txt)
    if [ -z "$entry" ]; then
        echo "App name not found."
        exit 1
    fi

    local picture=$(echo $entry | cut -d':' -f2)
    local embed_password=$(echo $entry | cut -d':' -f4)

    # Extract the old password
    ./extract.sh "$picture" "$embed_password"

    # Add the picture back to the available list
    add_picture_to_list "$picture"

    # Remove the entry from passwords.txt
    grep -v "^$app_name:" passwords.txt > passwords.tmp
    mv passwords.tmp passwords.txt
}

# Main script logic
case "$1" in
    -g)
        if [ "$#" -ne 3 ]; then
            echo "Usage: $0 -g app_name security_level"
            exit 1
        fi
        generate_password "$2" "$3"
        ;;
    -c)
        if [ "$#" -ne 3 ]; then
            echo "Usage: $0 -c app_name new_password"
            exit 1
        fi
        change_password "$2" "$3"
        ;;
    -d)
        if [ "$#" -ne 2 ]; then
            echo "Usage: $0 -d app_name"
            exit 1
        fi
        delete_entry "$2"
        ;;
    *)
        echo "Usage: $0 {-g app_name security_level | -c app_name new_password | -d app_name}"
        exit 1
        ;;
esac

