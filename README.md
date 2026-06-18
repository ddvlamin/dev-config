# dev-config

Personal developer configuration repository — a single source of truth for devcontainer setup, AI assistant dotfiles, skills, agents, and prompt instructions.

## What's in here

| Directory | Purpose |
|-----------|---------|
| [`.devcontainer/`](.devcontainer/) | VS Code Dev Container definition (Dockerfile + devcontainer.json) |

## Quick start

### Dev Container
Open this repo in VS Code and choose **Reopen in Container**. The container installs all Python dependencies via `uv sync`.

### Workspace Initialization
To initialize a new project directory on your host machine, run the following command from the root of the target project directory:

```bash
curl -sSL https://raw.githubusercontent.com/ddvlamin/dev-config/main/initialize.sh | bash -s -- <project-name>
```

It will install the AI CLI's configs and skills from the repository https://github.com/ddvlamin/llm-config

*Note: You can customize the source branch by prefixing the command with `BRANCH=your-branch`.*

#### Prerequisites
Ensure the following tools are installed on your host system:
* **python**
* **curl** (for downloading the assets)
* **tar** (for extraction)
* **uv** (for dependency resolution and locking)
* **gh** (GitHub CLI, for host-level GitHub integrations and authentication)

##### Installation
* **macOS**:
  ```bash
  brew install curl python uv gh
  ```
* **Linux (Debian/Ubuntu)**:
  ```bash
  sudo apt-get update && sudo apt-get install -y curl tar python3 gh
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```

##### GitHub CLI Authentication
To enable smooth GitHub interaction, make sure your VSCode is logged in into github.

For gh in `post_setup.sh` you can export the GITHUB_TOKEN using the github credentials via your VSCode.

```
export GITHUB_TOKEN=$(printf "protocol=https\nhost=github.com\n" | git credential fill 2>&1 | grep "^password=" | cut -d= -f2)
```

This token might not have permissions to set labels or other properties of github issues. For this it will need `project` scope and you will need to request a new token for this.

### AI dotfiles
After running `initialize.sh` you will get the follwing folders with your AI CLI configurations:

- .ai-dotfiles
- .skills
- .prompts

## Dependencies

- Python ≥ 3.12 (managed via [`uv`](https://github.com/astral-sh/uv))
- [GNU Stow](https://www.gnu.org/software/stow/) for dotfile symlinking
- [VS Code](https://code.visualstudio.com/) + Dev Containers extension (optional but recommended)

## Security

Never commit API keys or tokens.
