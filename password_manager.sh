#!/bin/bash

# Function to check user authentication
check_authentication() {
    authenticated=$(./authenticate.sh -c)
    if [ $? -ne 0 ]; then
        echo "Authentication required. Please authenticate."
        ./authenticate.sh -a
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
            ./password_generation.sh -g "$app_name" "$security_level" "$passphrase"
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
            ./password_generation.sh -a "$app_name" "$password" "$security_level" "$passphrase"
            ;;
        -c)
            echo "Enter the app name:"
            read app_name
            echo "Enter the new password:"
            read -s new_password
            echo "Enter the passphrase:"
            read -s passphrase
            ./password_generation.sh -c "$app_name" "$new_password" "$passphrase"
            ;;
        -d)
            echo "Enter the app name:"
            read app_name
            echo "Enter the passphrase:"
            read -s passphrase
            ./password_generation.sh -d "$app_name" "$passphrase"
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
    ./extract_password.sh "$app_name" "$passphrase"
}

# Function to check expiration dates
check_expiration() {
    ./track_expirations.sh
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
    *)
        echo "Usage: $0 {-pg|-gp | -pa|-ap | -pc|-cp | -pd|-dp | -pe|-ep | -pr|-rp}"
        exit 1
        ;;
esac

