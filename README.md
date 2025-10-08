# Clock8001Pi5

This repository contains an installation script for setting up Clock-8001 on a Raspberry Pi 5 running Raspberry Pi OS Lite (32-bit) Bookworm.
Note: This only works on Bookworm, Trixie is not supported.

## About Clock-8001

The clock-8001 is an open-source, customizable, professional-grade clock and timer project, typically based on a Raspberry Pi. Its main features include network control via the Open Sound Control (OSC) protocol, advanced timing, and customizable interfaces.

- Official Clock-8001 project: [Clock-8001 GitLab](https://gitlab.com/clock-8001/clock-8001/)
- This repository provides helper scripts and automation; Clock-8001 itself is licensed under GNU GPL v2.0 or later.

## Installation

> **Note:** This script is intended for Raspberry Pi OS Lite (32-bit) Bookworm. Other operating systems or architectures may not be compatible.

### Prerequisites

- A Raspberry Pi 5 running Raspberry Pi OS Lite (32-bit)
- Internet access
- `sudo` privileges

### Steps

1. Download and run the install script:

    ```bash
    wget https://raw.githubusercontent.com/jpkelly/Clock8001Pi5/main/install.sh
    bash install.sh
    ```

    The install script will automatically update and upgrade your system, install required dependencies, and handle all necessary setup.

2. The script will:
    - Install required dependencies
    - Download and install Clock-8001 (you may choose latest or default version)
    - Build a compatible SDL library
    - Set up services for Clock-8001 and alsa-ltc (Audio to OSC SMTP LTC Converter)
    - Enable and start the services

3. **Web Interface:**
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
