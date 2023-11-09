# spicyDocs

## Overview

This ~~is~~ used to be the repo for my documentation - now it's merged with my main cookbooks repo for a monolithic repo structure! The aim is to keep it up to date with my homelab and to allow others to learn from the publicly hosted docs and config files when they ask about my homelab.

## Installation

Markdown documentation files are stored in the `cookbooks/docs/src/` folder. Run the `cookbooks/docs/bin/setup.sh` script to set up a python virtual environment to be able to run `./bin/preview.sh` and view changes locally before pushing to your repo.

!!! note
        This is currently only tested and working on WSL on Windows builds. May also work on native linux. Lo siento. 

While this is not necessary, it helps save on runtime minutes if your docs website is run through a "freemium" CI pipeline. I.E. I have my website deployed to GitHub Pages through a GitHub Actions CI pipeline. Free GitHub accounts receive 2000 minutes to run GitHub Actions, so viewing changes locally helps cut down on re-running CI just to view a typo change. Running the preview server can also allow you to view changes instantly instead of having to wait for the CI pipeline to finish.

## Links

[GitHub Actions](https://github.com/features/actions)

[GitHub Pages](https://pages.github.com/)

[My Docs](https://github.com/spicyFajitas/cookbooks/tree/master/docs)

https://gitmoji.dev/, https://www.conventionalcommits.org/en/v1.0.0/#summary

## To Do 

- [x] changes in order to run CI linting
