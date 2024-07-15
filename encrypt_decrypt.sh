#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 -e|-d passphrase"
    exit 1
fi

option=$1
passphrase=$2
input_file="steghide.enc"
output_file="steghide"

case $option in
    -e)
        # Encrypt the file
        if [ -f "$output_file" ]; then
            openssl enc -aes-256-cbc -salt -in "$output_file" -out "$input_file" -pass pass:"$passphrase" -pbkdf2
            if [ $? -eq 0 ]; then
                echo "File encrypted successfully."
                rm "$output_file"  # Remove the plaintext file
            else
                echo "Failed to encrypt the file."
            fi
        else
            echo "No file named $output_file found to encrypt."
        fi
        ;;
    -d)
        # Decrypt the file
        if [ -f "$input_file" ]; then
            openssl enc -d -aes-256-cbc -in "$input_file" -out "$output_file" -pass pass:"$passphrase" -pbkdf2
            if [ $? -eq 0 ]; then
                cat "$output_file"  # Output the decrypted password
                rm "$output_file"  # Remove the plaintext file
            else
                echo "Failed to decrypt the file."
            fi
        else
            echo "No file named $input_file found to decrypt."
        fi
        ;;
    *)
        echo "Invalid option. Use -e to encrypt or -d to decrypt."
        exit 1
        ;;
esac

