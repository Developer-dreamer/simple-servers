#!/bin/bash

readonly LOG_FILE="/var/log/apiServer.log"
readonly PORT="4242"
readonly DB="/home/ubuntu/db.txt"

read_db() {
  local param="$1"

  if [[ ! -e $DB ]]; then
    echo "Error with database"
    exit 1
  fi

  while IFS=";" read -r movie director year; do
    if [[ "$param" == "$year" || "$param" == "$movie" ]]; then
      echo "$movie ($year), directed by $director"
    fi
  done <"$DB"
}

handle_client() {
  echo "Hello! IP of your gateway?"
  read gateway_ip

  if [[ -z "$gateway_ip" ]]; then
    echo "$(date) - Protocol violation: Missing IP" >>"$LOG_FILE"
    echo "Protocol violation. Disconnecting."
    exit 1
  fi

  echo "Your favorite city?"
  read favorite_city

  if [[ -z "$favorite_city" ]]; then
    echo "$(date) - Protocol violation: Missing city" >>"$LOG_FILE"
    echo "Protocol violation. Disconnecting."
    exit 1
  fi

  echo "$(date) - Handshake successful with IP $gateway_ip and city $favorite_city" >>"$LOG_FILE"
  echo "Ready."

  while true; do
    read user_input
    echo "$(date) - Received request: $user_input" >>"$LOG_FILE"

    if [[ "$user_input" == "exit" ]]; then
      echo "Don't stop me now!"
      break
    else
      command_type=$(echo "$user_input" | awk '{print $1}')
      param=$(echo "$user_input" | cut -d' ' -f2-)

      if [[ "$command_type" != "GetMoviesByYear" && "$command_type" != "GetMovieDirector" ]]; then
        echo "Incorrect command: $command_type"
        echo "Allowed commands: GetMoviesByYear, GetMovieDirector"
      else
        result=$(read_db "$param")
        echo "${result:-No results found.}"
      fi
    fi
  done
}

while true; do
  read input
  if [[ "$input" == "Hi!" ]]; then
    handle_client
    break
  fi
done
