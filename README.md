# dev-config

Personal developer configuration repository — a single source of truth for devcontainer setup, AI assistant dotfiles, skills, agents, and prompt instructions.

## What's in here

| Directory | Purpose |
|-----------|---------|
| [`ai-dotfiles/`](ai-dotfiles/) | Symlink-managed configs for AI CLIs (Claude, Gemini, Codex, Vibe) via GNU Stow |
| [`skills/`](skills/) | Reusable skill files for Antigravity CLI (code review, git, TDD, refactoring, …) |
| [`.agents/`](.agents/) | Custom agents and plugins for Antigravity CLI |
| [`prompts/`](prompts/) | Shared instruction files for code review, task implementation, memory bank, etc. |
| [`.devcontainer/`](.devcontainer/) | VS Code Dev Container definition (Dockerfile + devcontainer.json) |

## Quick start

### Dev Container
Open this repo in VS Code and choose **Reopen in Container**. The container installs all Python dependencies via `uv sync`.

### AI dotfiles
Configs for AI CLIs live in [`ai-dotfiles/`](ai-dotfiles/) and are managed with [GNU Stow](https://www.gnu.org/software/stow/):

```bash
cd ai-dotfiles
stow claude gemini codex vibe   # symlink all
stow claude                     # or pick individual ones
```

See [`ai-dotfiles/README.md`](ai-dotfiles/README.md) for full details and security notes.

### Skills
Skills extend Antigravity CLI with specialized behaviours (TDD, git commits, deep research, …). They live in [`skills/`](skills/) and are picked up automatically when `skills/` is configured as the skills directory in `.antigravitycli`.

## Dependencies

- Python ≥ 3.12 (managed via [`uv`](https://github.com/astral-sh/uv))
- [GNU Stow](https://www.gnu.org/software/stow/) for dotfile symlinking
- [VS Code](https://code.visualstudio.com/) + Dev Containers extension (optional but recommended)

## Security

Never commit API keys or tokens. See [`ai-dotfiles/README.md`](ai-dotfiles/README.md#security-warning) for which files are `.gitignore`d per CLI.
