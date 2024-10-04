# Git

Page dedicated to making git easier to use for myself and hopefully others.

* `#` indicates optional argument

## Commands

`git clone <repo>` Clones repo

`git checkout -b <branch name> #<branch to branch from>`

`git stash` Stash current uncommitted changes

`git stash pop` Un-stash last stashed uncommitted changes

`git pull` Pull remote changes into current branch (if there's been remote updates to branch currently checked out)

`git rebase <base>` Rebase from branch (example: `git rebase origin masterr`)

`git remote -v` See remotes

`git remote set-url origin <url>` Set remote url for origin

`git config --global push.autoSetupRemote true` Set up automatic branch creation on remote when creating a new branch

## Rebasing

If you want to rebase a branch based on remote master branch, `git rebase origin/master` is not enough, it will not get new commits directly from origin/master. You need to `git fetch` before `git rebase origin/master`.

Or you can use another way to rebase a branch.

switch to master `git checkout master`
`git pull origin master`
switch back to your own branch `git checkout <your branch>`
`git rebase origin/master`
then, your branch is updated to newest commits.

[Reference](https://stackoverflow.com/questions/29164321/git-difference-git-rebase-origin-branch-vs-git-rebase-origin-branch)

## Git Cleanup Alias

### Windows

`git fetch prune`

`git remote prune origin`

`git branch | Select-String -NotMatch -Pattern "master|main" | %{ git branch -D $_.ToString().Trim() }`

[This link](https://stackoverflow.com/questions/37664226/git-fetch-origin-prune-doesnt-delete-local-branches) has aliases for Windows and Linux
