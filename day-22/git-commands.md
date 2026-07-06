# Git Commands Reference

> My personal Git reference - started on Day 22, will update when I learn new commands.

---

## Setup & Config

| Command | What it does | Example |
|---|---|---|
| `git --version` | Check if Git is installed and which version | `git --version` → `git version 2.43.0` |
| `git config --global user.name "Name"` | Set your name for all commits globally | `git config --global user.name "Nandan"` |
| `git config --global user.email "email"` | Set your email for all commits globally | `git config --global user.email "you@mail.com"` |
| `git config --list` | View all current Git config values | `git config --list` |
| `git config user.name` | Check a specific config value | `git config user.name` |

---

## Repository Setup

| Command | What it does | Example |
|---|---|---|
| `git init` | Initialize a new empty Git repo in the current folder | `cd myproject && git init` |
| `git clone <url>` | Download an existing repo from remote (GitHub/GitLab etc.) | `git clone https://github.com/user/repo.git` |

---

## Basic Workflow

| Command | What it does | Example |
|---|---|---|
| `git status` | Show the state of your working directory and staging area | `git status` |
| `git add <file>` | Stage a specific file for the next commit | `git add git-commands.md` |
| `git add .` | Stage ALL changed files at once | `git add .` |
| `git commit -m "msg"` | Commit staged changes with a message | `git commit -m "docs: add notes"` |
| `git commit --amend` | Edit the last commit's message or add forgotten changes | `git commit --amend -m "new message"` |

---

## Viewing Changes

| Command | What it does | Example |
|---|---|---|
| `git log` | Show full commit history with author, date, hash, message | `git log` |
| `git log --oneline` | Compact one-line-per-commit view of history | `git log --oneline` |
| `git log --oneline --graph` | Visual branch/merge graph in terminal | `git log --oneline --graph` |
| `git diff` | Show unstaged changes (working dir vs last commit) | `git diff` |
| `git diff --staged` | Show staged changes (what's about to be committed) | `git diff --staged` |
| `git diff HEAD~1 HEAD` | Compare last commit to the one before it | `git diff HEAD~1 HEAD` |
| `git show <hash>` | Show details of a specific commit | `git show a1b2c3d` |

---

## Undoing Changes

| Command | What it does | Example |
|---|---|---|
| `git restore <file>` | Discard unstaged changes in a file (revert to last commit) | `git restore notes.md` |
| `git restore --staged <file>` | Unstage a file (undo `git add`) without losing changes | `git restore --staged notes.md` |
| `git reset HEAD~1` | Undo the last commit, keep changes as unstaged | `git reset HEAD~1` |
| `git reset --hard HEAD~1` | Undo the last commit AND discard all changes (dangerous!) | `git reset --hard HEAD~1` |
| `git revert <hash>` | Create a new commit that undoes a previous one (safe for shared repos) | `git revert a1b2c3d` |

---

## Branching commands

| Command | What it does | Example |
|---|---|---|
| `git branch` | List all local branches | `git branch` |
| `git branch <name>` | Create a new branch | `git branch feature-login` |
| `git branch -a` | list all branches (local + remote) |
| `git switch <name>` | switch to an existing branch |
| `git switch -c <name>` | create a new branch and switch to it |
| `git checkout <branch>` | Switch to an existing branch | `git checkout feature-login` |
| `git checkout -b <name>` | Create and switch to a new branch in one step | `git checkout -b feature-login` |
| `git branch -D <name> ` | force delete a branch
| `git merge <branch>` | Merge another branch into the current one | `git merge feature-login` |

---

## Merging (Day 24)
| Command | What it does | Example |
|---|---|---|
| `git merge <branch>` | Merge a branch into your current branch (fast-forward if no divergence, merge commit if diverged) | `git merge feature-login` |
| `git merge --no-ff <branch>` | Force a merge commit even if a fast-forward is possible (keeps branch history visible) | `git merge --no-ff feature-login` |
| `git merge --squash <branch>` | Combine all commits from a branch into one set of staged changes (you then commit manually) | `git merge --squash feature-profile` |
| `git merge --abort` | Cancel a merge that has conflicts and go back to the pre-merge state | `git merge --abort` |
| `git diff --name-only --diff-filter=U` | List files that currently have unresolved merge conflicts | `git diff --name-only --diff-filter=U` |

---

## Rebasing (Day 24)
| Command | What it does | Example |
|---|---|---|
| `git rebase <branch>` | Replay your current branch's commits on top of another branch's latest commit | `git rebase main` |
| `git rebase --continue` | Continue a rebase after resolving a conflict | `git rebase --continue` |
| `git rebase --abort` | Cancel an in-progress rebase and return to the original state | `git rebase --abort` |
| `git rebase --skip` | Skip the current conflicting commit during a rebase | `git rebase --skip` |
| `git rebase -i <base>` | Interactive rebase — reorder, squash, edit, or drop commits | `git rebase -i HEAD~3` |

---

## Stashing (Day 24)
| Command | What it does | Example |
|---|---|---|
| `git stash` | Save uncommitted changes (staged + unstaged) and clean the working directory | `git stash` |
| `git stash push -m "msg"` | Stash changes with a custom descriptive message | `git stash push -m "wip dashboard"` |
| `git stash list` | List all saved stashes | `git stash list` |
| `git stash apply` | Re-apply the most recent stash but keep it in the list | `git stash apply` |
| `git stash apply stash@{n}` | Re-apply a specific stash by index, keeping it in the list | `git stash apply stash@{1}` |
| `git stash pop` | Re-apply the most recent stash AND remove it from the list | `git stash pop` |
| `git stash drop stash@{n}` | Delete a specific stash without applying it | `git stash drop stash@{0}` |
| `git stash clear` | Delete all stashes | `git stash clear` |
| `git stash show -p stash@{n}` | View the diff contained in a specific stash | `git stash show -p stash@{0}` |

---

## Cherry-Picking (Day 24)
| Command | What it does | Example |
|---|---|---|
| `git cherry-pick <hash>` | Apply one specific commit from another branch onto the current branch | `git cherry-pick d4e5f6g` |
| `git cherry-pick <hash1> <hash2>` | Cherry-pick multiple specific commits at once | `git cherry-pick d4e5f6g h7i8j9k` |
| `git cherry-pick --continue` | Continue a cherry-pick after resolving a conflict | `git cherry-pick --continue` |
| `git cherry-pick --abort` | Cancel an in-progress cherry-pick | `git cherry-pick --abort` |

---

## Visualizing History (Day 24)
| Command | What it does | Example |
|---|---|---|
| `git log --oneline --graph --all` | Visual graph of all branches and how/where they diverged or merged | `git log --oneline --graph --all` |
| `git log` | Used to see the logs of git operations in detail | `git log` |
| `git log --oneline` | To see the git logs in one line | `git log --oneline` |

---
