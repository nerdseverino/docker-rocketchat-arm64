#!/bin/bash
set -e

# Rocket.Chat ARM64 Build Script
# Usage: ./scripts/build.sh [version]

VERSION=${1:-"8.0.1"}
IMAGE_NAME="systemcrashpoa/nerdseverino"
TAG="RC.${VERSION}-arm64"

echo "🚀 Building Rocket.Chat ${VERSION} for ARM64..."

# Update Dockerfile version
sed -i "s/ENV RC_VERSION=.*/ENV RC_VERSION=${VERSION}/" Dockerfile

# Build image
docker buildx build \
  --platform linux/arm64 \
  --tag "${IMAGE_NAME}:${TAG}" \
  --tag "${IMAGE_NAME}:latest-arm64" \
  --push \
  .

echo "✅ Build complete: ${IMAGE_NAME}:${TAG}"
