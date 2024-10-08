#!/bin/bash

# Function to check if a package is installed
check_installed() {
    dpkg -l | grep -qw "$1" && echo "$1 is already installed" || (echo "Installing $1" && sudo apt install -y "$1")
}

# Function to prompt user for input with a default value
prompt_input() {
    local var_name=$1
    local prompt_message=$2
    local default_value=$3
    read -p "$prompt_message [$default_value]: " input
    input=${input:-$default_value}
    eval "$var_name=\"$input\""
}

# Function to get the Raspberry Pi's IP address
get_ip_address() {
    hostname -I | awk '{print $1}'
}

echo "Starting installation of Web Display API..."

# Update package list
sudo apt update

# Check for necessary packages and install if not present
check_installed python3
check_installed python3-pip
check_installed chromium-browser
check_installed xserver-xorg
check_installed xinit

# Install Flask if not installed
pip3 show flask &> /dev/null
if [ $? -eq 0 ];then
    echo "Flask is already installed"
else
    echo "Installing Flask..."
    sudo pip3 install flask
fi

# Prompt user for port number (default 5000)
prompt_input PORT "Enter the port number for the Web Display API" "5000"

# Prompt user for installation directory (default /etc/web_display_api)
prompt_input INSTALL_DIR "Enter the installation directory" "/etc/web_display_api"

# Prompt user for the username (default current user)
prompt_input USERNAME "Enter the username to run the service under" "$(whoami)"

# Create app directory if it doesn't exist
mkdir -p $INSTALL_DIR

# Create the Python app in the proper directory
cat << EOF > $INSTALL_DIR/web_display_api.py
from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)

# Function to load the URL in a fullscreen Chromium browser window
def load_website(url):
    # Kill any existing Chromium processes
    subprocess.run(["pkill", "chromium"], check=False)
    
    # Set environment variables for X server display and authority
    display = os.environ.get('DISPLAY', ':0')
    xauthority = os.environ.get('XAUTHORITY', '/home/$USERNAME/.Xauthority')
    
    # Start Chromium in full-screen mode using the current X server session
    subprocess.Popen([
        'chromium-browser', '--no-sandbox', '--start-fullscreen', url
    ], env={"DISPLAY": display, "XAUTHORITY": xauthority})

# API endpoint to receive POST request with URL
@app.route('/open-url', methods=['POST'])
def open_url():
    data = request.json
    url = data.get('url')
    if url:
        load_website(url)
        return jsonify({"status": "success", "message": f"Opening {url}"}), 200
    else:
        return jsonify({"status": "error", "message": "No URL provided"}), 400

if __name__ == '__main__':
    # Start the Flask server
    app.run(host='0.0.0.0', port=$PORT)
EOF

# Ensure the script is executable
sudo chmod +x $INSTALL_DIR/web_display_api.py

# Create a systemd service file for the app
sudo cat << EOF > /etc/systemd/system/web_display_api.service
[Unit]
Description=Web Display API to open websites in fullscreen browser
After=network.target

[Service]
ExecStart=/usr/bin/python3 $INSTALL_DIR/web_display_api.py
WorkingDirectory=$INSTALL_DIR
Restart=always
User=$USERNAME
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/$USERNAME/.Xauthority

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd manager configuration and enable the service
sudo systemctl daemon-reload
sudo systemctl enable web_display_api.service
sudo systemctl start web_display_api.service

# Get the machine's IP address
IP_ADDRESS=$(get_ip_address)

# Display final success message with instructions
echo "Installation complete. The Web Display API is running on port $PORT and will start automatically on boot."
echo ""
echo "You can make POST requests to the following endpoint:"
echo "http://$IP_ADDRESS:$PORT/open-url"
echo ""
echo "To manually manage the Web Display API service, use the following commands:"
echo ""
echo "Start the service:"
echo "  sudo systemctl start web_display_api.service"
echo ""
echo "Stop the service:"
echo "  sudo systemctl stop web_display_api.service"
echo ""
echo "Restart the service:"
echo "  sudo systemctl restart web_display_api.service"
echo ""
echo "Check the status of the service:"
echo "  sudo systemctl status web_display_api.service"
echo ""