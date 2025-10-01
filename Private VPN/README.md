# Kali Linux VPN Setup Guide

A guide and script to configure an OpenVPN connection on Kali Linux using the Network Manager and ProtonVPN.

## Features

-   **Secure:** Encrypts internet traffic to protect online identity and data.
-   **Bypass Geoblocks:** Access region-restricted content by routing your traffic through a VPN server.

---

## Manual Setup Instructions

### Step 1: Install Required Packages

First, open terminal and ensure system is up-to-date. Then, install OpenVPN and the Network Manager integration.

```bash
sudo apt update
sudo apt install openvpn
sudo apt install network-manager-openvpn-gnome
```

### Step 2: Download the OpenVPN (`.ovpn`) Configuration File

1.  Go to the [ProtonVPN login page](https://account.protonvpn.com/login) and sign in or create a free account.
2.  Navigate to the **Downloads** section from the left sidebar.
3.  Find the **OpenVPN configuration files** section.
4.  Set the **Platform** to `GNU/Linux`.
5.  Choose a server and download it to save the `.ovpn` file.

### Step 3: Configure the VPN Connection

1.  Click on the **Network Manager** icon (top-right of the screen).
2.  Select **VPN Connections** > **Add a VPN connection...**.
3.  In the new window, scroll to the bottom, choose **Import a saved VPN configuration...**, and click **Create**.
4.  Select the `.ovpn` file.
5.  An "Editing VPN" window will appear. Use OpenVPN credentials.
    * Go back to your ProtonVPN account page.
    * Navigate to **Account** > **OpenVPN / IKEv2 username**.
    * Copy the **Username** and **Password** provided there.
6.  Paste these credentials into the `Username` and `Password` fields in the VPN editing window.
7.  Click **Save**.

### Step 4: Connect to the VPN

1.  Click the **Network Manager** icon again.
2.  Go to **VPN Connections**.
3.  Click the name of the VPN connection that was just created to connect.
