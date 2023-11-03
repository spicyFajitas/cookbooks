# Intro

## About Me

Welcome to my documentation! I currently attend Michigan Technological University as a dedicated student in Computer Network and System Administration. I am looking to grow my education and career as a DevOps Engineer or Site Reliability Engineer. My primary education is in network engineering, Windows server environments, and virtualization, but my work experience has made me become interested in DevOps and other automation roles.

I started my journey in IT with three different IT Help Desk positions. I was the boots-on-the-ground person to do initial troubleshooting with any and all computer hardware and software issues. I have experiences in manufacturing and education environments.

After help desk, I joined a Cloud Team. I learned about deploying applications with a cloud-native mindset and also learned how cloud deployments can help businesses save money on environments while being able to dynamically scale according to their needs.

Next, I decided to step into the automation space. I am learning a lot about CI/CD principles and the tools that help teams achieve their goals. I am constantly learning new technologies and problem solving, all of which is driven by my passion for IT.

For full documentation regarding the infrastructure of this site, visit the [MkDocs website](https://www.mkdocs.org) or the [Material for MkDocs website](https://squidfunk.github.io/mkdocs-material/).

## Overview

This is the website for my documentation! The aim is to keep it up to date with my homelab and to allow others to learn from the publicly hosted docs when they ask about my homelab.

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
