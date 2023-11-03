# spicyDocs

## Overview

This is the repo for my documentation! The aim is to keep it up to date with my homelab and to allow others to learn from the publicly hosted docs when they ask about my homelab.

## Installation

Markdown documentation files are stored in the `./src/` folder. Run the `./bin/setup.sh` script to set up a python virtual environment to be able to run `./bin/preview.sh` and view changes locally before pushing to your repo. While this is not necessary, it helps save on runtime minutes if your docs website is run through a "freemium" CI pipeline. I.E. I have my website deployed to GitHub Pages through a GitHub Actions CI pipeline. Free GitHub accounts receive 2000 minutes to run GitHub Actions, so viewing changes locally helps cut down on re-running CI just to view a typo change. Running the preview server can also allow you to view changes instantly instead of having to wait for the CI pipeline to finish.

## Links

[GitHub Actions](https://github.com/features/actions)

[GitHub Pages](https://pages.github.com/)

[My Docs](https://spicyfajitas.github.io/docs/)

https://gitmoji.dev/, https://www.conventionalcommits.org/en/v1.0.0/#summary

## To Do 

- [x] changes in order to run CI
