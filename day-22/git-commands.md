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

## Branching Basics *(preview - Day 23)*

| Command | What it does | Example |
|---|---|---|
| `git branch` | List all local branches | `git branch` |
| `git branch <name>` | Create a new branch | `git branch feature-login` |
| `git checkout <branch>` | Switch to an existing branch | `git checkout feature-login` |
| `git checkout -b <name>` | Create and switch to a new branch in one step | `git checkout -b feature-login` |
| `git merge <branch>` | Merge another branch into the current one | `git merge feature-login` |
