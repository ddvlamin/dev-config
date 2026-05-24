#!/bin/bash
set -e

# Configuration
REPO_OWNER="ddvlamin"
REPO_NAME="dev-config"
BRANCH="${BRANCH:-main}"

echo "=========================================================="
echo "Initializing Development Environment from $REPO_OWNER/$REPO_NAME"
echo "=========================================================="

# Create temporary directory for download
TEMP_DIR=$(mktemp -d)
TARBALL_URL="https://github.com/$REPO_OWNER/$REPO_NAME/tarball/$BRANCH"

echo "-> Downloading repository archive from GitHub ($BRANCH)..."
if ! curl -sSL "$TARBALL_URL" -o "$TEMP_DIR/archive.tar.gz"; then
    echo "ERROR: Failed to download archive from $TARBALL_URL"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "-> Extracting archive..."
mkdir -p "$TEMP_DIR/extracted"
tar -xzf "$TEMP_DIR/archive.tar.gz" -C "$TEMP_DIR/extracted" --strip-components=1

# Copy .devcontainer
echo "-> Deploying .devcontainer..."
if [ -d "$TEMP_DIR/extracted/.devcontainer" ]; then
    rm -rf .devcontainer
    cp -r "$TEMP_DIR/extracted/.devcontainer" ./
    echo "   [OK] .devcontainer folder updated."
else
    echo "   [WARNING] .devcontainer folder not found in source repository."
fi

# Copy ai-dotfiles
echo "-> Deploying ai-dotfiles..."
if [ -d "$TEMP_DIR/extracted/ai-dotfiles" ]; then
    rm -rf ai-dotfiles
    cp -r "$TEMP_DIR/extracted/ai-dotfiles" ./
    echo "   [OK] ai-dotfiles folder updated."
else
    echo "   [WARNING] ai-dotfiles folder not found in source repository."
fi

# Copy .dockerignore
echo "-> Deploying .dockerignore..."
if [ -f "$TEMP_DIR/extracted/.dockerignore" ]; then
    cp "$TEMP_DIR/extracted/.dockerignore" ./
    echo "   [OK] .dockerignore updated."
else
    # Create a default fallback .dockerignore if it didn't exist in the downloaded archive
    cat << 'EOF' > .dockerignore
.venv
__pycache__
*.pyc
.git
.github
.vscode
.gemini
node_modules
EOF
    echo "   [OK] Default .dockerignore created."
fi

# Modify pyproject.toml if it exists
if [ -f "pyproject.toml" ]; then
    echo "-> Modifying pyproject.toml to add required dependencies..."
    python3 -c '
import sys
import os
import re

deps_to_add = ["mcp", "omega-memory[server]", "httpx", "pydantic", "python-dotenv"]

if not os.path.exists("pyproject.toml"):
    sys.exit(0)

with open("pyproject.toml", "r") as f:
    pyproject_content = f.read()

block_match = re.search(r'dependencies\s*=\s*\[([\s\S]*?)\n\s*\]', pyproject_content)                                      
                                                                                                                        
if block_match:                                                                                                       
    block_content = block_match.group(1)    
                                                                                                                                                                                          
    dependencies = re.findall(r'["\']([^"\']+)["\']', block_content)                                                                                                                                                               
    dependencies += deps_to_add

    new_block = "\n" + ",\n".join(f'    "{dep}"' for dep in dependencies)

    pyproject_content = re.sub(
        r'(dependencies\s*=\s*\[)([\s\S]*?)(\n\s*\])',
        r'\1' + new_block + r'\3',
        pyproject_content
    )
    with open("pyproject.toml", "w") as f:
        f.write(pyproject_content)
                                                                                                                                                                                               
else:                                                                                                                 
    print("No dependencies block found.")
'
fi

uv lock

# Clean up
rm -rf "$TEMP_DIR"

echo "=========================================================="
echo "Initialization Complete!"
echo "You can now open this repository in VS Code Dev Containers."
echo "=========================================================="
