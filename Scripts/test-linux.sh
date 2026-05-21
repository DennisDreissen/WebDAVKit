#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

COMPOSE_FILE="docker-compose.yml"
BUILD_PATH=".build-linux"
NETWORK_NAME="webdavclient_test_network"

cleanup() {
    echo "==> Stopping WebDAV..."
    docker compose -f "$COMPOSE_FILE" down -v
    rm -rf "$BUILD_PATH"
}

trap cleanup EXIT

rm -rf "$BUILD_PATH"

echo "==> Starting WebDAV..."
docker compose -f "$COMPOSE_FILE" up -d --wait webdav

echo "==> Running Swift tests on Linux Swift 6.0 container..."
docker run --rm \
    --network "$NETWORK_NAME" \
    -v "$PWD":/pkg \
    -w /pkg \
    -e WEBDAV_BASE_URL=http://webdav:80 \
    "swift:6.0" \
    swift test --build-path "$BUILD_PATH" "$@"

rm -rf "$BUILD_PATH"

echo "==> Running Swift tests on Linux Swift 6.3 container..."
docker run --rm \
    --network "$NETWORK_NAME" \
    -v "$PWD":/pkg \
    -w /pkg \
    -e WEBDAV_BASE_URL=http://webdav:80 \
    "swift:6.3" \
    swift test --build-path "$BUILD_PATH" "$@"
