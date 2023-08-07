#!/bin/bash

# Check if a file name is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

# Check if the provided file exists
if [ ! -f "$1" ]; then
    echo "File not found: $1"
    exit 1
fi

# Read each line from the file
while read -r line; do
    lowercased_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')  # Convert to lowercase

    echo "Processing: $lowercased_line"

    # Perform whois command and extract "Registrant Name:"
    registrant_name=$(whois "$lowercased_line" | awk -F ':' '/Registrant Name:/ {print $2; exit}')

    if [ -n "$registrant_name" ]; then
        echo "Registrant Name: $registrant_name"
    else
        echo "Registrant Name not found"
    fi

    # Perform fping command and extract IP address
    fping_output=$(fping -A -n "$lowercased_line" 2>&1)
    
    if [ $? -eq 0 ]; then
        ip_address=$(echo "$fping_output" | awk '{print $2}')
        echo "fping: Host is reachable, IP: $ip_address"
    else
        echo "fping: Host is unreachable"
    fi

    echo
done < "$1"
