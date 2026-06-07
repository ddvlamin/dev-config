#!/bin/bash
set -e

# Configuration
REPO_OWNER="ddvlamin"
REPO_NAME="dev-config"
BRANCH="${BRANCH:-main}"
PROJECT_NAME="${1:?Usage: $0 <project-name>}"

# Ensure uv is installed
if command -v uv >/dev/null 2>&1; then
    UV_CMD="uv"
elif [ -f "$HOME/.local/bin/uv" ]; then
    UV_CMD="$HOME/.local/bin/uv"
else
    echo "-> 'uv' not found. Installing uv locally..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    UV_CMD="$HOME/.local/bin/uv"
fi

echo "=========================================================="
echo "Initializing Development Environment from $REPO_OWNER/$REPO_NAME"
echo "=========================================================="

# Create temporary directory for download
TEMP_DIR=$(mktemp -d)
TARBALL_URL="https://github.com/$REPO_OWNER/$REPO_NAME/archive/refs/heads/$BRANCH.tar.gz"

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

echo "-> Setting project name in devcontainer.json..."
sed -i "s/\"name\": \".*\"/\"name\": \"$PROJECT_NAME\"/" .devcontainer/devcontainer.json
echo "   [OK] devcontainer.json name set to '$PROJECT_NAME'."

# Copy .ai-dotfiles
echo "-> Deploying .ai-dotfiles..."
if [ -d "$TEMP_DIR/extracted/.ai-dotfiles" ]; then
    rm -rf .ai-dotfiles
    cp -r "$TEMP_DIR/extracted/.ai-dotfiles" ./
    echo "   [OK] .ai-dotfiles folder updated."
else
    echo "   [WARNING] .ai-dotfiles folder not found in source repository."
fi

# Copy .skills
echo "-> Deploying .skills..."
if [ -d "$TEMP_DIR/extracted/.skills" ]; then
    rm -rf .skills
    cp -r "$TEMP_DIR/extracted/.skills" ./
    echo "   [OK] .skills folder updated."
else
    echo "   [WARNING] .skills folder not found in source repository."
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

# Copy pyproject.toml from tarball if it doesn't exist locally
if [ ! -f "pyproject.toml" ]; then
    echo "-> No pyproject.toml found, copying from repository..."
    if [ -f "$TEMP_DIR/extracted/pyproject.toml" ]; then
        cp "$TEMP_DIR/extracted/pyproject.toml" ./
        echo "   [OK] pyproject.toml copied from repository."
    else
        echo "   [WARNING] pyproject.toml not found in source repository either, skipping."
    fi
fi

echo "-> Setting project name in pyproject.toml..."
sed -i "s/^name = \".*\"/name = \"$PROJECT_NAME\"/" pyproject.toml
echo "   [OK] pyproject.toml name set to '$PROJECT_NAME'."

# Copy AGENTS.md from tarball if it doesn't exist locally
if [ ! -f "AGENTS.md" ]; then
    echo "-> No AGENTS.md found, copying from repository..."
    if [ -f "$TEMP_DIR/extracted/AGENTS.md" ]; then
        cp "$TEMP_DIR/extracted/AGENTS.md" ./
        echo "   [OK] AGENTS.md copied from repository."
    else
        echo "   [WARNING] AGENTS.md not found in source repository either, skipping."
    fi
fi

"$UV_CMD" lock

# Clean up
rm -rf "$TEMP_DIR"

echo "=========================================================="
echo "Initialization Complete!"
echo "You can now open this repository in VS Code Dev Containers."
echo "=========================================================="
