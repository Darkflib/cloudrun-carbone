#!/bin/bash

# Manual deployment script for cloudrun-carbone
# This script helps deploy the service manually to Google Cloud Run

set -e

echo "☁️  Cloudrun-Carbone Manual Deployment"
echo "======================================"

# Check if gcloud is installed and authenticated
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: gcloud CLI is not installed"
    echo "   Please install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if user is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 > /dev/null; then
    echo "❌ Error: Not authenticated with gcloud"
    echo "   Please run: gcloud auth login"
    exit 1
fi

echo "✅ gcloud CLI is ready"

# Get project ID
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo "❌ Error: No project set in gcloud"
    echo "   Please run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo "✅ Using project: $PROJECT_ID"

# Check for optional license
if [ -z "$CARBONE_EE_LICENSE" ]; then
    echo "ℹ️  CARBONE_EE_LICENSE not set - deploying with Community Edition features"
    echo "   To enable Enterprise Edition features, set your license:"
    echo "   export CARBONE_EE_LICENSE=your_license_here"
    CARBONE_LICENSE_ARG=""
else
    echo "✅ CARBONE_EE_LICENSE is set - deploying with Enterprise Edition features"
    CARBONE_LICENSE_ARG="--set-env-vars CARBONE_EE_LICENSE=\"$CARBONE_EE_LICENSE\""
fi
# Set variables
IMAGE_NAME="cloudrun-carbone"
SERVICE_NAME="carbone-service"
REGION=${GCP_REGION:-"us-central1"}

echo "📦 Building and pushing image..."
gcloud builds submit --config cloudbuild.yaml --substitutions _IMAGE_NAME=$IMAGE_NAME

echo "🚀 Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image gcr.io/$PROJECT_ID/$IMAGE_NAME:latest \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated=false \
    --set-env-vars CARBONE_EE_STUDIO=true \
    $CARBONE_LICENSE_ARG \
    --port 4000 \
    --memory 1Gi \
    --cpu 1 \
    --min-instances 0 \
    --max-instances 10

# Get service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --platform=managed --region=$REGION --format='value(status.url)')

echo ""
echo "🎉 Deployment Complete!"
echo "======================="
echo "Service URL: $SERVICE_URL"
echo ""
echo "To test the service:"
echo "TOKEN=\$(gcloud auth print-identity-token)"
echo "curl -H \"Authorization: Bearer \$TOKEN\" $SERVICE_URL/version"