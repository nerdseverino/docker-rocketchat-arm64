#!/bin/bash
set -e

# Create new version branch and update files
# Usage: ./scripts/new-version.sh 8.0.2

if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 8.0.2"
  exit 1
fi

VERSION=$1
BRANCH_NAME="${VERSION}"

echo "🔄 Creating new version ${VERSION}..."

# Create and switch to new branch
git checkout -b "${BRANCH_NAME}"

# Update Dockerfile
sed -i "s/ENV RC_VERSION=.*/ENV RC_VERSION=${VERSION}/" Dockerfile

# Update workflow tag
sed -i "s/type=raw,value=RC\.[0-9]\+\.[0-9]\+\.[0-9]\+-arm64/type=raw,value=RC.${VERSION}-arm64/" .github/workflows/docker-publish.yml

# Update README
sed -i "s/RC\.[0-9]\+\.[0-9]\+\.[0-9]\+-arm64/RC.${VERSION}-arm64/g" README.md

# Commit changes
git add .
git commit -m "Update to Rocket.Chat ${VERSION}"

echo "✅ Version ${VERSION} ready!"
echo "📤 Push with: git push origin ${BRANCH_NAME}"
