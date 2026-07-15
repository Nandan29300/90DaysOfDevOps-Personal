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

## Remote Commands (Day 25)
| Command | What it does | Example |
|---|---|---|
| `git remote -v` | List remotes and their URLs (fetch + push) | `git remote -v` |
| `git remote add <name> <url>` | Add a new remote | `git remote add origin https://github.com/user/repo.git` |
| `git remote remove <name>` | Remove a configured remote | `git remote remove origin` |
| `git push <remote> <branch>` | Push local branch commits to a remote | `git push origin main` |
| `git push -u <remote> <branch>` | Push and set upstream tracking (so future `git push` alone works) | `git push -u origin feature-login` |
| `git push origin --delete <branch>` | Delete a branch on the remote | `git push origin --delete old-feature` |
| `git pull <remote> <branch>` | Fetch + merge remote changes into current branch | `git pull origin main` |
| `git pull --rebase` | Fetch + rebase local commits on top of remote changes instead of merging | `git pull --rebase origin main` |
| `git fetch` | Download remote commits/branches without merging into local branches | `git fetch origin` |
| `git fetch --all` | Fetch from all configured remotes | `git fetch --all` |
| `git clone <url>` | Clone a full remote repo (history + branches) to local | `git clone https://github.com/user/repo.git` |
| Fork (GitHub UI) | Create your own copy of someone else's repo under your account, then clone your fork locally to work on it | Fork via GitHub → `git clone https://github.com/you/repo.git` |
| `git remote add upstream <url>` | Track the original repo you forked from, to pull in its latest changes | `git remote add upstream https://github.com/original/repo.git` |

---

## Reset & Revert - Deep Dive (Day 25)

| Command | What it does | Destructive? | Safe on shared branches? |
|---|---|---|---|
| `git reset --soft HEAD~1` | Moves HEAD back, keeps changes **staged** | No | No |
| `git reset --mixed HEAD~1` (default) | Moves HEAD back, keeps changes in **working dir**, unstages them | No | No |
| `git reset --hard HEAD~1` | Moves HEAD back, **wipes** staging + working dir | Yes | No |
| `git revert <hash>` | Creates a **new commit** that undoes a target commit's changes | No | Yes |
| `git reflog` | Shows history of everywhere HEAD has pointed — safety net to recover "lost" commits after a hard reset | — | — |

---

## GitHub CLI - Auth & Setup (Day 26)
| Command | What it does | Example |
|---|---|---|
| `gh --version` | Check gh is installed and which version | `gh --version` |
| `gh auth login` | Authenticate gh with a GitHub account (browser, token, or SSH flow) | `gh auth login` |
| `gh auth status` | Verify login and see which account/scopes are active | `gh auth status` |
| `gh auth switch` | Switch between multiple logged-in accounts | `gh auth switch` |
| `gh auth logout` | Log out of a gh-authenticated account | `gh auth logout` |
| `gh help` | Top-level help / list of command groups | `gh help` |
| `gh <command> --help` | Help for a specific command | `gh pr create --help` |

---

## GitHub CLI - Repositories (Day 26)
| Command | What it does | Example |
|---|---|---|
| `gh repo create <name> --public --add-readme` | Create a new GitHub repo from the terminal | `gh repo create day26-test-repo --public --add-readme` |
| `gh repo create --source . --push` | Turn an existing local folder into a GitHub repo and push it | `gh repo create --source . --public --push` |
| `gh repo clone <owner>/<repo>` | Clone a repo using gh (auth handled automatically) | `gh repo clone octocat/Hello-World` |
| `gh repo view <owner>/<repo>` | View repo details in the terminal | `gh repo view octocat/Hello-World` |
| `gh repo view --web` | Open the current/specified repo in the browser | `gh repo view --web` |
| `gh repo list [owner]` | List repos you own (or another owner's) | `gh repo list --limit 50` |
| `gh repo delete <owner>/<repo> --yes` | Delete a repo (irreversible — be careful) | `gh repo delete me/day26-test-repo --yes` |
| `gh repo fork <owner>/<repo>` | Fork a repo from the terminal | `gh repo fork octocat/Hello-World --clone` |

---

## GitHub CLI - Issues (Day 26)
| Command | What it does | Example |
|---|---|---|
| `gh issue create --title "..." --body "..." --label bug` | Create an issue with title, body, label | `gh issue create --title "Login bug" --body "..." --label bug` |
| `gh issue list` | List open issues on the current repo | `gh issue list --state open` |
| `gh issue view <number>` | View a specific issue | `gh issue view 12` |
| `gh issue close <number>` | Close an issue | `gh issue close 12` |
| `gh issue reopen <number>` | Reopen a closed issue | `gh issue reopen 12` |
| `gh issue list --json number,title,labels` | Get machine-readable issue data for scripting | `gh issue list --json number,title --jq '.[].title'` |

---

## GitHub CLI - Pull Requests (Day 26)
| Command | What it does | Example |
|---|---|---|
| `gh pr create --fill` | Create a PR, auto-filling title/body from commits | `gh pr create --fill` |
| `gh pr create --title "..." --body "..."` | Create a PR with custom title/body | `gh pr create --title "Add feature" --body "Details..."` |
| `gh pr list` | List open PRs on the current repo | `gh pr list` |
| `gh pr view <number>` | View a PR's details, reviewers, status | `gh pr view 5` |
| `gh pr checks <number>` | View CI/status check results for a PR | `gh pr checks 5` |
| `gh pr checkout <number>` | Check out a PR's branch locally to test it | `gh pr checkout 5` |
| `gh pr diff <number>` | View a PR's diff in the terminal | `gh pr diff 5` |
| `gh pr review <number> --approve -b "msg"` | Approve a PR with a comment | `gh pr review 5 --approve -b "LGTM"` |
| `gh pr review <number> --request-changes -b "msg"` | Request changes on a PR | `gh pr review 5 --request-changes -b "Needs tests"` |
| `gh pr merge <number> --squash --delete-branch` | Merge a PR and delete its branch | `gh pr merge 5 --squash --delete-branch` |

---

## GitHub CLI - Actions & Workflows (Day 26 preview)
| Command | What it does | Example |
|---|---|---|
| `gh run list` | List recent workflow runs on a repo | `gh run list --repo cli/cli` |
| `gh run view <run-id>` | View the status/summary of a specific run | `gh run view 123456` |
| `gh run view <run-id> --log-failed` | View logs of just the failed steps | `gh run view 123456 --log-failed` |
| `gh run watch` | Live-stream a run's status until it finishes | `gh run watch` |
| `gh run rerun <run-id> --failed` | Re-run only the failed jobs of a run | `gh run rerun 123456 --failed` |
| `gh workflow list` | List workflows defined in a repo | `gh workflow list` |
| `gh workflow run <name>` | Manually trigger a `workflow_dispatch` workflow | `gh workflow run deploy.yml -f env=staging` |

---

## GitHub CLI - Extra Tricks (Day 26)
| Command | What it does | Example |
|---|---|---|
| `gh api <endpoint>` | Make a raw GitHub API call (auth handled automatically) | `gh api repos/octocat/Hello-World` |
| `gh gist create <file> --public` | Create a Gist from a local file | `gh gist create notes.md --public` |
| `gh release create <tag> --notes "..."` | Create a tagged GitHub release | `gh release create v1.0.0 --notes "First release"` |
| `gh alias set <name> '<command>'` | Create a shortcut for a frequently used command | `gh alias set prs 'pr list --author @me'` |
| `gh search repos "<query>" --language=<lang>` | Search GitHub repos from the terminal | `gh search repos "devops" --language=python --stars=">100"` |

---
