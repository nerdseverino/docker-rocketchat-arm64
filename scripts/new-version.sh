#!/bin/bash
set -e

# Create new version branch and update files
# Usage: ./scripts/new-version.sh 8.0.2

if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 8.0.2"
  exit 1
fi

# Always run from repo root
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

VERSION=$1

echo "🔄 Creating new version ${VERSION}..."

git checkout -b "${VERSION}"

sed -i "s/ENV RC_VERSION=.*/ENV RC_VERSION=${VERSION}/" Dockerfile
sed -i "s/RC\.[0-9]\+\.[0-9]\+\.[0-9]\+-arm64/RC.${VERSION}-arm64/g" README.md

git add .
git commit -m "Update to Rocket.Chat ${VERSION}"

echo "✅ Version ${VERSION} ready!"
echo "📤 Push with: git push origin ${VERSION}"
