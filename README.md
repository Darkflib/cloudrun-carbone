# cloudrun-carbone

Cloudrun packaging of the official Carbone image for programmatic document generation.

**Carbone** is the most efficient universal future-proof report generator that enables you to create any document or report from templates and JSON data.

## Overview

This repository provides a containerized version of Carbone Enterprise Edition (EE) optimized for deployment on Google Cloud Run. The service exposes Carbone's API for generating documents programmatically with authentication protection.

## Features

- Based on official `carbone/carbone-ee` Docker image
- Optimized for Google Cloud Run deployment
- Authentication-protected endpoint
- Automated CI/CD with GitHub Actions
- Configurable Carbone Studio integration
- Enterprise Edition features support

## Prerequisites

Before deploying, ensure you have:

1. **Google Cloud Project** with the following APIs enabled:
   - Cloud Run API
   - Cloud Build API
   - Container Registry API

2. **Carbone Enterprise Edition License** (set `CARBONE_EE_LICENSE` secret)

3. **Google Cloud Service Account** with the following roles:
   - Cloud Run Developer
   - Cloud Build Editor
   - Storage Admin (for Container Registry)

## Required Variables and Secrets

### Repository Variables
Set these in your GitHub repository settings under **Settings → Secrets and variables → Actions → Variables**:

| Variable | Description | Example |
|----------|-------------|---------|
| `GCP_PROJECT_ID` | Your Google Cloud Project ID | `my-project-123` |
| `GCP_REGION` | Cloud Run deployment region | `us-central1` |

### Repository Secrets
Set these in your GitHub repository settings under **Settings → Secrets and variables → Actions → Secrets**:

| Secret | Description | How to obtain |
|--------|-------------|---------------|
| `GCP_SA_KEY` | Service Account JSON key | Create in GCP Console → IAM → Service Accounts |
| `CARBONE_EE_LICENSE` | Carbone Enterprise Edition license | Obtain from Carbone sales team |

## Deployment

### Automatic Deployment

The service deploys automatically via GitHub Actions when code is pushed to the `main` branch.

1. **Fork/Clone** this repository
2. **Set up variables and secrets** as described above
3. **Push to main branch** or trigger the workflow manually

### Manual Deployment

You can also deploy manually using the provided script or Google Cloud SDK:

#### Using the deployment script:
```bash
# Set required environment variables
export CARBONE_EE_LICENSE=your_license_here
export GCP_REGION=us-central1  # optional, defaults to us-central1

# Run the deployment script
./deploy-manual.sh
```

#### Using gcloud commands directly:
```bash
# Authenticate with Google Cloud
gcloud auth login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Build and deploy
gcloud builds submit --config cloudbuild.yaml --substitutions _IMAGE_NAME=cloudrun-carbone
gcloud run deploy carbone-service \
  --image gcr.io/YOUR_PROJECT_ID/cloudrun-carbone:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated=false \
  --set-env-vars CARBONE_EE_STUDIO=true \
  --set-env-vars CARBONE_EE_LICENSE=YOUR_LICENSE_KEY \
  --port 4000
```

## Usage

### Authentication

The Cloud Run service requires authentication. Get an identity token:

```bash
# Get identity token
TOKEN=$(gcloud auth print-identity-token)

# Use the token in requests
curl -H "Authorization: Bearer $TOKEN" \
     https://YOUR_SERVICE_URL/api/render
```

### API Endpoints

The service exposes Carbone's standard API endpoints:

- `POST /render` - Generate documents from templates
- `GET /version` - Get Carbone version information
- Additional endpoints as per Carbone EE documentation

### Example Request

```bash
# Example document generation
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "template": "base64_encoded_template",
    "data": {"name": "John Doe", "date": "2024-01-01"}
  }' \
  https://YOUR_SERVICE_URL/render
```

## Development

### Local Development

To run locally for development, use the provided script:

```bash
# Set your Carbone license
export CARBONE_EE_LICENSE=your_license_here

# Run the local development script
./run-local.sh
```

Or manually with Docker:

```bash
# Build the Docker image
docker build -t cloudrun-carbone .

# Run locally (requires Carbone license)
docker run -p 4000:4000 \
  -e CARBONE_EE_LICENSE=your_license_here \
  -e CARBONE_EE_STUDIO=true \
  cloudrun-carbone
```

### Testing

Test the deployment:

```bash
# Check service health
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
     https://YOUR_SERVICE_URL/version
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CARBONE_EE_LICENSE` | Required | Your Carbone Enterprise Edition license |
| `CARBONE_EE_STUDIO` | `true` | Enable Carbone Studio features |

### Cloud Run Configuration

The default deployment configuration:
- **Memory**: 1Gi
- **CPU**: 1 vCPU
- **Port**: 4000
- **Min instances**: 0 (scales to zero)
- **Max instances**: 10
- **Authentication**: Required

## Support

- **Carbone Documentation**: [Official Carbone Docs](https://carbone.io/documentation.html)
- **Google Cloud Run**: [Cloud Run Documentation](https://cloud.google.com/run/docs)
- **Issues**: [GitHub Issues](https://github.com/Darkflib/cloudrun-carbone/issues)

## License

This project is licensed under the terms specified in the LICENSE file. Note that Carbone Enterprise Edition requires a separate commercial license.
