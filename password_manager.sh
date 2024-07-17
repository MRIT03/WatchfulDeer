#!/bin/bash

# Set the base directory of the WatchfulDeer application
WATCHFUL_DEER_DIR="/home/riad/code/WatchfulDeer"

# Set the Rofi theme file path
ROFI_THEME="$HOME/.config/rofi/styles/style_13.rasi"

# Function to check user authentication
check_authentication() {
    authenticated=$("$WATCHFUL_DEER_DIR/authenticate.sh" -c)
    if [ $? -ne 0 ]; then
        echo "Authentication required. Please authenticate."
        "$WATCHFUL_DEER_DIR/authenticate.sh" -a
        if [ $? -ne 0 ]; then
            echo "Authentication failed. Exiting."
            exit 1
        fi
    fi
}

# Function to manage passwords
manage_password() {
    option=$1
    case $option in
        -g)
            echo "Enter the app name:"
            read app_name
            echo "Enter the security level (1-4):"
            read security_level
            echo "Enter the passphrase:"
            read -s passphrase
            "$WATCHFUL_DEER_DIR/password_generation.sh" -g "$app_name" "$security_level" "$passphrase"
            ;;
        -a)
            echo "Enter the app name:"
            read app_name
            echo "Enter the password:"
            read -s password
            echo "Enter the security level (1-4):"
            read security_level
            echo "Enter the passphrase:"
            read -s passphrase
            "$WATCHFUL_DEER_DIR/password_generation.sh" -a "$app_name" "$password" "$security_level" "$passphrase"
            ;;
        -c)
            echo "Enter the app name:"
            read app_name
            echo "Enter the new password:"
            read -s new_password
            echo "Enter the passphrase:"
            read -s passphrase
            "$WATCHFUL_DEER_DIR/password_generation.sh" -c "$app_name" "$new_password" "$passphrase"
            ;;
        -d)
            echo "Enter the app name:"
            read app_name
            echo "Enter the passphrase:"
            read -s passphrase
            "$WATCHFUL_DEER_DIR/password_generation.sh" -d "$app_name" "$passphrase"
            ;;
        *)
            echo "Invalid option for manage_password."
            exit 1
            ;;
    esac
}

# Function to retrieve password
retrieve_password() {
    echo "Enter the app name:"
    read app_name
    echo "Enter the passphrase:"
    read -s passphrase
    "$WATCHFUL_DEER_DIR/extract_password.sh" "$app_name" "$passphrase"
}

# Function to check expiration dates
check_expiration() {
    "$WATCHFUL_DEER_DIR/track_expirations.sh"
}

# Function to display the main menu with Rofi
rofi_menu() {
    local options="Generate Password\nAdd/Change Password\nChange Existing Password\nDelete Password\nCheck Expirations\nRetrieve Password"
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
            check_expiration
            ;;
        "Retrieve Password")
            retrieve_password_rofi
            ;;
        *)
            echo "Invalid option selected."
            exit 1
            ;;
    esac
}

# Function to manage passwords using Rofi
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
            echo "Invalid option for manage_password_rofi."
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

