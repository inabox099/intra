#!/bin/bash

# Define the subnet to scan
SUBNET="192.168.0.1/24"

# Check for required tools
if ! command -v nmap &> /dev/null; then
    echo "nmap is required but not installed. Please install nmap."
    exit 1
fi

# Scan the subnet for hosts with SSH enabled
echo "Scanning subnet $SUBNET for hosts with SSH enabled..."
SSH_HOSTS=$(nmap -p 22 --open -oG - "$SUBNET" | awk '/22\/open/ {print $2}')

# Check if any hosts were found
if [ -z "$SSH_HOSTS" ]; then
    echo "No hosts with SSH enabled found on subnet $SUBNET."
    exit 0
fi

# Check for the presence of the user "ansuser" on each host
echo "Checking for the presence of user 'ansuser' on discovered hosts..."
for HOST in $SSH_HOSTS; do
    if ssh -o BatchMode=yes -o ConnectTimeout=5 "ansuser@$HOST" "exit" 2>/dev/null; then
        echo "Host $HOST has SSH enabled and user 'ansuser' is present."
    else
        echo "Host $HOST does not have user 'ansuser' or is unreachable."
    fi
done