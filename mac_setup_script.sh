#!/bin/bash

set -e

# === CONFIGURATION ===
USERNAME="student"
PUBKEY_URL="https://raw.githubusercontent.com/MilanVives/MilanVives/main/MBP-id_rsa.pub"
SSH_DIR="/Users/$USERNAME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

echo "=== Starting SSH Setup Script ==="
echo "Deploying SSH key to user: $USERNAME"
echo ""

# Ensure the user exists
if ! id "$USERNAME" &>/dev/null; then
    echo "Error: User '$USERNAME' does not exist."
    exit 1
fi

# Create .ssh directory if it doesn’t exist
echo "Creating $SSH_DIR if missing..."
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
chown "$USERNAME":"staff" "$SSH_DIR"

# Download public key and append to authorized_keys
echo "Adding public key to authorized_keys..."
curl -fsSL "$PUBKEY_URL" >> "$AUTH_KEYS"

chmod 600 "$AUTH_KEYS"
chown "$USERNAME":"staff" "$AUTH_KEYS"

echo "Public key deployed successfully."
echo ""

# === ENABLE SSH REMOTE LOGIN ===
echo "Enabling SSH (Remote Login)..."
sudo systemsetup -setremotelogin on

# Start SSH (needed for some macOS versions)
sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist 2>/dev/null || true

echo "SSH Remote Login is enabled."
echo ""

# === GET HOSTNAME ===
HOSTNAME=$(scutil --get LocalHostName 2>/dev/null || hostname)
echo "Hostname: $HOSTNAME"
echo ""

# === GET IP ADDRESSES IN 10.0.0.0/8 ===
echo "IP addresses in the 10.0.0.0/8 range:"
ifconfig | awk '/inet / {print $2}' | grep '^10\.' || echo "No 10.x.x.x addresses found."
echo ""

echo "=== Setup Complete ==="
