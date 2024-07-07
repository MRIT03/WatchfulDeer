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

app_name=$1
security_level=$2
password=$(tr -dc 'A-Za-z0-9!?%=' < /dev/urandom | head -c 10)
expiration_date=$(generate_expiration_date $security_level)
# Format the output
output="$app_name, $password, $expiration_date"

# Send the output to the expiration tracking script
./track_expirations.sh add "$output"

# Print the generated password and expiration date for confirmation
echo "Generated: $output"




