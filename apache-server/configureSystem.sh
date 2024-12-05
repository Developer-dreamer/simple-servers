#!/bin/bash

swap_ports() {
  readonly CONFIG="/etc/apache2/sites-available/000-default.conf"
  readonly PORTS="/etc/apache2/ports.conf"

  sudo sed -i 's|<VirtualHost \*:80>|<VirtualHost \*:10000>|' "$CONFIG"
  sudo sed -i 's/Listen 80/Listen 10000/' "$PORTS"

  sudo iptables -A INPUT -p tcp --dport 10000 -s 127.0.0.1 -j ACCEPT

  sudo iptables -A INPUT -p tcp --dport 10000 -j REJECT

  echo "Port updated to 10000"
}

configure_server() {
  readonly INDEX_PAGE="/home/ubuntu/index.html"
  readonly ERROR_PAGE="/home/ubuntu/error.html"

  echo "Configuring Apache"
  if ! command -v apache2 >/dev/null 2>&1; then
    echo "Apache package not found. Installing ..."
    sudo apt-get install apache2 apache2-doc apache2-utils -y >/dev/null 2>&1
  fi

  #moving our site to working directory
  sudo mv $INDEX_PAGE $ERROR_PAGE /var/www/html/

  #mooving port 80 to 10000
  swap_ports

  #reloading configuration of the apache2
  sudo systemctl reload apache2
}

configure_proxy() {
  readonly PROXY="/home/ubuntu/proxyServer.sh"
  readonly PROXY_SERVICE="/home/ubuntu/proxyServer.service"

  if ! command -v socat >/dev/null 2>&1; then
    echo "Socat package not found. Intalling ..."
    sudo apt-get install socat -y >/dev/null 2>&1
  fi

  sudo chmod +x "$PROXY"
  sudo mv "$PROXY" "/etc/"
  sudo mv "$PROXY_SERVICE" "/etc/systemd/system/"

  sudo systemctl daemon-reload
  sudo systemctl enable proxyServer.service
  sudo systemctl start proxyServer.service
}

configure_server
configure_proxy
