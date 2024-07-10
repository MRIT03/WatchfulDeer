#!/bin/bash

# Function to hash a password
hash_password() {
    if [ -z "$1" ]; then
        read -sp "Enter the password to hash: " password
        echo
    else
        password="$1"
    fi

    # Use Python to hash the password using bcrypt
    hashed_password=$(python3 -c "
import bcrypt
password = '$password'.encode('utf-8')
hashed = bcrypt.hashpw(password, bcrypt.gensalt())
print(hashed.decode('utf-8'))
")

    # Display the hashed password
    echo "Hashed password: $hashed_password"
}

# Function to check if a password matches a hash
check_password() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Error: Please provide both a password and a hash."
        exit 1
    fi

    password="$1"
    hash="$2"
    echo $password
    echo $hash
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

    # Display the result
    echo "$result"
}

# Main script logic
if [ "$1" == "-h" ]; then
    hash_password "$2"
elif [ "$1" == "-c" ]; then
    check_password "$2" "$3"
else
    echo "Usage: $0 [-h password | -c password hash]"
    echo "  -h  Hash a password"
    echo "  -c  Check if a password matches a hash"
fi

