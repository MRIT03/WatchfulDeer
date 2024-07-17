#!/bin/bash

# Set the base directory
BASE_DIR="$HOME/code/WatchfulDeer"

# File containing the bcrypt hash
HASH_FILE="$BASE_DIR/users"
# Log file to store the last authentication date
AUTH_LOG_FILE="$BASE_DIR/auth.log"

# Function to check if a password matches a hash
check_password() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Error: Please provide both a password and a hash."
        exit 1
    fi

    password="$1"
    hash="$2"

    # Use Python to check if the password matches the hash
    result=$(python3 -c "
import bcrypt

password = '$password'.encode('utf-8')
hash = '$hash'.encode('utf-8')

try:
    if bcrypt.checkpw(password, hash):
        print('The password matches the hash.')
    else:
        print('The password does not match the hash.')
except ValueError:
    print('The hash provided is not valid.')
")

    echo "$result"
}

# Function to check if the user is already authenticated for today
is_authenticated_today() {
    if [ -f "$AUTH_LOG_FILE" ]; then
        last_auth_date=$(cat "$AUTH_LOG_FILE")
        current_date=$(date +%Y-%m-%d)
        if [ "$last_auth_date" == "$current_date" ]; then
            return 0
        fi
    fi
    return 1
}

# Function to prompt for password and authenticate
prompt_for_password() {
    read -sp "Enter your password: " password
    echo
    authenticate "$password"
}

# Function to authenticate with a given password
authenticate() {
    password="$1"

    # Read the hash from the users file
    hash=$(cat "$HASH_FILE")

    # Check the password using check_password function
    result=$(check_password "$password" "$hash")
    if [[ "$result" == *"The password matches the hash."* ]]; then
        echo "Authentication successful."
        # Store the current date in the AUTH_LOG_FILE
        date +%Y-%m-%d > "$AUTH_LOG_FILE"
    else
        echo "Authentication failed."
        exit 1
    fi
}

# Main script logic
case "$1" in
    -c)
        if is_authenticated_today; then
            echo "Already authenticated for today."
            exit 0
        else
            echo "Not authenticated for today."
            exit 1
        fi
        ;;
    -a)
        if [ -n "$2" ]; then
            authenticate "$2"
        else
            prompt_for_password
        fi
        ;;
    *)
        echo "Usage: $0 {-c | -a [passphrase]}"
        exit 1
        ;;
esac

