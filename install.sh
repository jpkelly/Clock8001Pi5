#!/bin/bash

# Clock-8001 Raspberry Pi 5 Install Script
# Author: jp (jpkelly/piClock)
# Clock-8001 Authors: depili, kissa
# License: MIT (this script only)
#
# NOTE: This script is intended for Raspberry Pi OS Lite (32-bit).
#       Other operating systems or architectures may not be compatible.
#
# This script automates the installation of Clock-8001 and related services.
# It does NOT include or modify Clock-8001 code.
# Clock-8001 is licensed under GNU GPL v2.0 or later.
# See: https://gitlab.com/clock-8001/clock-8001/
#
# Usage:
#   bash install.sh
#
# Run as a user with sudo privileges. Review the script before running on production systems.

echo "Installing Raspberry Pi 5 Build of Clock-8001"

# Update system
echo "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

# Install dependencies
echo "Installing dependencies..."
sudo apt-get install -y build-essential pkg-config autoconf automake libtool libdrm-dev libgbm-dev libudev-dev linux-libc-dev libdirectfb-dev libts-dev

# Parse version from URL
CLOCK_URL="https://kissa.depili.fi/clock-8001/releases/clock-8001_4.24.2_armhf.deb"
CLOCK_VERSION=$(echo "$CLOCK_URL" | grep -oP 'clock-8001_\K[0-9.]+(?=_armhf.deb)')

echo "\n============================================"
echo "Clock-8001 version to be installed: \033[1;32m$CLOCK_VERSION\033[0m"
echo "============================================\n"
echo "Do you want to install the latest version instead? (y/N)"
read -r INSTALL_LATEST
if [[ "$INSTALL_LATEST" =~ ^[Yy]$ ]]; then
    echo "Fetching latest version info..."
    LATEST_URL=$(curl -s https://kissa.depili.fi/clock-8001/releases/ | grep -oP 'clock-8001_[0-9.]+_armhf.deb' | sort -V | tail -1)
    if [ -n "$LATEST_URL" ]; then
        CLOCK_URL="https://kissa.depili.fi/clock-8001/releases/$LATEST_URL"
        CLOCK_VERSION=$(echo "$CLOCK_URL" | grep -oP 'clock-8001_\K[0-9.]+(?=_armhf.deb)')
        echo "Latest version found: $CLOCK_VERSION"
    else
        echo "Could not find latest version, using default."
    fi
fi

echo "Installing Clock-8001 version $CLOCK_VERSION..."
curl -O "$CLOCK_URL"
sudo apt install -y ./clock-8001_${CLOCK_VERSION}_armhf.deb

# Build compatible (legacy) version of SDL
echo "Building compatible version of SDL..."
wget https://github.com/libsdl-org/SDL/archive/refs/tags/release-2.0.10.tar.gz
tar xzf release-2.0.10.tar.gz
cd SDL-release-2.0.10
./configure --enable-video-kmsdrm --enable-video-directfb --disable-video-opengl --disable-video-opengles
make -j4
sudo make install
sudo ldconfig
cd ..

# Setup environment
echo "Setting up environment..."
sudo cp /usr/bin/sdl-clock /usr/share/clock-8001/
sudo chown pi:pi /usr/share/clock-8001/clock.ini
sudo chmod 664 /usr/share/clock-8001/clock.ini

# Create sdl-clock.service file
echo "Creating sdl-clock service..."
cat > sdl-clock.service << EOF
[Unit]
Description=Clock-8001 SDL App
After=network.target

[Service]
Type=simple
WorkingDirectory=/usr/share/clock-8001/
ExecStart=/usr/share/clock-8001/sdl-clock --config=/usr/share/clock-8001/clock.ini --http-port=:8080 --debug
Restart=on-failure
User=pi
Environment=SDL_VIDEODRIVER=kmsdrm

[Install]
WantedBy=multi-user.target
EOF
sudo mv sdl-clock.service /etc/systemd/system/

# Enable/run sdl-clock service
echo "Enabling sdl-clock service..."
sudo systemctl daemon-reload
sudo systemctl enable sdl-clock
sudo systemctl start sdl-clock

# Install alsa-ltc (Audio to OSC SMTP LTC Converter)
echo "Installing alsa-ltc..."

# Install dependencies for alsa-ltc
echo "Installing alsa-ltc dependencies..."
sudo apt-get install -y libltc11

# Add alsa-ltc app to /usr/share/clock-8001/
echo "Adding alsa-ltc app..."
cd /usr/share/clock-8001/
sudo wget https://kissa.depili.fi/clock-8001/alsa-ltc
sudo chown pi:pi alsa-ltc
chmod +x alsa-ltc

# Create alsa-ltc_cmd.sh
echo "Creating alsa-ltc_cmd.sh..."
sudo tee /usr/share/clock-8001/alsa-ltc_cmd.sh > /dev/null << EOF
#!/bin/bash
/usr/share/clock-8001/alsa-ltc sysdefault:CARD=Device 255.255.255.255 1245
EOF
sudo chown pi:pi /usr/share/clock-8001/alsa-ltc_cmd.sh
chmod +x /usr/share/clock-8001/alsa-ltc_cmd.sh

# Create alsa-ltc.service
echo "Creating alsa-ltc service..."
sudo tee /etc/systemd/system/alsa-ltc.service > /dev/null << EOF
[Unit]
Description=Audio to OSC SMTP LTC Converter
After=network.target sound.target

[Service]
Type=simple
WorkingDirectory=/usr/share/clock-8001
ExecStart=/usr/share/clock-8001/alsa-ltc_cmd.sh
Restart=always
RestartSec=2
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
sudo mv alsa-ltc.service /etc/systemd/system/

# Enable/run alsa-ltc service
echo "Enabling alsa-ltc service..."
sudo systemctl daemon-reload
sudo systemctl enable alsa-ltc
sudo systemctl start alsa-ltc

echo "Installation completed!"

# Show web interface login instructions
IP=$(hostname -I | awk '{print $1}')
PORT=$(grep '^HTTPPort=' /usr/share/clock-8001/clock.ini | cut -d'=' -f2)

# Remove any leading colon from PORT
PORT_CLEAN=${PORT#:}

cat <<EOM

============================================
🎉 Installation completed!
============================================

To access the Clock-8001 web interface:

   Open your browser and go to:
   http://$IP:$PORT_CLEAN

Default login credentials:
   Username: admin
   Password: clockwork

If accessing from another device, use your Raspberry Pi's IP address above.
(or use the hostname: http://$(hostname).local:$PORT_CLEAN)

Enjoy your new Clock-8001 system!
============================================
EOM