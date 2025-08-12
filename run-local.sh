#!/bin/bash

# Local development script for cloudrun-carbone
# This script helps test the Carbone service locally

set -e

echo "🚀 Cloudrun-Carbone Local Development"
echo "====================================="

# Check if required environment variables are set
if [ -z "$CARBONE_EE_LICENSE" ]; then
    echo "❌ Error: CARBONE_EE_LICENSE environment variable is required"
    echo "   Please set your Carbone Enterprise Edition license:"
    echo "   export CARBONE_EE_LICENSE=your_license_here"
    exit 1
fi

echo "✅ CARBONE_EE_LICENSE is set"

# Build the image
echo "🔨 Building Docker image..."
docker build \
    --build-arg BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
    --build-arg VCS_REF=$(git rev-parse HEAD 2>/dev/null || echo "local") \
    --build-arg VERSION=$(git rev-parse --short HEAD 2>/dev/null || echo "local") \
    -t cloudrun-carbone:local .

echo "✅ Image built successfully"

# Run the container
echo "🚀 Starting Carbone service on port 4000..."
echo "   Access the service at: http://localhost:4000"
echo "   Press Ctrl+C to stop"

docker run --rm -it \
    -p 4000:4000 \
    -e CARBONE_EE_LICENSE="$CARBONE_EE_LICENSE" \
    -e CARBONE_EE_STUDIO=true \
    cloudrun-carbone:local