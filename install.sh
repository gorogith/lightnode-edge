#!/bin/bash

# filepath: /home/xru/bot/forward1/setup_light_node.sh

echo "=== Layer Edge Light Node Setup Script ==="

# Update and install prerequisites
echo "Updating system and installing prerequisites..."
sudo apt update && sudo apt install -y curl build-essential golang rustc cargo

# Install risc0 toolchain
echo "Installing risc0 toolchain..."
curl -L https://risczero.com/install | bash && export PATH=$PATH:$HOME/.risc0/bin
source ~/.bashrc
rzup install

# Prompt user for .env configuration
echo "Configuring environment variables..."
read -p "Enter GRPC_URL (default: grpc.testnet.layeredge.io:9090): " GRPC_URL
GRPC_URL=${GRPC_URL:-grpc.testnet.layeredge.io:9090}

read -p "Enter CONTRACT_ADDR: " CONTRACT_ADDR
read -p "Enter ZK_PROVER_URL (default: http://127.0.0.1:3001): " ZK_PROVER_URL
ZK_PROVER_URL=${ZK_PROVER_URL:-http://127.0.0.1:3001}

read -p "Enter API_REQUEST_TIMEOUT (default: 100): " API_REQUEST_TIMEOUT
API_REQUEST_TIMEOUT=${API_REQUEST_TIMEOUT:-100}

read -p "Enter POINTS_API (default: http://127.0.0.1:8080): " POINTS_API
POINTS_API=${POINTS_API:-http://127.0.0.1:8080}

read -p "Enter PRIVATE_KEY: " PRIVATE_KEY

# Create .env file
echo "Creating .env file..."
cat <<EOL > .env
GRPC_URL=$GRPC_URL
CONTRACT_ADDR=$CONTRACT_ADDR
ZK_PROVER_URL=$ZK_PROVER_URL
API_REQUEST_TIMEOUT=$API_REQUEST_TIMEOUT
POINTS_API=$POINTS_API
PRIVATE_KEY=$PRIVATE_KEY
EOL

echo ".env file created successfully!"

# Build and run the servers
echo "Building and running the servers..."
if [ -d "risc0-merkle-service" ]; then
  cd risc0-merkle-service
  cargo build && cargo run &
  cd ..
else
  echo "Directory 'risc0-merkle-service' not found. Please clone the repository."
fi

if [ -f "light-node.go" ]; then
  go build light-node.go && ./light-node &
else
  echo "File 'light-node.go' not found. Please ensure the Light Node source code is present."
fi

echo "Setup complete! Ensure both servers are running."
