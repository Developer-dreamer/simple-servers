#!/bin/bash

# File containing IP and authorization key pairs
CREDENTIALS_FILE="/etc/authServer/credentials.txt"
FTP_PORT="21"

# Extract client IP from environment variable passed by socat
CLIENT_IP="${SOCAT_PEERADDR}"

# Prompt user for authorization key
echo "Enter authorization key for IP $CLIENT_IP:"
read -r AUTH_KEY

# Check if the IP and authorization key are valid
MATCH_FOUND=false
while IFS=' ' read -r FILE_IP FILE_KEY; do
  if [[ "$CLIENT_IP" == "$FILE_IP" && "$AUTH_KEY" == "$FILE_KEY" ]]; then
    MATCH_FOUND=true
    break
  fi
done <"$CREDENTIALS_FILE"

# Clear any previous iptables rules for this IP address on FTP port
iptables -D INPUT -s "$CLIENT_IP" -p tcp --dport $FTP_PORT -j ACCEPT 2>/dev/null
iptables -D INPUT -s "$CLIENT_IP" -p tcp --dport $FTP_PORT -j DROP 2>/dev/null

if $MATCH_FOUND; then
  # If credentials match, allow access to the FTP server
  iptables -I INPUT -s "$CLIENT_IP" -p tcp --dport $FTP_PORT -j ACCEPT
  echo "Access to FTP server granted for IP $CLIENT_IP."
else
  # If no match, explicitly deny access to the FTP server
  iptables -A INPUT -s "$CLIENT_IP" -p tcp --dport $FTP_PORT -j DROP
  echo "Access to FTP server denied for IP $CLIENT_IP due to invalid credentials."
fi
