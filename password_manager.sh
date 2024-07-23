#!/bin/bash

# Set the base directory of the WatchfulDeer application
WATCHFUL_DEER_DIR="/home/riad/code/WatchfulDeer"

# Set the Rofi theme file path
ROFI_THEME="$HOME/.config/rofi/styles/style_13.rasi"
USE_ROFI=false

# Function to display messages (using Rofi if enabled)
display_message() {
    if $USE_ROFI; then
        rofi -theme "$ROFI_THEME" -e "$1"
    else
        echo "$1"
    fi
}

# Function to display input prompt (using Rofi if enabled)
prompt_input() {
    local prompt="$1"
    if $USE_ROFI; then
        rofi -theme "$ROFI_THEME" -dmenu -p "$prompt"
    else
        read -p "$prompt" input
        echo "$input"
    fi
}

# Function to display password prompt (using Rofi if enabled)
prompt_password() {
    local prompt="$1"
    if $USE_ROFI; then
        rofi -theme "$ROFI_THEME" -password -dmenu -p "$prompt"
    else
        read -sp "$prompt" input
        echo "$input"
    fi
}

# Function to check user authentication
check_authentication() {
    authenticated=$("$WATCHFUL_DEER_DIR/authenticate.sh" -c)
    if [ $? -ne 0 ]; then
        if $USE_ROFI; then
            authenticate_rofi
        else
            passphrase=$(prompt_password "Enter the passphrase:")
            authenticated=$("$WATCHFUL_DEER_DIR/authenticate.sh" -a "$passphrase")
            if [ $? -ne 0 ]; then
                display_message "Authentication failed."
                exit 1
            else
                display_message "Authentication successful."
            fi
        fi
    fi
}

# Function to manage passwords
manage_password() {
    option=$1
    case $option in
        -g)
            app_name=$(prompt_input "Enter the app name:")
            user_name=$(prompt_input "Enter the user name:")
            security_level=$(prompt_input "Enter the security level (1-4):")
            passphrase=$(prompt_password "Enter the passphrase:")
            result=$("$WATCHFUL_DEER_DIR/password_generation.sh" -g "$app_name" "$user_name" "$security_level" "$passphrase")
            display_message "$result"
            ;;
        -a)
            app_name=$(prompt_input "Enter the app name:")
            user_name=$(prompt_input "Enter the user name:")
            password=$(prompt_password "Enter the password:")
            security_level=$(prompt_input "Enter the security level (1-4):")
            passphrase=$(prompt_password "Enter the passphrase:")
            result=$("$WATCHFUL_DEER_DIR/password_generation.sh" -a "$app_name" "$user_name" "$password" "$security_level" "$passphrase")
            display_message "$result"
            ;;
        -c)
            app_name=$(prompt_input "Enter the app name:")
            user_name=$(prompt_input "Enter the user name:")
            new_password=$(prompt_password "Enter the new password:")
            passphrase=$(prompt_password "Enter the passphrase:")
            result=$("$WATCHFUL_DEER_DIR/password_generation.sh" -c "$app_name" "$user_name" "$new_password" "$passphrase")
            display_message "$result"
            ;;
        -d)
            app_name=$(prompt_input "Enter the app name:")
            user_name=$(prompt_input "Enter the user name:")
            passphrase=$(prompt_password "Enter the passphrase:")
            result=$("$WATCHFUL_DEER_DIR/password_generation.sh" -d "$app_name" "$user_name" "$passphrase")
            display_message "$result"
            ;;
        *)
            display_message "Invalid option for manage_password."
            exit 1
            ;;
    esac
}

# Function to retrieve password using Rofi
retrieve_password_rofi() {
    app_name=$(prompt_input "Enter the app name:")
    user_name=$(prompt_input "Enter the user name:")
    passphrase=$(prompt_password "Enter the passphrase:")
    result=$("$WATCHFUL_DEER_DIR/extract_password.sh" "$app_name" "$user_name" "$passphrase" -c)
    display_message "$result"
}

# Function to authenticate using Rofi
authenticate_rofi() {
    passphrase=$(prompt_password "Enter the passphrase:")
    authenticated=$("$WATCHFUL_DEER_DIR/authenticate.sh" -a "$passphrase")
    if [ $? -ne 0 ]; then
        display_message "Authentication failed."
        exit 1
    else
        display_message "Authentication successful."
    fi
}

# Function to check expiration dates using Rofi
check_expiration_rofi() {
    password_file="$WATCHFUL_DEER_DIR/passwords"
    today=$(date +%Y-%m-%d)
    week_later=$(date -d "$today + 7 days" +%Y-%m-%d)

    expired_apps=()
    expiring_soon_apps=()

    while IFS=, read -r app_name user_name coverfile expiration_date; do
        if [[ "$expiration_date" < "$today" ]]; then
            expired_apps+=("$app_name:$user_name")
        elif [[ "$expiration_date" < "$week_later" ]]; then
            expiring_soon_apps+=("$app_name:$user_name")
        fi
    done < "$password_file"

    expired_apps_msg="Expired:\n$(printf "%s\n" "${expired_apps[@]}")"
    expiring_soon_apps_msg="Expiring soon:\n$(printf "%s\n" "${expiring_soon_apps[@]}")"

    if [[ ${#expired_apps[@]} -gt 0 ]]; then
        display_message "$expired_apps_msg"
    fi

    if [[ ${#expiring_soon_apps[@]} -gt 0 ]]; then
        display_message "$expiring_soon_apps_msg"
    fi

    echo -e "$expired_apps_msg"
    echo -e "$expiring_soon_apps_msg"
}

# Function to display the main menu with Rofi
rofi_menu() {
    check_authentication
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
            display_message "Invalid option selected."
            exit 1
            ;;
    esac
}

# Function to manage passwords using Rofi
manage_password_rofi() {
    option=$1
    case $option in
        -g)
            app_name=$(prompt_input "Enter the app name:")
            user_name=$(prompt_input "Enter the user name:")
            security_level=$(prompt_input "Enter the security level (1-4):")
            passphrase=$(prompt_password "Enter the passphrase:")
            "$WATCHFUL_DEER_DIR/password_generation.sh" -g "$app_name" "$user_name" "$security_level" "$passphrase"
            if [ $? -ne 0 ]; then
                display_message "Failed to generate password. Incorrect passphrase."
                exit 1
            fi
            ;;
        -a)
            app_name=$(prompt_input "Enter the app name:")
            user_name=$(prompt_input "Enter the user name:")
            password=$(prompt_password "Enter the password:")
            security_level=$(prompt_input "Enter the security level (1-4):")
            passphrase=$(prompt_password "Enter the passphrase:")
            result=$("$WATCHFUL_DEER_DIR/password_generation.sh" -a "$app_name" "$user_name" "$password" "$security_level" "$passphrase")
            display_message "$result"
            ;;
        -c)
            app_name=$(prompt_input "Enter the app name:")
            user_name=$(prompt_input "Enter the user name:")
            new_password=$(prompt_password "Enter the new password:")
            passphrase=$(prompt_password "Enter the passphrase:")
            result=$("$WATCHFUL_DEER_DIR/password_generation.sh" -c "$app_name" "$user_name" "$new_password" "$passphrase")
            display_message "$result"
            ;;
        -d)
            app_name=$(prompt_input "Enter the app name:")
            user_name=$(prompt_input "Enter the user name:")
            passphrase=$(prompt_password "Enter the passphrase:")
            result=$("$WATCHFUL_DEER_DIR/password_generation.sh" -d "$app_name" "$user_name" "$passphrase")
            display_message "$result"
            ;;
        *)
            display_message "Invalid option for manage_password_rofi."
            exit 1
            ;;
    esac
}

# Parse command-line options
option=$1
case $option in
    -pg|-gp)
        check_authentication
        manage_password -g
        ;;
    -pa|-ap)
        check_authentication
        manage_password -a
        ;;
    -pc|-cp)
        check_authentication
        manage_password -c
        ;;
    -pd|-dp)
        check_authentication
        manage_password -d
        ;;
    -pe|-ep)
        check_authentication
        check_expiration
        ;;
    -pr|-rp)
        check_authentication
        retrieve_password
        ;;
    -ro)
        USE_ROFI=true
        rofi_menu
        ;;
    *)
        echo "Usage: $0 {-pg|-gp | -pa|-ap | -pc|-cp | -pd|-dp | -pe|-ep | -pr|-rp | -ro}"
        exit 1
        ;;
esac

