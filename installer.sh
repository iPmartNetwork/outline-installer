#!/bin/bash

# Text attributes
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

echo "
____________________________________________________________________________________
        ____                             _     _                                     
    ,   /    )                           /|   /                                  /   
-------/____/---_--_----__---)__--_/_---/-| -/-----__--_/_-----------__---)__---/-__-
  /   /        / /  ) /   ) /   ) /    /  | /    /___) /   | /| /  /   ) /   ) /(    
_/___/________/_/__/_(___(_/_____(_ __/___|/____(___ _(_ __|/_|/__(___/_/_____/___\__
                                                                                     
"
echo "***** https://github.com/ipmartnetwork *****"
# Welcome message
echo "${GREEN}Welcome to Outline VPN Auto Installer script by iPmart Network${RESET}"
echo "${GREEN}Outline VPN installation is ready to begin, press any key to start.${RESET}"
read -n 1 -s

# Ask user if they want to remove the firewall
read -p "Do you want to remove the firewall from the system? (y/N): " remove_firewall

if [[ ${remove_firewall,,} == "y" ]]; then
#if [[ $remove_firewall == "y" || $remove_firewall == "Y" ]]; then
    echo "${GREEN}Removing the firewall from the system...${RESET}"

    # Flush IP tables
    iptables -F

    # Stop iptables and UFW services
    service iptables stop
    service ufw stop

    # Remove iptables and UFW packages
    apt -y remove iptables
    apt -y remove ufw

    echo "${GREEN}Firewall has been removed from the system.${RESET}"
else
    echo "${GREEN}Skipping firewall removal.${RESET}"

    # Check if UFW is installed
    if command -v ufw &>/dev/null; then
        echo "${GREEN}UFW is installed. Configuring UFW firewall rules...${RESET}"

        # Allow port 59618 TCP
        ufw allow 59618/tcp

        # Allow port 60208 TCP
        ufw allow 60208/tcp

        # Allow port 60208 UDP
        ufw allow 60208/udp

        # Enable UFW
        ufw --force enable

        echo "${GREEN}UFW firewall rules have been configured.${RESET}"
    fi

    # Check if iptables is installed
    if command -v iptables &>/dev/null; then
        echo "${GREEN}iptables is installed. Configuring iptables firewall rules...${RESET}"

        # Allow port 59618 TCP
        iptables -A INPUT -p tcp --dport 59618 -j ACCEPT

        # Allow port 60208 TCP
        iptables -A INPUT -p tcp --dport 60208 -j ACCEPT

        # Allow port 60208 UDP
        iptables -A INPUT -p udp --dport 60208 -j ACCEPT

        echo "${GREEN}iptables firewall rules have been configured.${RESET}"
    fi
fi

# Update and upgrade the system
echo "${GREEN}Updating and upgrading the system...${RESET}"
apt-get update
apt-get -y upgrade

# Clean up unused packages
echo "${GREEN}Cleaning up unused packages...${RESET}"
apt-get -y autoremove
apt-get -y autoclean

# Install Docker
echo "${GREEN}Installing Docker...${RESET}"
curl -sS https://get.docker.com/ | sh

# Start and enable Docker service
echo -e "${GREEN}Starting and enabling Docker service...${RESET}"
systemctl start docker
systemctl enable docker

# Install Outline VPN Server
echo "${GREEN}Installing Outline Server...${RESET}"
wget -qO- https://raw.githubusercontent.com/Jigsaw-Code/outline-server/master/src/server_manager/install_scripts/install_server.sh | bash

# Check the installation status
if [ $? -eq 0 ]; then
    echo "${GREEN}Outline VPN has been installed successfully.${RESET}"
else
    echo "${RED}Outline VPN installation failed.${RESET}"
fi
