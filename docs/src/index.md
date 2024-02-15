# Intro

If you're looking for my personal website / blog, feel free to [check it out](https://shell.lug.mtu.edu/~adam/)

## Overview

This is the website for my documentation! The aim is to keep it up to date with my homelab and to allow others to learn from the publicly hosted docs when they ask about my homelab.

For full documentation regarding the infrastructure of this site, visit the [MkDocs website](https://www.mkdocs.org) or the [Material for MkDocs website](https://squidfunk.github.io/mkdocs-material/).

## Usage

### Editing Repo

Feel free to fork and modify for your own usage.

Markdown documentation files are stored in the `./docs/` folder. Run the `./bin/setup.sh` script to set up a python virtual environment to be able to run `./bin/preview.sh` and view changes locally before pushing to your repo. I edit my docs in WSL instances - you can edit anywhere but the scripts are only supported on Linux.

### CI

In order to run CI and update your website, you need to include `[CI]` in your commit message - see `.github/workflows/main.yml`:

```yml
    if: "contains(github.event.head_commit.message, '[CI]')"
```

This ensures that GitHub actions runs for the shortest amount of time possible as it skips all jobs. This is not necessary, and you can remove this line in order to run CI every time. I like having it as it saves my GitHub actions CI runtime minutes.

## Links

[GitHub Actions](https://github.com/features/actions)

[GitHub Pages](https://pages.github.com/)
