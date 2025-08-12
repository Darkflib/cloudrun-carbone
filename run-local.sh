#!/bin/bash

# Local development script for cloudrun-carbone
# This script helps test the Carbone service locally

set -e

echo "🚀 Cloudrun-Carbone Local Development"
echo "====================================="

# Check for optional license
if [ -z "$CARBONE_EE_LICENSE" ]; then
    echo "ℹ️  CARBONE_EE_LICENSE not set - running with Community Edition features"
    echo "   To enable Enterprise Edition features, set your license:"
    echo "   export CARBONE_EE_LICENSE=your_license_here"
    CARBONE_LICENSE_ARG=""
else
    echo "✅ CARBONE_EE_LICENSE is set - running with Enterprise Edition features"
    CARBONE_LICENSE_ARG="-e CARBONE_EE_LICENSE=\"$CARBONE_EE_LICENSE\""
fi

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
    $CARBONE_LICENSE_ARG \
    -e CARBONE_EE_STUDIO=true \
    cloudrun-carbone:local