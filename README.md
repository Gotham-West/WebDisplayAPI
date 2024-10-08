
# Web Display API

**Web Display API** is a simple Flask-based application for Raspberry Pi that allows you to load a website URL in a full-screen Chromium browser via a POST API request. The app runs as a system service, ensuring it starts automatically on boot and is easily manageable.

## Features
- Load any URL into a full-screen Chromium browser on a Raspberry Pi.
- Runs automatically on boot as a system service.
- Customizable port and installation directory.
- API-driven: Control the display using POST requests.

## Requirements
- Raspberry Pi running a version of Raspbian with network access.
- Installed packages: Python 3, Flask, Chromium Browser, X server.

The installation script will handle these automatically.

## Installation

### 1. Install the App
You can install the app using the following one-liner command:

```bash
curl -sSL https://raw.githubusercontent.com/gotham-west/webdisplayapi/main/install.sh | bash
```

### 2. Customize Installation

During the installation process, you will be prompted to:
- Choose the port number for the API (default: 5000).
- Specify the installation directory (default: `/etc/web_display_api`).
- Specify the username under which the service will run (default: the current user).

### 3. Post-Installation

After installation, the **Web Display API** service will be running and configured to start on boot.

You will see output similar to the following:

```bash
Installation complete. The Web Display API is running on port 5000 and will start automatically on boot.

You can make POST requests to the following endpoint:
http://192.168.1.50:5000/open-url

To manually manage the Web Display API service, use the following commands:

Start the service:
  sudo systemctl start web_display_api.service

Stop the service:
  sudo systemctl stop web_display_api.service

Restart the service:
  sudo systemctl restart web_display_api.service

Check the status of the service:
  sudo systemctl status web_display_api.service
```

## API Usage

### Endpoint: `/open-url`
- **Method**: `POST`
- **Content-Type**: `application/json`
- **Body**:
  - `url`: The website URL to open.

### Example POST request:

```bash
curl -X POST http://<RaspberryPi_IP>:5000/open-url -H "Content-Type: application/json" -d '{"url": "https://example.com"}'
```

This will open `https://example.com` in a full-screen Chromium browser window on the Raspberry Pi.

## Managing the Service

You can manually control the **Web Display API** service using the following commands:

- **Start the service**:
  ```bash
  sudo systemctl start web_display_api.service
  ```

- **Stop the service**:
  ```bash
  sudo systemctl stop web_display_api.service
  ```

- **Restart the service**:
  ```bash
  sudo systemctl restart web_display_api.service
  ```

- **Check the status of the service**:
  ```bash
  sudo systemctl status web_display_api.service
  ```

## Troubleshooting

- **Display Issues**: Ensure that the X server is running, and Chromium has permission to display content.
- **Service Issues**: If the service fails to start or behaves unexpectedly, check the service logs:
  ```bash
  sudo journalctl -u web_display_api.service
  ```

## Uninstall

To uninstall the **Web Display API** service, stop the service, disable it, and remove its files:

```bash
sudo systemctl stop web_display_api.service
sudo systemctl disable web_display_api.service
sudo rm /etc/systemd/system/web_display_api.service
sudo rm -rf /path/to/your/installation_directory
sudo systemctl daemon-reload
```

Make sure to replace `/path/to/your/installation_directory` with the actual installation path.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
