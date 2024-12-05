#!/bin/bash

configure_access() {
  if [ -z "$1" ]; then
    echo "Usage: $0 <comma-separated list of IP addresses>"
    exit 1
  fi

  IFS=',' read -ra ALLOWED_IPS <<<"$1"

  echo "Disabling ICMP (ping) requests..."

  sudo iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

  echo "Ping requests disabled."

  echo "Configuring FTP access..."

  sudo iptables -A INPUT -p tcp --dport 21 -j DROP

  for IP in "${ALLOWED_IPS[@]}"; do
    sudo iptables -A INPUT -p tcp --dport 21 -s "$IP" -j ACCEPT

    echo "FTP access allowed for $IP"

  done

  echo "IpTables configured"
}

install_packages() {
  echo "Configuring socat ..."

  if ! command -v socat >/dev/null 2>&1; then
    echo "Socat package not found. Intalling ..."
    sudo apt-get install socat -y >/dev/null 2>&1
  fi

  echo "Configuring vsftpd"

  if ! command -v vsftpd >/dev/null 2>&1; then
    echo "vsftpd package not found. Intalling ..."
    sudo apt-get install vsftpd -y >/dev/null 2>&1
  fi

  echo "Required packages installed"
}

configure_server() {
  readonly SERVER="/home/ubuntu/authServer.sh"
  readonly SERVER_SERVICE="/home/ubuntu/authServer.service"
  readonly CREDENTIALS="/home/ubuntu/credentials.txt"

  echo "Configuring credentials ..."

  sudo mkdir "/etc/authServer"
  sudo mv "$CREDENTIALS" "/etc/authServer/"

  echo "Configuring server ..."

  sudo chmod +x "$SERVER"
  sudo mv "$SERVER" "/usr/bin/"
  sudo mv "$SERVER_SERVICE" "/etc/systemd/system/"

  sudo systemctl daemon-reload
  sudo systemctl enable authServer.service
  sudo systemctl start authServer.service

  echo "Server configured"
}

configure_ftp_user() {
  local USERNAME="ftp_user"
  local PASSWORD="MyFTPPass!"
  local USER_HOME="/home/$USERNAME"
  local FILE1="$USER_HOME/1.txt"
  local FILE2="$USER_HOME/2.txt"
  local FILE_CONTENT="Hello World!"

  # Add user with specific home directory and no interaction
  sudo adduser --gecos "FTP User,,," --disabled-password "$USERNAME"

  # Set the user's password
  echo "$USERNAME:$PASSWORD" | sudo chpasswd

  # Ensure the home directory exists (it should be created by adduser, but double-check)
  sudo mkdir -p "$USER_HOME"

  # Create files with "Hello World!" content
  echo "$FILE_CONTENT" | sudo tee "$FILE1" "$FILE2" >/dev/null

  # Set appropriate ownership and permissions
  sudo chown -R "$USERNAME:$USERNAME" "$USER_HOME"
  sudo chmod 644 "$FILE1" "$FILE2"

  # Print success message
  echo "FTP user '$USERNAME' created with password '$PASSWORD'."
  echo "Files '1.txt' and '2.txt' with 'Hello World!' are available in $USER_HOME."
}

configure_access $1
install_packages
configure_server
configure_ftp_user
