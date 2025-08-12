# Use the official Carbone EE image as base
FROM carbone/carbone-ee:latest

# Build arguments for metadata
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# Add OpenContainer Image metadata labels
LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.authors="gh:darkflib" \
      org.opencontainers.image.url="https://github.com/Darkflib/cloudrun-carbone" \
      org.opencontainers.image.source="https://github.com/Darkflib/cloudrun-carbone" \
      org.opencontainers.image.title="Carbone - The Most Efficient Universal Future-proof Report Generator" \
      org.opencontainers.image.description="Cloudrun packaging of the official image" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.version="${VERSION}"

# The base image already exposes port 4000 and sets up the Carbone service
# We don't need to modify any of the base image's configuration