#!/bin/bash

# Set the base directory of the WatchfulDeer application
WATCHFUL_DEER_DIR="/home/riad/code/WatchfulDeer"

# Set the Rofi theme file path
ROFI_THEME="$HOME/.config/rofi/styles/style_13.rasi"

# Function to check user authentication
check_authentication() {
    authenticated=$("$WATCHFUL_DEER_DIR/authenticate.sh" -c)
    if [ $? -ne 0 ]; then
        passphrase=$(rofi -theme "$ROFI_THEME" -password -dmenu -p "Enter the passphrase:")
        authenticated=$("$WATCHFUL_DEER_DIR/authenticate.sh" -a "$passphrase")
        if [ $? -ne 0 ]; then
            rofi -theme "$ROFI_THEME" -e "Authentication failed."
            exit 1
        else
            rofi -theme "$ROFI_THEME" -e "Authentication successful."
        fi
    fi
}

# Function to manage passwords
manage_password_rofi() {
    option=$1
    case $option in
        -g)
            app_name=$(rofi -theme "$ROFI_THEME" -dmenu -p "Enter the app name:")
            security_level=$(rofi -theme "$ROFI_THEME" -dmenu -p "Enter the security level (1-4):")
            passphrase=$(rofi -theme "$ROFI_THEME" -password -dmenu -p "Enter the passphrase:")
            "$WATCHFUL_DEER_DIR/password_generation.sh" -g "$app_name" "$security_level" "$passphrase"
            ;;
        -a)
            app_name=$(rofi -theme "$ROFI_THEME" -dmenu -p "Enter the app name:")
            password=$(rofi -theme "$ROFI_THEME" -password -dmenu -p "Enter the password:")
            security_level=$(rofi -theme "$ROFI_THEME" -dmenu -p "Enter the security level (1-4):")
            passphrase=$(rofi -theme "$ROFI_THEME" -password -dmenu -p "Enter the passphrase:")
            "$WATCHFUL_DEER_DIR/password_generation.sh" -a "$app_name" "$password" "$security_level" "$passphrase"
            ;;
        -c)
            app_name=$(rofi -theme "$ROFI_THEME" -dmenu -p "Enter the app name:")
            new_password=$(rofi -theme "$ROFI_THEME" -password -dmenu -p "Enter the new password:")
            passphrase=$(rofi -theme "$ROFI_THEME" -password -dmenu -p "Enter the passphrase:")
            "$WATCHFUL_DEER_DIR/password_generation.sh" -c "$app_name" "$new_password" "$passphrase"
            ;;
        -d)
            app_name=$(rofi -theme "$ROFI_THEME" -dmenu -p "Enter the app name:")
            passphrase=$(rofi -theme "$ROFI_THEME" -password -dmenu -p "Enter the passphrase:")
            "$WATCHFUL_DEER_DIR/password_generation.sh" -d "$app_name" "$passphrase"
            ;;
        *)
            rofi -theme "$ROFI_THEME" -e "Invalid option for manage_password."
            exit 1
            ;;
    esac
}

# Function to retrieve password using Rofi
retrieve_password_rofi() {
    app_name=$(rofi -theme "$ROFI_THEME" -dmenu -p "Enter the app name:")
    passphrase=$(rofi -theme "$ROFI_THEME" -password -dmenu -p "Enter the passphrase:")
    "$WATCHFUL_DEER_DIR/extract_password.sh" "$app_name" "$passphrase"
}

# Function to authenticate using Rofi
authenticate_rofi() {
    passphrase=$(rofi -theme "$ROFI_THEME" -password -dmenu -p "Enter the passphrase:")
    authenticated=$("$WATCHFUL_DEER_DIR/authenticate.sh" -a "$passphrase")
    if [ $? -ne 0 ]; then
        rofi -theme "$ROFI_THEME" -e "Authentication failed."
        exit 1
    else
        rofi -theme "$ROFI_THEME" -e "Authentication successful."
    fi
}

# Function to check expiration dates using Rofi
check_expiration_rofi() {
    password_file="$WATCHFUL_DEER_DIR/passwords"
    today=$(date +%Y-%m-%d)
    week_later=$(date -d "$today + 7 days" +%Y-%m-%d)

    expired_apps=()
    expiring_soon_apps=()

    while IFS=, read -r app_name coverfile expiration_date; do
        if [[ "$expiration_date" < "$today" ]]; then
            expired_apps+=("$app_name")
        elif [[ "$expiration_date" < "$week_later" ]]; then
            expiring_soon_apps+=("$app_name")
        fi
    done < "$password_file"

    expired_apps_msg="Expired:\n$(printf "%s\n" "${expired_apps[@]}")"
    expiring_soon_apps_msg="Expiring soon:\n$(printf "%s\n" "${expiring_soon_apps[@]}")"

    if [[ ${#expired_apps[@]} -gt 0 ]]; then
        rofi -theme "$ROFI_THEME" -e "$expired_apps_msg"
    fi

    if [[ ${#expiring_soon_apps[@]} -gt 0 ]]; then
        rofi -theme "$ROFI_THEME" -e "$expiring_soon_apps_msg"
    fi

    echo -e "$expired_apps_msg"
    echo -e "$expiring_soon_apps_msg"
}

# Function to display the main menu with Rofi
rofi_menu() {
    local options="Generate Password\nAdd/Change Password\nChange Existing Password\nDelete Password\nCheck Expirations\nRetrieve Password\nAuthenticate"
    local choice=$(echo -e "$options" | rofi -theme "$ROFI_THEME" -dmenu -p "Select an action:")

    case $choice in
        "Generate Password")
            manage_password_rofi -g
            ;;
        "Add/Change Password")
            manage_password_rofi -a
            ;;
        "Change Existing Password")
            manage_password_rofi -c
            ;;
        "Delete Password")
            manage_password_rofi -d
            ;;
        "Check Expirations")
            check_expiration_rofi
            ;;
        "Retrieve Password")
            retrieve_password_rofi
            ;;
        "Authenticate")
            authenticate_rofi
            ;;
        *)
            rofi -theme "$ROFI_THEME" -e "Invalid option selected."
            exit 1
            ;;
    esac
}

# Ensure the user is authenticated
check_authentication

# Parse command-line options
option=$1
case $option in
    -pg|-gp)
        manage_password -g
        ;;
    -pa|-ap)
        manage_password -a
        ;;
    -pc|-cp)
        manage_password -c
        ;;
    -pd|-dp)
        manage_password -d
        ;;
    -pe|-ep)
        check_expiration
        ;;
    -pr|-rp)
        retrieve_password
        ;;
    -ro)
        rofi_menu
        ;;
    *)
        echo "Usage: $0 {-pg|-gp | -pa|-ap | -pc|-cp | -pd|-dp | -pe|-ep | -pr|-rp | -ro}"
        exit 1
        ;;
esac

