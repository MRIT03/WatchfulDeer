#!/bin/bash

# Path to store the password list
password_file="passwords"

# Function to initialize the password file if it doesn't exist
initialize_file() {
    if [[ ! -f $password_file ]]; then
        touch $password_file
    fi
}

# Function to sort passwords by expiration date
sort_passwords() {
    sort -t, -k3 $password_file -o $password_file
}

# Function to add or update a password entry
add_password() {
    initialize_file

    local new_entry="$1"
    local app_name=$(echo "$new_entry" | awk -F, '{print $1}' | xargs | tr '[:upper:]' '[:lower:]')
    local file_where_password_is_stored=$(echo "$new_entry" | awk -F, '{print $2}' | xargs)
    local expiration_date=$(echo "$new_entry" | awk -F, '{print $3}' | xargs)

    # Check if the app already exists (case insensitive)
    local existing_entry=$(grep -i "^$app_name," $password_file)

    if [[ -n "$existing_entry" ]]; then
        # Update the existing entry
        sed -i "s/^$app_name,.*/$new_entry/I" $password_file
        echo "Updated: $new_entry"
    else
        # Add the new entry
        echo "$new_entry" >> $password_file
        echo "Added: $new_entry"
    fi

    # Sort the passwords by expiration date
    sort_passwords
}

# Function to check and remove expired passwords
check_expirations() {
    today=$(date +%Y-%m-%d)
    week_later=$(date -d "$today + 7 days" +%Y-%m-%d)
    
    expired_apps=()
    expiring_soon_apps=()

    while IFS=: read -r app_name coverfile expiration_date; do
        if [[ "$expiration_date" < "$today" ]]; then
            expired_apps+=("$app_name")
        elif [[ "$expiration_date" < "$week_later" ]]; then
            expiring_soon_apps+=("$app_name")
        fi
    done < passwords

    if [[ ${#expired_apps[@]} -gt 0 ]]; then
        notify-send "Expired Passwords" "The following passwords have expired: ${expired_apps[*]}"
    fi

    if [[ ${#expiring_soon_apps[@]} -gt 0 ]]; then
        notify-send "Expiring Soon Passwords" "The following passwords will expire within a week: ${expiring_soon_apps[*]}"
    fi

    echo "Expired: ${expired_apps[*]}"
    echo "Expiring soon: ${expiring_soon_apps[*]}"
}
# Main logic
case "$1" in
    add)
        add_password "$2"
        ;;
    check)
        check_expirations
        ;;
    *)
        echo "Usage: $0 {add|check} [password_info]"
        exit 1
        ;;
esac

