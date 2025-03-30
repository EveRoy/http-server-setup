#!/bin/bash


print() {
    echo -e "\033[1;36m[$(date '+%H:%M:%S')]\033[0m $1"
}

display_banner() {
    if command -v figlet > /dev/null; then
        clear
        echo -e "\033[1;32m"
        figlet -f slant " HTTPS Server - Setup "
        echo -e "\033[0m"
    else
        echo "[INFO] figlet not found. Skipping banner."
    fi
}

section() {
    local message=$1
    local width=60
    local border_line=$(printf '%*s' "$width" '' | tr ' ' '=')

    echo -e "\n\033[1;36m$border_line\033[0m"
    echo -e "\033[1;36m🔹  $(date '+%H:%M:%S')  |  $message\033[0m"
    echo -e "\033[1;36m$border_line\033[0m"
}

install_apache() {
    section "Installing Apache"
    print "🔄 Updating system packages..."
    sudo apt update -y > /dev/null 2>&1

    print "📦 Installing Apache web server..."
    sudo apt install apache2 -y > /dev/null 2>&1

    print "🔍 Checking Apache service status..."
    if systemctl is-active --quiet apache2; then
        print "✅ Apache is already running."
    else
        print "🚀 Starting Apache..."
        sudo systemctl start apache2 > /dev/null 2>&1
        if systemctl is-active --quiet apache2; then
            print "✅ Apache started."
        else
            print "❌ Apache failed to start."
            exit 1
        fi
    fi

    print "🔒 Enabling Apache on boot..."
    sudo systemctl enable apache2 > /dev/null 2>&1
}

verify_apache() {
    section "Verifying Apache"
    print "🔍 Checking HTTP response..."
    if curl -s http://localhost | grep -q 'html'; then
        print "✅ Apache is serving HTTP content."
    else
        print "❌ Apache is not serving properly."
        exit 1
    fi
}

setup_content() {
    section "Setting Up Web Content"
    print "🌐 Wait..."
    sudo bash -c 'cat > /var/www/html/index.html' << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Web Fundamentals</title>
    <style>
        body {
            background-color: #0f0f0f;
            margin: 0;
            padding: 0;
            font-family: "Orbitron", sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            color: #00ffcc;
            text-shadow: 0 0 10px #00ffcc;
        }
        h1 {
            font-size: 3em;
            text-align: center;
        }
        @import url('https://fonts.googleapis.com/css2?family=Orbitron:wght@500&display=swap');
    </style>
</head>
<body>
    <h1>Web Fundamentals is fun!</h1>
</body>
</html>
EOF
    print "✅ Web content ready."
}

enable_ssl_module() {
    section "Enabling SSL Module"
    print "🔐 Enabling SSL support..."
    sudo a2enmod ssl > /dev/null 2>&1
}

create_ssl_directory() {
    section "Creating SSL Directory"
    print "📁 Preparing SSL directory..."
    sudo mkdir -p /etc/apache2/ssl
    sudo chown -R www-data:www-data /etc/apache2/ssl
    sudo chmod -R 700 /etc/apache2/ssl
}

generate_ssl_certificates() {
    section "Generating SSL Certificates"
    print "🔏 Creating self-signed certificate..."
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/apache2/ssl/selfsigned.key \
        -out /etc/apache2/ssl/selfsigned.crt
}

create_https_config() {
    section "Creating HTTPS Configuration"
    print "📝 Writing virtual host for HTTPS..."
    sudo bash -c 'cat > /etc/apache2/sites-available/https-selfsigned.conf' << EOF
<VirtualHost *:443>
    ServerAdmin admin@localhost
    DocumentRoot /var/www/html
    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/selfsigned.crt
    SSLCertificateKeyFile /etc/apache2/ssl/selfsigned.key

    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
    print "✅ HTTPS virtual host created."
}

enable_https_site() {
    section "Enabling HTTPS Site"
    print "📡 Enabling new HTTPS site..."
    sudo a2ensite https-selfsigned.conf > /dev/null 2>&1
    print "🔄 Reloading Apache..."
    sudo systemctl reload apache2 > /dev/null 2>&1 && print "✅ Apache reloaded." || print "❌ Failed to reload Apache."
}

validate_config() {
    section "Validating Configuration"
    print "🧪 Checking Apache configuration syntax..."
    if sudo apache2ctl configtest | grep 'Syntax OK'; then
        print "✅ Syntax is valid."
    else
        print "⚠️ Fixing missing ServerName..."
        echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf > /dev/null
        sudo apache2ctl configtest || { print "❌ Config still invalid."; exit 1; }
        print "✅ Configuration fixed."
    fi
}

verify_https() {
    section "Verifying HTTPS"
    print "🔍 Testing HTTPS response..."
    if curl -k https://localhost | grep -q 'html'; then
        print "✅ Apache is serving HTTPS content."
    else
        print "❌ HTTPS test failed."
        exit 1
    fi
}

main() {
    display_banner
    install_apache
    verify_apache
    setup_content
    enable_ssl_module
    create_ssl_directory
    generate_ssl_certificates
    create_https_config
    enable_https_site
    validate_config
    verify_https
    print "🎉 Setup complete. Your HTTPS server is ready!"
}

main
