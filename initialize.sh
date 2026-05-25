#!/bin/bash
set -e

# Configuration
REPO_OWNER="ddvlamin"
REPO_NAME="dev-config"
BRANCH="${BRANCH:-main}"
PROJECT_NAME="${PROJECT_NAME:-dev-config}"

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

# Configure .gitignore
echo "-> Configuring .gitignore..."
if [ ! -f .gitignore ]; then
    touch .gitignore
    echo "   [OK] Created .gitignore file."
fi

# Ensure .ai-dotfiles and .skills are in .gitignore
for item in ".ai-dotfiles" ".skills"; do
    if ! grep -qxF "$item" .gitignore; then
        # Ensure there is a newline at the end of the file before appending
        if [ -s .gitignore ] && [ -n "$(tail -c 1 .gitignore)" ]; then
            echo "" >> .gitignore
        fi
        echo "$item" >> .gitignore
        echo "   [OK] Added $item to .gitignore."
    fi
done


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

# Modify pyproject.toml if it exists
if [ -f "pyproject.toml" ]; then
    echo "-> Modifying pyproject.toml to add required dependencies and update project name..."
    export PROJECT_NAME
    python3 << 'PYEOF'
import sys
import os
import re

deps_to_add = ["mcp", "omega-memory[server]", "httpx", "pydantic", "python-dotenv"]

if not os.path.exists("pyproject.toml"):
    sys.exit(0)

with open("pyproject.toml", "r") as f:
    pyproject_content = f.read()

# Update project name if specified
project_name = os.environ.get("PROJECT_NAME")
if project_name:
    project_match = re.search(r'\[project\]([\s\S]*?)(?=\n\s*\[|$)', pyproject_content)
    if project_match:
        project_section = project_match.group(0)
        updated_section = re.sub(
            r'(name\s*=\s*)(["\'])([^"\']*)(["\'])',
            r'\1\2' + project_name + r'\4',
            project_section,
            count=1
        )
        pyproject_content = pyproject_content.replace(project_section, updated_section)

block_match = re.search(r'dependencies\s*=\s*\[([\s\S]*?)\]', pyproject_content)

if block_match:
    block_content = block_match.group(1)

    dependencies = re.findall(r'["\']([^"\']+)["\']', block_content)

    existing_bases = {d.split('>=')[0].split('<')[0].split('==')[0].split('[')[0].strip() for d in dependencies}
    dependencies += [d for d in deps_to_add if d.split('[')[0] not in existing_bases]

    new_block = "dependencies = [\n" + ",\n".join(f'    "{dep}"' for dep in dependencies) + "\n]"

    pyproject_content = pyproject_content.replace(block_match.group(0), new_block)
    with open("pyproject.toml", "w") as f:
        f.write(pyproject_content)
    print("   [OK] pyproject.toml dependencies and project name updated.")

else:
    new_block = "dependencies = [\n" + ",\n".join(f'    "{dep}"' for dep in deps_to_add) + "\n]\n"
    project_match = re.search(r'(\[project\][^\[]*)', pyproject_content, re.DOTALL)
    if project_match:
        # Insert after the [project] section header line
        insert_pos = pyproject_content.index('\n', pyproject_content.index('[project]')) + 1
        pyproject_content = pyproject_content[:insert_pos] + new_block + pyproject_content[insert_pos:]
    else:
        pyproject_content += "\n" + new_block
    with open("pyproject.toml", "w") as f:
        f.write(pyproject_content)
    print("   [OK] dependencies block created and project name updated in pyproject.toml.")
PYEOF
fi

uv lock

# Clean up
rm -rf "$TEMP_DIR"

echo "=========================================================="
echo "Initialization Complete!"
echo "You can now open this repository in VS Code Dev Containers."
echo "=========================================================="
