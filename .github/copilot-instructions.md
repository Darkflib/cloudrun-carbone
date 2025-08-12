# Cloudrun-Carbone

Google Cloud Run deployment of Carbone Enterprise Edition for programmatic document generation. This repository packages the official Carbone EE Docker image for deployment on Google Cloud Run with authentication protection and automated CI/CD.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### **CRITICAL BUILD AND DEPLOYMENT TIMEOUTS**
- **Docker build**: Takes 8-15 seconds (base image is 698MB). NEVER CANCEL. Set timeout to 5+ minutes.
- **Cloud Build**: Takes 2-5 minutes including image push. NEVER CANCEL. Set timeout to 10+ minutes.
- **Cloud Run deployment**: Takes 1-2 minutes. NEVER CANCEL. Set timeout to 5+ minutes.
- **Container startup**: Takes 5-10 seconds. Service listens on port 4000.

### Bootstrap and Build
**Prerequisites**: Docker must be installed and running.

1. **Clone and setup repository**:
   ```bash
   git clone https://github.com/Darkflib/cloudrun-carbone.git
   cd cloudrun-carbone
   ```

2. **Build Docker image locally**:
   ```bash
   docker build \
     --build-arg BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
     --build-arg VCS_REF=$(git rev-parse HEAD 2>/dev/null || echo "local") \
     --build-arg VERSION=$(git rev-parse --short HEAD 2>/dev/null || echo "local") \
     -t cloudrun-carbone:local .
   ```
   - **Build time**: ~8 seconds on cached runs, up to 60 seconds on first run
   - **Image size**: ~698MB
   - **NEVER CANCEL**: Set timeout to 5+ minutes

### Local Development and Testing

3. **Run locally for development**:
   ```bash
   # Optional: Set license for Enterprise Edition features
   export CARBONE_EE_LICENSE=your_license_here
   ./run-local.sh
   ```
   - **Requirements**: None (runs Community Edition without license)
   - **Optional**: Valid Carbone EE license for Enterprise features
   - **Service URL**: http://localhost:4000
   - **Startup time**: 5-10 seconds
   - **Studio interface**: Available at root URL (/) when CARBONE_EE_STUDIO=true

4. **Test the service manually**:
   ```bash
   # Start service in background (Community Edition - no license required)
   docker run --rm -d -p 4000:4000 \
     -e CARBONE_EE_STUDIO=true \
     cloudrun-carbone:local
   
   # OR with Enterprise Edition license
   # CARBONE_EE_LICENSE=test_license docker run --rm -d -p 4000:4000 \
   #   -e CARBONE_EE_LICENSE="test_license" \
   #   -e CARBONE_EE_STUDIO=true \
   #   cloudrun-carbone:local
   
   # Test endpoints
   curl -s http://localhost:4000/                    # Studio interface (200)
   curl -s -w "Status: %{http_code}\n" http://localhost:4000/render  # API endpoint (404 without template)
   
   # Stop container
   docker stop $(docker ps -q --filter ancestor=cloudrun-carbone:local)
   ```

### Google Cloud Deployment

5. **Manual deployment**:
   ```bash
   # Prerequisites: gcloud CLI installed and authenticated
   # Optional: Set license for Enterprise Edition features
   export CARBONE_EE_LICENSE=your_license_here
   export GCP_REGION=us-central1  # optional, defaults to us-central1
   ./deploy-manual.sh
   ```
   - **Build time**: 2-5 minutes via Cloud Build. NEVER CANCEL. Set timeout to 10+ minutes.
   - **Deploy time**: 1-2 minutes. NEVER CANCEL. Set timeout to 5+ minutes.

6. **Automated deployment** (GitHub Actions):
   - **Triggers**: Push to `main` branch or manual workflow dispatch
   - **Build time**: 3-8 minutes total. NEVER CANCEL.
   - **Required secrets**: `GCP_SA_KEY`, `CARBONE_EE_LICENSE`
   - **Required variables**: `GCP_PROJECT_ID`, `GCP_REGION`

## Validation Scenarios

### **MANDATORY Testing After Changes**
**ALWAYS run these validation steps after making any changes**:

1. **Build validation**:
   ```bash
   # Test Docker build (set 5+ minute timeout)
   docker build -t cloudrun-carbone:test .
   ```

2. **Container startup validation**:
   ```bash
   # Test container starts successfully (Community Edition)
   docker run --rm -d -p 4000:4000 \
     -e CARBONE_EE_STUDIO=true \
     cloudrun-carbone:test
   
   # Verify service responds (wait 10 seconds for startup)
   sleep 10
   curl -f http://localhost:4000/ || echo "Service failed to start"
   
   # Clean up
   docker stop $(docker ps -q --filter ancestor=cloudrun-carbone:test)
   ```

3. **Configuration validation**:
   ```bash
   # Verify scripts are executable and functional
   ./run-local.sh  # Should show license info message and proceed with build
   ./deploy-manual.sh  # Should fail with gcloud config error - expected
   ```

4. **Cloud Build configuration**:
   ```bash
   # Validate cloudbuild.yaml syntax
   gcloud builds submit --config cloudbuild.yaml --substitutions _IMAGE_NAME=test --dry-run
   ```

## Common Tasks and Troubleshooting

### Build Issues
- **"Unable to find image 'carbone/carbone-ee:latest'"**: Docker is not running or cannot access Docker Hub
- **Build takes longer than expected**: Normal for first run (downloading 698MB base image)
- **OpenSSL warnings in container**: Expected behavior, does not affect functionality

### Deployment Issues
- **"gcloud not found"**: Install Google Cloud SDK
- **"No project set"**: Run `gcloud config set project YOUR_PROJECT_ID`
- **"Invalid license"**: Service will run in Community Edition mode (limited features)

### Configuration Requirements

**GitHub Repository Secrets** (Settings → Secrets and variables → Actions):
- `GCP_SA_KEY`: Google Cloud Service Account JSON key
- `CARBONE_EE_LICENSE`: Carbone Enterprise Edition license (optional - runs Community Edition if not provided)

**GitHub Repository Variables**:
- `GCP_PROJECT_ID`: Google Cloud Project ID
- `GCP_REGION`: Cloud Run deployment region (default: us-central1)

**Google Cloud APIs** (must be enabled):
- Cloud Run API
- Cloud Build API
- Container Registry API

**Service Account Roles** (for GCP_SA_KEY):
- Cloud Run Developer
- Cloud Build Editor
- Storage Admin

## Key Project Structure

```
.
├── Dockerfile                    # Extends carbone/carbone-ee:latest
├── cloudbuild.yaml              # Google Cloud Build configuration
├── .github/workflows/deploy.yml # GitHub Actions CI/CD
├── run-local.sh                 # Local development script
├── deploy-manual.sh             # Manual deployment script
├── .dockerignore               # Docker build exclusions
└── README.md                   # Project documentation
```

## Critical Service Details

- **Base Image**: `carbone/carbone-ee:latest` (Carbone v4.25.11)
- **Port**: 4000 (HTTP)
- **Memory**: 1Gi (Cloud Run default)
- **CPU**: 1 vCPU (Cloud Run default)
- **Authentication**: Required for Cloud Run (use `gcloud auth print-identity-token`)
- **Studio Interface**: Enabled by default (`CARBONE_EE_STUDIO=true`)
- **License**: Enterprise Edition optional for additional features (defaults to Community Edition)

## API Testing

**Authentication for Cloud Run**:
```bash
# Get identity token
TOKEN=$(gcloud auth print-identity-token)

# Test deployed service
curl -H "Authorization: Bearer $TOKEN" https://YOUR_SERVICE_URL/
```

**Local Testing** (no auth required):
```bash
curl http://localhost:4000/        # Studio interface
curl http://localhost:4000/render  # API endpoint (requires template)
```

## Expected Behavior

**Successful startup logs**:
```
Carbone On-Premise: v4.25.11
Studio is on
Carbone webserver is started and listens on port 4000
LibreOffice converter is ready
```

**Warning messages** (expected and non-blocking):
- OpenSSL key generation warnings
- Invalid license warnings (when using test license)

**Service endpoints**:
- `/` - Returns Carbone Studio HTML interface (200)
- `/render/{templateId}` - Document generation API
- Various other Carbone API endpoints as per official documentation