# Clock8001Pi5

This repository contains an installation script for setting up Clock-8001 on a Raspberry Pi 5 running Raspberry Pi OS Lite (32-bit).

## About Clock-8001

Clock-8001 is a timecode clock suite for Raspberry Pi. It is developed by depili and kissa, with packaging and install automation by JP Kelly.

- Official Clock-8001 project: [Clock-8001 GitLab](https://gitlab.com/clock-8001/clock-8001/)
- This repository provides helper scripts and automation; Clock-8001 itself is licensed under GNU GPL v2.0 or later.

## Installation

> **Note:** This script is intended for Raspberry Pi OS Lite (32-bit). Other operating systems or architectures may not be compatible.

### Prerequisites

- A Raspberry Pi 5 running Raspberry Pi OS Lite (32-bit)
- Internet access
- `sudo` privileges

### Steps

1. Update your system:

    ```bash
    sudo apt-get update
    sudo apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
    ```

2. Download and run the install script:

    ```bash
    git clone https://github.com/jpkelly/Clock8001Pi5.git
    cd Clock8001Pi5
    bash install.sh
    ```

3. The script will:
    - Install required dependencies
    - Download and install Clock-8001 (you may choose latest or default version)
    - Build a compatible SDL library
    - Set up services for Clock-8001 and alsa-ltc (Audio to OSC SMTP LTC Converter)
    - Enable and start the services

4. **Web Interface:**
    - After installation, access the Clock-8001 web interface at:  
      `http://<your-pi-ip>:<port>`
    - Default credentials:
      - Username: `admin`
      - Password: `clockwork`
    - You can also use your Pi's hostname:  
      `http://<hostname>.local:<port>`

## License

This install script is released under the MIT License (see LICENSE file).  
Clock-8001 itself is licensed under GNU GPL v2.0 or later.

## Credits

- Clock-8001 Authors: depili, kissa
- Install script and packaging: JP Kelly