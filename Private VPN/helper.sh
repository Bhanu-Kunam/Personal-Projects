#!/bin/bash

# ==============================================================================
# VPN Setup Guide for Kali Linux (using ProtonVPN)
#
# Description:
# This script will install the necessary packages for OpenVPN and guide
# through the configuration steps.
# ==============================================================================

# STEP 1: INSTALL REQUIRED PACKAGES
echo "### STEP 1: Installing OpenVPN and Network Manager Packages... ###"
echo "Will now update package list and install required software."
echo ""

# Update package lists
sudo apt-get update

# Install the necessary packages
sudo apt install openvpn
sudo apt install network-manager-openvpn-gnome

echo ""
echo "Success! Packages installed."
echo "Restart system after the script is done."
echo ""
echo "--------------------------------------------------------------------------"
echo ""

# STEP 2: DOWNLOAD OVPN CONFIGURATION FILE
echo "### STEP 2: Download the .ovpn Configuration File ###"
echo "1. Go to the ProtonVPN Account page: https://account.protonvpn.com/login"
echo "2. Log in or create a free account."
echo "3. On the left sidebar, click on 'Downloads'."
echo "4. In the 'OpenVPN configuration files' section, do the following:"
echo "   - Platform: Select 'GNU/Linux'"
echo "   - Protocol: Select 'UDP'"
echo "   - Select a country and server, then 'Download'."
echo "5. Save the '.ovpn' file."
echo ""
read -p "Press [Enter] when you have downloaded the .ovpn file..."
echo ""
echo "--------------------------------------------------------------------------"
echo ""

# STEP 3: CONFIGURE THE VPN CONNECTION
echo "### STEP 3: Configure the VPN in Network Manager ###"
echo "Now, import the file that was downloaded."
echo ""
echo "1. Click the network icon at the top-right of your screen."
echo "2. Go to 'VPN Connections' -> 'Add a VPN connection...'."
echo "3. A new window will appear. At the bottom, select 'Import a saved VPN configuration...' and click 'Create'."
echo "4. Select the '.ovpn' file that was downloaded, and click 'Open'."
echo ""
echo "A new window titled 'Editing VPN connection' will appear. Enter OpenVPN credentials."
echo ""
echo "5. To find credentials, go back to ProtonVPN account page."
echo "6. On the left sidebar, click 'Account' -> 'OpenVPN / IKEv2 username'."
echo "7. Copy the 'Username' and 'Password' shown there."
echo "8. Paste these credentials into the 'Username' and 'Password' fields in the VPN connection window."
echo "9. Click 'Save' in the top-right corner."
echo ""
read -p "Press [Enter] when you have saved the VPN configuration..."
echo ""
echo "--------------------------------------------------------------------------"
echo ""

# STEP 4: CONNECT TO THE VPN 
echo "### STEP 4: Connect to New VPN ###"
echo "VPN is now configured and ready to use."
echo ""
echo "1. Click the network icon at the top-right of your screen again."
echo "2. Go to 'VPN Connections'."
echo "3. Click on the name of the connection that was just created to enable it."
echo ""
echo "All Done! A notification will appear when the connection is successful."
echo "Remember to restart your system if you haven't already."
echo ""
