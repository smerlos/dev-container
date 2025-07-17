# Dev Container Usage Guide

This document provides quick reference tips for using the development container.

## Basic Commands

- `mise install <tool>@<version>`: Install a tool using mise.
- `setup-workspace`: Initialize the workspace and install tool versions specified in `.mise.toml`.
- `docker compose up -d`: Launch services defined in `docker-compose.yml` (if present).

## Handy Tips

- Use `direnv allow` after modifying `.envrc` to load environment variables automatically.
- Run `.devcontainer/test-container.sh` inside the container to verify everything is working.

For more details, see the main [README](README.md).
