#!/bin/bash

DEFAULT_SERVER_IP="$1"
DEFAULT_SERVER_PORT="4242"
SERVER_FD=3 # Global variable for the file descriptor

perform_handshake() {
  exec {SERVER_FD}<>/dev/tcp/"$DEFAULT_SERVER_IP"/"$DEFAULT_SERVER_PORT"

  if [[ $? -eq 0 ]]; then
    echo "Hi!" >&${SERVER_FD} # Send "Hi!" to the server
  else
    echo "Failed to connect to $DEFAULT_SERVER_IP on port $DEFAULT_SERVER_PORT"
    exit 1
  fi

  while true; do
    read -r response <&${SERVER_FD}

    if [[ "$response" == "Hello! IP of your gateway?" ]]; then
      default_gateway=$(ip route | grep default | awk '{print $3}')
      echo "$default_gateway" >&${SERVER_FD}
    elif [[ "$response" == "Your favorite city?" ]]; then
      echo "Ochakiv" >&${SERVER_FD}
    elif [[ "$response" == "Ready." ]]; then
      echo "$response"
      break
    else
      echo "Unexpected response: $response"
      exit 1
    fi
  done
}

process_communication() {
  while true; do
    read -p "Enter command (or type 'exit' to quit): " user_input

    if [[ "$user_input" == "exit" ]]; then
      echo "Don't stop me now!"
      break
    fi

    echo "$user_input" >&${SERVER_FD}
    read -r server_response <&${SERVER_FD}
    echo "Server: $server_response"
  done
}

# Main script logic
perform_handshake
process_communication

exec {SERVER_FD}>&-
