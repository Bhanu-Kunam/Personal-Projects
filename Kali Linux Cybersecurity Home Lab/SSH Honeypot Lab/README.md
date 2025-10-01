# Simple Honeypot on Kali Linux

## What is a Honeypot?

A honeypot is a security mechanism that creates a decoy to lure in attackers. It is designed to be a vulnerable system that will attract and trap attackers, allowing you to study their methods and gather intelligence about their activities.

## Features

* **Medium to high interaction SSH and Telnet honeypot**
* **Logs brute force attacks**
* **Logs shell interaction performed by the attacker**
* **Simulates a vulnerable system to attract attackers**

## Installation

1.  **Update your system:**

    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

2.  **Clone the Cowrie repository:**

    ```bash
    git clone [https://github.com/cowrie/cowrie.git](https://github.com/cowrie/cowrie.git) /home/kali/Honeypot
    ```

3.  **Set up a Python virtual environment:**

    ```bash
    sudo apt install python3-venv -y
    cd /home/kali/Honeypot
    python3 -m venv cowrie-env
    source cowrie-env/bin/activate
    ```

4.  **Install dependencies:**

    ```bash
    pip install -r requirements.txt
    ```

5.  **Configure Cowrie:**

    ```bash
    cp etc/cowrie.cfg.dist etc/cowrie.cfg
    nano etc/cowrie.cfg
    ```

    * Change the `hostname` to something like `ssh_server22` to deceive attackers.
    * Enable Telnet by changing `enabled = false` to `enabled = true` under the `[telnet]` section.

6.  **Set up Cowrie to listen on port 22:**

    ```bash
    sudo iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222
    sudo iptables -t nat -A PREROUTING -p tcp --dport 23 -j REDIRECT --to-port 2223
    ```
     * iptables : The command-line utility used to configure Linux kernel firewall rules and network traffic.
     * -t nat	: Specifies that we want to use the nat (Network Address Translation) table. This table is used for routing packets to different network interfaces or ports.
     * -A PREROUTING : Appends this rule to the PREROUTING chain. This chain processes packets as soon as they arrive on the machine, before any routing decisions are made.
     * -p tcp	: Indicates that this rule applies only to packets using the TCP protocol.
     * --dport 22	: Specifies the destination port. The rule will only match packets that are intended for port 22 (or 23 in the second command).
     * -j REDIRECT : Jumps to the REDIRECT target, which is an action to take. REDIRECT forwards the packet to a different port on the same machine.
     * --to-port 2222	: Specifies the new destination port where the traffic will be sent (or 2223 in the second command).

7.  **Set up permissions:**

    ```bash
    sudo chown -R kali:kali /home/kali/Honeypot/var/run
    sudo chown -R kali:kali /home/kali/Honeypot/var/lib/cowrie
    sudo chmod -R 755 /home/kali/Honeypot/var/run
    su kali
    ```

## Usage

1.  **Start the honeypot:**

    ```bash
    bin/cowrie start
    ```

2.  **Check the status:**

    ```bash
    ps aux | grep cowrie
    ```
    * ps aux : This command lists all currently running processes.
    * a	: Shows processes for all users, not just the current one.
    * u	: Displays the user who owns each process for more detail.
    * x	: Includes processes that are not attached to a terminal (like background services).
    * | (Pipe) : The pipe passes the output of "ps aux" as an input for the next command, "grep cowrie"
    * grep cowrie :	This command searches through the input it receives from the pipe and displays only the lines that contain the word "cowrie".

3.  **View the logs:**

    ```bash
    tail -f var/log/cowrie/cowrie.log
    ```
    * Expected log output to confirm that the honeypot is now active and listening for SSH and Telnet connections on ports 2222 and 2223, respectively:
      * "CowrieSSHFactory starting on 2222" : The SSH honeypot is now listening on port 2222
      * "HoneyPotTelnetFactory starting on 2223" : The Telnet honeypot is listening on port 2223

4.  **Stop the honeypot:**

    ```bash
    bin/cowrie stop
    ```

## Attack Simulation

From another machine, you can simulate an attack on your honeypot.

1.  **Check if both machines can communicate:**

    ```bash
    ip a
    ping <Machine_ip>
    ```

1.  **SSH connection attempt:**

    ```bash
    ssh kali@<Target_IP>
    ```

## Overview of Network Logon Crackers: Hydra and Medusa

Hydra and Medusa are command-line tools engineered for performing rapid dictionary and brute-force attacks against network authentication services. They are widely utilized in the cybersecurity field for both offensive and defensive security assessments.

### Core Attack Methodologies

These tools primarily employ two methods for password cracking:

* **Dictionary Attack**: This technique utilizes a predefined list of potential passwords, known as a wordlist or dictionary. The tool systematically attempts to authenticate with each password in the list, a method that is highly efficient against common or weak credentials.
* **Brute-Force Attack**: In this approach, the tool systematically generates and tests all possible character combinations for a password of a given length. While exhaustive, this method is computationally intensive and time-consuming.



---

### THC-Hydra

Often referred to as Hydra, this tool is recognized for its extensive flexibility and broad support for numerous network protocols.

* **Primary Function**: Hydra is a parallelized network logon cracker designed to test authentication on a wide array of services.
* **Key Features**:
    * **Extensive Protocol Support**: It is compatible with a vast number of services, including but not limited to SSH, Telnet, FTP, HTTP/HTTPS authentication forms, SMB, RDP, and various database protocols.
    * **High Performance**: Its parallel design allows for multiple simultaneous login attempts, significantly accelerating the cracking process.
    * **Versatility**: Hydra can be configured to cycle through lists of both usernames and passwords, making it adaptable to various testing scenarios.

---

### Medusa

Medusa is a comparable tool, distinguished by its focus on speed, stability, and massively parallel operation.

* **Primary Function**: Medusa is engineered to be a fast, modular, and parallel network logon cracker, well-suited for large-scale security audits.
* **Key Features**:
    * **Speed and Stability**: It is highly regarded for maintaining stable performance during intensive scans across a large number of hosts.
    * **Massively Parallel Operation**: The design allows for thread-based parallel testing of multiple hosts, users, or passwords concurrently.
    * **Modular Architecture**: Support for different services is implemented via individual modules, which allows for straightforward extension and customization.

---

2.  **Brute-force attack with Hydra:**

    ```bash
    hydra -l kali -P /usr/share/wordlists/rockyou.txt ssh://<Target_IP> -t 4
    ```

3.  **Brute-force attack with Medusa:**

    ```bash
    medusa -h <Target_IP> -u kali -P /usr/share/wordlists/rockyou.txt -M ssh -n 22
    ```

## Disclaimer

This project provides a step-by-step guide to creating a simple honeypot on Kali Linux using **Cowrie**. This guide is based on the [Medium article by Iritt](https://iritt.medium.com/creating-a-simple-honeypot-project-on-kali-linux-a-step-by-step-guide-with-attack-simulation-d2aacf5e35ea).
