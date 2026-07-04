# Day 23 – Git Branching & Working with GitHub

---

## Task 1: Understanding Branches

### 1. What is a branch in Git?

A branch is just a **movable pointer to a commit**. When you make a new commit, the branch pointer automatically moves forward to point at that new commit.

Technically, `main` isn't special - it's just the default branch name Git gives you. Every branch is a lightweight pointer stored in `.git/refs/heads/`. This is why creating a branch in Git is instant and cheap (unlike some older version control systems that literally copy the whole codebase).

**Why this matters:** because branches are just pointers, you can create dozens of them without worrying about disk space or performance.

### 2. Why do we use branches instead of committing everything to `main`?

- **Isolation** – `main` stays stable and deployable at all times. Broken/half-finished work never touches it.
- **Parallel work** – multiple people (or you, wearing different hats) can work on different features/fixes at the same time without stepping on each other.
- **Safe experimentation** – you can try a risky idea; if it fails, delete the branch and `main` is untouched.
- **Clean history & review** – changes go through a branch → Pull Request → review → merge flow, so `main` gets an intentional, reviewed history instead of a messy stream of half-baked commits.
- **Easy rollback** – if a feature breaks something, you just don't merge it (or you revert the merge commit) instead of untangling commits mixed into `main`.

### 3. What is `HEAD` in Git?

`HEAD` is a pointer that tells Git **"where you currently are."** Normally, `HEAD` points to the branch you're on (e.g., `main`), and that branch pointer points to the latest commit.

```
HEAD → main → commit C3
```

When you switch branches, `HEAD` moves to point at the new branch instead:

```
HEAD → feature-1 → commit C4
```

If you check out a specific commit hash directly (instead of a branch), you get a **"detached HEAD"** state - `HEAD` points straight at a commit instead of at a branch.

### 4. What happens to your files when you switch branches?

Git rewrites the files in your **working directory** to match the snapshot of the commit that the new branch points to:

- Files that exist in the new branch but not the old one → appear.
- Files that exist in the old branch but not the new one → disappear (but they're safe, still saved in the old branch's history).
- Files that differ between branches → get updated to match the new branch's version.

⚠️ If you have **uncommitted changes** that conflict with the branch you're switching to, Git will block the switch and ask you to commit, stash, or discard those changes first. This is Git protecting you from silently losing work.

---

## Task 2: Branching Commands - Hands-On

```bash
# 1. List all branches (local)
git branch

# 2. Create a new branch called feature-1 (doesn't switch to it)
git branch feature-1

# 3. Switch to feature-1
git switch feature-1
# (older equivalent: git checkout feature-1)

# 4. Create AND switch to feature-2 in one command
git switch -c feature-2
# (older equivalent: git checkout -b feature-2)

# 5. Move between branches using git switch
git switch main
git switch feature-2

# 6. Make a commit on feature-1 that doesn't exist on main
git switch feature-1
echo "This line only exists on feature-1" >> notes.txt
git add notes.txt
git commit -m "Add feature-1 only content"

# 7. Switch back to main and verify the commit is NOT there
git switch main
cat notes.txt        # the feature-1 line will be missing
git log --oneline    # feature-1's commit won't show in main's history

# 8. Delete a branch you no longer need
git branch -d feature-2       # safe delete (only if merged)
git branch -D feature-2       # force delete (even if unmerged)

# 9. Verify all branches again
git branch -a
```

### `git switch` vs `git checkout` - what's the difference?

`git checkout` is an old, "overloaded" command - it does too many unrelated things: switching branches, restoring files, checking out specific commits, etc. That overlap made it confusing and occasionally dangerous (e.g., `git checkout <file>` can silently discard changes).

`git switch` was introduced (Git 2.23+) to do **one job only**: switching branches. Similarly, `git restore` was introduced to handle restoring files. This split makes commands safer and their intent obvious just from the name.

| | `git checkout` | `git switch` |
|---|---|---|
| Purpose | Multi-purpose (branches, files, commits) | Branches only |
| Create + switch | `git checkout -b name` | `git switch -c name` |
| Safety | Can accidentally discard file changes | Focused, harder to misuse |
| Status | Still works, kept for compatibility | Recommended modern approach |

---

## Task 3: Push to GitHub

Steps performed:

1. Created a new empty repository on GitHub - **no README, no `.gitignore`** (so it's truly empty and won't conflict with local history).
2. Connected the local repo to the GitHub remote:

```bash
git remote add origin https://github.com/Nandan300/devops-git-practice.git
git remote -v     # verify the remote was added correctly
```

3. Pushed `main` to GitHub:

```bash
git push -u origin main
```

4. Pushed `feature-1` to GitHub:

```bash
git push -u origin feature-1
```

5. Verified on GitHub.com that both `main` and `feature-1` branches are visible in the branch dropdown of the repo.

> 💡 The `-u` flag (`--set-upstream`) links your local branch to the remote branch, so afterwards you can just run `git push` / `git pull` without specifying `origin main` every time.

### `origin` vs `upstream` - what's the difference?

- **`origin`** is just the default nickname Git gives to the remote repository you cloned from (or the one you first added). For most personal projects, `origin` = your own repo on GitHub.
- **`upstream`** is a convention (not a Git rule) used when you're working with a **fork**. It refers to the *original* repository you forked from, so you can pull in updates the original maintainers make, separately from your own fork (`origin`).

Example setup when contributing to an open-source project:

```bash
origin    → https://github.com/Nandan29300/project.git   (your fork)
upstream  → https://github.com/<original-owner>/project.git  (original repo)
```

---

## Task 4: Pull from GitHub

1. Edited a file directly on GitHub using the web editor and committed the change on `main`.
2. Pulled the change into the local repo:

```bash
git pull origin main
```

3. Verified the file locally now matches what was changed on GitHub.

### `git fetch` vs `git pull` - what's the difference?

- **`git fetch`** downloads new commits/branches from the remote into your local repo's "remote-tracking branches" (e.g., `origin/main`), but it **does not touch your working files or your local branch**. It's a safe, look-before-you-leap operation - you can inspect what changed before merging it in.
- **`git pull`** is essentially `git fetch` **+** `git merge` (or `git rebase`, depending on config) combined into one step. It fetches the changes *and* immediately merges them into your current branch, updating your working files right away.

Rule of thumb: use `git fetch` when you want to review incoming changes first; use `git pull` when you just want to sync up quickly and trust there won't be conflicts.

---

## Task 5: Clone vs Fork

1. Cloned a public repo directly to the local machine:

```bash
git clone https://github.com/<owner>/<public-repo>.git
```

2. Forked the same repo on GitHub (creates a copy under my own GitHub account), then cloned *that* fork:

```bash
git clone https://github.com/<my-username>/<public-repo>.git
```

### What is the difference between clone and fork?

- **Clone** is a **Git** concept: it downloads a full copy of a repository (all commits, branches, history) onto your local machine. It works on *any* repo you have access to and doesn't require GitHub at all - Git itself has no idea what "GitHub" is.
- **Fork** is a **GitHub** (platform) concept, not a Git command. It creates your own **copy of the repository under your own GitHub account**, so you have a remote repo you can push to - useful when you don't have write access to the original.

### When would you clone vs fork?

- **Clone**: when you already have (or don't need) push access to the repo - e.g., cloning your own team's private repo, or just grabbing a copy of an open-source project to read/run locally.
- **Fork**: when you want to contribute to a project you **don't** have write access to. You fork it, make changes in your own copy, and open a Pull Request back to the original repo.

### After forking, how do you keep your fork in sync with the original repo?

```bash
# 1. Add the original repo as a remote called "upstream" (one-time setup)
git remote add upstream https://github.com/<original-owner>/<repo>.git

# 2. Fetch the latest changes from the original repo
git fetch upstream

# 3. Merge those changes into your local main branch
git switch main
git merge upstream/main

# 4. Push the updated main to your own fork (origin)
git push origin main
```

---

## Key Takeaways

- Branches are cheap, lightweight pointers - use them liberally.
- `HEAD` tracks where you currently are in the repo.
- `git switch` is the modern, safer way to change branches; `git checkout` still works but does too much.
- `origin` = your remote; `upstream` = the original repo you forked from.
- `git fetch` = download only; `git pull` = download + merge.
- `clone` is a Git-level copy; `fork` is a GitHub-level copy under your own account.

---
