# HTTPS Server Setup Script

## Overview
This script sets up a secure HTTPS server on Ubuntu using Apache2 and a self-signed SSL certificate. It also deploys a futuristic landing page styled in HTML and CSS. Designed for simplicity and visual clarity, the script includes a stylish terminal interface with clean feedback and icons for a user-friendly experience.

## Features
- 📦 Installs and enables Apache2 web server
- 🔐 Enables SSL support and generates a self-signed certificate
- 🌐 Creates a stylish, futuristic web page served over HTTPS
- 🧼 Clean and colorized terminal output
- 💻 Minimal interaction needed — fully automated

## Usage
### 1. Clone the Repository
```bash
git clone https://github.com/EveRoy/http-server-setup.git
cd http-server-setup
```

### 2. Make the Script Executable
```bash
chmod +x https_server_setup.sh
```

### 3. Run the Script
```bash
./https_server_setup.sh
```

The script will perform the full setup and display progress in a human-friendly way.

## Customizing the Web Page
The default landing page displays:
```
Web Fundamentals is fun!
```
If you wish to use a different web page:
1. Open the script.
2. Scroll to the `setup_content` function.
3. Replace the HTML inside the `cat > /var/www/html/index.html` section with your own HTML content.

Alternatively, you can manually replace the file:
```bash
sudo nano /var/www/html/index.html
```
Paste your custom HTML and save.

## Requirements
- Ubuntu/Debian system
- Internet connection (to install packages)
- `figlet` (optional, for fancy title banner)

The script will auto-install all dependencies if missing.

## Disclaimer
This is a demo script for learning and internal testing purposes. Do not use self-signed certificates in production.

## License
MIT License

---
Made with ❤️ for anyone who wants to learn and look cool doing it.
