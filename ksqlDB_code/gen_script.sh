#!/bin/bash
set -e

# Usage function
usage() {
    echo "Usage: $0 <username>"
    echo "Example: $0 user01"
    exit 1
}

# Check if username argument is provided
if [ -z "$1" ]; then
    usage
fi

USERNAME=$1
GEN_DIR="gen_script"
ORIG_DIR="original_script"

# Check if original_script exists
if [ ! -d "$ORIG_DIR" ]; then
    echo "Error: Directory '$ORIG_DIR' does not exist."
    exit 1
fi

# Remove existing gen_script directory if it exists
if [ -d "$GEN_DIR" ]; then
    echo "Removing existing '$GEN_DIR' directory..."
    rm -rf "$GEN_DIR"
fi

# Create new gen_script directory
echo "Creating '$GEN_DIR' directory..."
mkdir -p "$GEN_DIR"

# Copy contents from original_script to gen_script
echo "Copying files from '$ORIG_DIR' to '$GEN_DIR'..."
# Using cp -R . to copy all files including hidden ones internally
cp -R "$ORIG_DIR/." "$GEN_DIR/"

# Replace <USER> with the provided username in all files
echo "Replacing <USER> with '$USERNAME' in all files..."
# Use find to locate files and sed to replace the string in place
# Using # as delimiter to avoid issues with slashes in username
find "$GEN_DIR" -type f -exec sed -i "s#<USER>#$USERNAME#g" {} +

echo "Success! Scripts generated in '$GEN_DIR' for user: $USERNAME"
