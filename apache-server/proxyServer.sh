#!/bin/bash

SUCCESS_PAGE="http://localhost:10000/index.html"
ERROR_PAGE="http://localhost:10000/error.html"

max_digit=0
for digit in $(echo "$SOCAT_PEERPORT" | grep -o .); do
  if ((digit > max_digit)); then
    max_digit=$digit
  fi
done

ps_output=$(ps aux)
last_two_hex=$(echo -n "$ps_output" | sha512sum | awk '{print substr($1, length($1)-1, 2)}')
last_two_decimal=$((16#$last_two_hex))

sum_result=$(((max_digit + last_two_decimal) % 2))

if ((sum_result == 1)); then
  curl -s "$SUCCESS_PAGE"
else
  curl -s "$ERROR_PAGE"
fi
