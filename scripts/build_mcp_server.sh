#!/usr/bin/env bash

# Script to build an MCP server Docker image from a local repository path.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Base path for MCP server repositories (relative to the monorepo root)
# This script assumes it's located in something like 'monorepo/maxos/scripts/'
# So, '../../' would point to 'monorepo/'
MONOREPO_ROOT_RELATIVE_TO_SCRIPT="../../"
DEFAULT_IMAGE_TAG="latest"

# --- Helper Functions ---
print_usage() {
  echo "Usage: $0 <path_to_mcp_server_directory>"
  echo "  <path_to_mcp_server_directory>: Path to the MCP server's source code directory,"
  echo "                                    relative to the monorepo root (e.g., 'mcp-server-docker' or 'test_bed/mcp-mangopay-api')."
  echo "Example: $0 mcp-server-docker"
}

# --- Script Main Logic ---

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Error: Missing MCP server directory path."
  print_usage
  exit 1
fi

MCP_SERVER_REL_PATH="$1"
# Construct the absolute path to the monorepo root from the script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ABS_PATH="$(cd "${SCRIPT_DIR}/${MONOREPO_ROOT_RELATIVE_TO_SCRIPT}" && pwd)"
MCP_SERVER_ABS_PATH="${MONOREPO_ABS_PATH}/${MCP_SERVER_REL_PATH}"

# Derive image name from the server directory name
IMAGE_NAME=$(basename "${MCP_SERVER_REL_PATH}")
IMAGE_TAG="${DEFAULT_IMAGE_TAG}"

echo "--- MCP Server Build Script ---"
echo "Monorepo Root: ${MONOREPO_ABS_PATH}"
echo "MCP Server Path: ${MCP_SERVER_ABS_PATH}"
echo "Derived Image Name: ${IMAGE_NAME}"
echo "Image Tag: ${IMAGE_TAG}"
echo "-------------------------------"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker could not be found. Please install Docker."
    exit 1
fi

# Check if the MCP server directory exists
if [ ! -d "$MCP_SERVER_ABS_PATH" ]; then
  echo "Error: MCP server directory not found at: $MCP_SERVER_ABS_PATH"
  exit 1
fi

# Navigate to the MCP server directory
cd "$MCP_SERVER_ABS_PATH"

# Check for Dockerfile and build
if [ -f "Dockerfile" ]; then
  echo "Dockerfile found. Attempting to build Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
  docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
  echo "Docker image build process finished for ${IMAGE_NAME}:${IMAGE_TAG}."
  echo "To run the container (example, may need specific ports/volumes):"
  echo "  docker run --rm -i ${IMAGE_NAME}:${IMAGE_TAG}"
# Add other build methods here if needed (e.g., Makefile, pyproject.toml with poetry/pdm)
# elif [ -f "Makefile" ]; then
#   echo "Makefile found. Attempting to build with 'make'..."
#   make
#   echo "Build process with Makefile finished."
# elif [ -f "pyproject.toml" ]; then
#   echo "pyproject.toml found. Further logic needed to determine build system (e.g., poetry, pdm)."
else
  echo "Error: No known build method found (e.g., Dockerfile) in ${MCP_SERVER_ABS_PATH}"
  # Go back to the original directory before exiting
  cd "$SCRIPT_DIR"
  exit 1
fi

# Go back to the original directory from where the script was called
cd "$SCRIPT_DIR"

echo "--- MCP Server Build Script Finished ---"