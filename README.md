# dev-config

Personal developer configuration repository — a single source of truth for devcontainer setup, AI assistant dotfiles, skills, agents, and prompt instructions.

## What's in here

| Directory | Purpose |
|-----------|---------|
| [`.ai-dotfiles/`](.ai-dotfiles/) | Symlink-managed configs for AI CLIs (Claude, Gemini, Codex, Vibe) via GNU Stow |
| [`.skills/`](.skills/) | Reusable skill files for Antigravity CLI (code review, git, TDD, refactoring, …) |
| [`.prompts/`](.prompts/) | Shared instruction files for code review, task implementation, memory bank, etc. |
| [`.devcontainer/`](.devcontainer/) | VS Code Dev Container definition (Dockerfile + devcontainer.json) |

## Quick start

### Dev Container
Open this repo in VS Code and choose **Reopen in Container**. The container installs all Python dependencies via `uv sync`.

### Workspace Initialization
To initialize a new or existing project directory on your host machine using the templates in this repository (deploying `.devcontainer`, `.dockerignore`, `.ai-dotfiles`, `.skills`, configuring `.gitignore`, and configuring Python dependencies), run the following command from the root of the target project directory:

```bash
curl -sSL https://raw.githubusercontent.com/ddvlamin/dev-config/main/initialize.sh | bash
```

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
To enable smooth GitHub interaction, configure your credentials by running `gh auth login`, and manually retrieve your token with `gh auth token` and ensure it is saved in your `oauth_token` field inside `~/.config/gh/hosts.yml`.

Example `~/.config/gh/hosts.yml`:
```yaml
github.com:
    git_protocol: https
    users:
        <YOUR_GITHUB_USER>s:
    user: <YOUR_GITHUB_USER>
    oauth_token: <YOUR_TOKEN>
```



### AI dotfiles
Configs for AI CLIs live in [`.ai-dotfiles/`](.ai-dotfiles/) and are managed with [GNU Stow](https://www.gnu.org/software/stow/):

```bash
cd .ai-dotfiles
stow claude gemini codex vibe   # symlink all
stow claude                     # or pick individual ones
```

See [`.ai-dotfiles/README.md`](.ai-dotfiles/README.md) for full details and security notes.

### Skills
Skills extend agentic CLIs with specialized behaviours (TDD, git commits, deep research, …). They live in [`.skills/`](.skills/) and are picked up automatically when `.skills/` is configured as the skills directory for your agentic CLI.

## Dependencies

- Python ≥ 3.12 (managed via [`uv`](https://github.com/astral-sh/uv))
- [GNU Stow](https://www.gnu.org/software/stow/) for dotfile symlinking
- [VS Code](https://code.visualstudio.com/) + Dev Containers extension (optional but recommended)

## Security

Never commit API keys or tokens. See [`.ai-dotfiles/README.md`](.ai-dotfiles/README.md#security-warning) for which files are `.gitignore`d per CLI.
