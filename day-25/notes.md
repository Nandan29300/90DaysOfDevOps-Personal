# Day 25 – Git Reset vs Git Revert & Branching Strategies

---

# Task 1: Git Reset (Hands-On)

## Setup

```bash
mkdir reset-practice && cd reset-practice

git init

echo "line 1" > file.txt
git add file.txt
git commit -m "commit A"

echo "line 2" >> file.txt
git add file.txt
git commit -m "commit B"

echo "line 3" >> file.txt
git add file.txt
git commit -m "commit C"

git log --oneline
```

Output:

```text
c3d4e5f (HEAD -> main) commit C
b2c3d4e commit B
a1b2c3d commit A
```

---

## 1. `git reset --soft HEAD~1`

```bash
git reset --soft HEAD~1
git status
```

### What happens?

- HEAD moves back from **commit C** to **commit B**.
- Changes from **commit C** are **kept in the staging area**.
- Your file content does **not** change.
- `git status` shows:

```
Changes to be committed
```

### In simple words

It removes the last commit but keeps all changes staged, ready to commit again.

```bash
git commit -m "commit C (redone)"
```

---

## 2. `git reset --mixed HEAD~1` (Default)

```bash
git reset --mixed HEAD~1
git status
```

### What happens?

- HEAD moves back one commit.
- Changes are removed from staging.
- Changes stay in your working directory.
- `git status` shows:

```
Changes not staged for commit
```

You must add them again before committing.

```bash
git add file.txt
git commit -m "commit C (redone again)"
```

### In simple words

The commit is removed, but your file changes stay. They are just unstaged.

---

## 3. `git reset --hard HEAD~1`

```bash
git reset --hard HEAD~1

git status
git log --oneline
cat file.txt
```

### What happens?

- HEAD moves back one commit.
- Staging area is cleared.
- Working directory is also reset.
- `line 3` is completely removed.
- `git status` shows:

```
nothing to commit, working tree clean
```

### In simple words

The commit and all its file changes are deleted.

⚠️ This is dangerous because your changes are lost.

---

# Summary of Reset

| Command | HEAD | Staging Area | Working Directory |
|---------|------|--------------|------------------|
| `--soft` | Moves back | Keeps changes staged | Keeps changes |
| `--mixed` | Moves back | Removes from staging | Keeps changes |
| `--hard` | Moves back | Deletes changes | Deletes changes |

---

## Which one is dangerous?

**`git reset --hard`**

Because it removes both the commit and the file changes from your computer.

---

## When should you use each one?

### `--soft`

Use when:

- You want to edit the last commit.
- You want to change the commit message.
- You want to combine commits.

---

### `--mixed`

Use when:

- You want to unstage files.
- You want to create smaller commits.

---

### `--hard`

Use when:

- You want to completely remove a commit.
- You don't need those changes anymore.

---

## Should you use `git reset` after pushing?

**No.**

If the commit is already pushed and others are using it, `git reset` changes Git history and can create problems.

Use **`git revert`** instead.

---

# Task 2: Git Revert (Hands-On)

## Setup

```bash
mkdir revert-practice && cd revert-practice

git init

echo "line 1" > file.txt
git add .
git commit -m "commit X"

echo "line 2" >> file.txt
git add .
git commit -m "commit Y"

echo "line 3" >> file.txt
git add .
git commit -m "commit Z"

git log --oneline
```

Output:

```text
9f8e7d6 commit Z
7d6c5b4 commit Y
5b4a3c2 commit X
```

---

## Revert Commit Y

```bash
git revert 7d6c5b4
```

Git opens a text editor.

Save and close it.

---

## What happens?

- Git creates a **new commit**.
- This new commit cancels the changes made in **commit Y**.
- Commit Y still stays in Git history.
- Only its changes are undone.

If there is a conflict, Git asks you to fix it before completing the revert.

---

## Check History

```bash
git log --oneline
```

Example:

```text
2a1b3c4 Revert "commit Y"
9f8e7d6 commit Z
7d6c5b4 commit Y
5b4a3c2 commit X
```

Notice that **commit Y is still there**.

---

# Reset vs Revert

## `git reset`

- Moves HEAD backwards.
- Can remove commits from history.
- Changes Git history.
- Best for local commits.

---

## `git revert`

- Creates a new commit.
- Original commit stays.
- History is not changed.
- Safe for shared branches.

---

## Why is `git revert` safer?

Because it never deletes history.

Everyone can simply pull the new revert commit.

No force push is needed.

---

## When to use which?

### Use `git reset`

- Before pushing.
- For your own local commits.

### Use `git revert`

- After pushing.
- On shared branches like `main`.

---

# Reset vs Revert (Comparison)

| Feature | `git reset` | `git revert` |
|----------|-------------|--------------|
| Removes commit? | Yes | No |
| Creates new commit? | No | Yes |
| Changes history? | Yes | No |
| Safe after push? | No | Yes |
| Best for | Local commits | Shared branches |

---

# Task 3: Branching Strategies

---

# 1. GitFlow

## Branches

- `main` → Production code
- `develop` → Current development
- `feature/*` → New features
- `release/*` → Prepare release
- `hotfix/*` → Urgent production fixes

### Flow

```
main
   │
release
   │
develop
 ├── feature/login
 ├── feature/payment
 └── feature/profile
```

---

## Used for

- Large companies
- Scheduled releases
- Multiple production versions

---

## Advantages

- Well organized
- Easy to manage releases
- Good for big teams

---

## Disadvantages

- Many branches
- More merges
- Slower development

---

# 2. GitHub Flow

## Branches

Only one main branch.

Every feature gets a small branch.

```
main
 ├── feature-login
 ├── feature-payment
 └── feature-profile
```

After review:

```
Feature Branch
      ↓
Pull Request
      ↓
Merge
      ↓
Deploy
```

---

## Used for

- Startups
- SaaS products
- Continuous deployment
- Open-source projects

---

## Advantages

- Simple
- Fast
- Easy to understand
- Works well with CI/CD

---

## Disadvantages

- No separate release branch
- Requires good testing

---

# 3. Trunk-Based Development

Everyone works on one branch (`main`).

Feature branches are very short (a few hours or one day).

```
main
●──●──●──●──●──●──●──●
```

Feature flags hide unfinished work.

---

## Used for

- Google
- Teams with strong CI/CD
- Continuous Integration

---

## Advantages

- Fewer merge conflicts
- Small commits
- Faster integration

---

## Disadvantages

- Needs strong automated testing
- Requires feature flags
- Needs disciplined developers

---

# Which strategy should you choose?

## Startup shipping quickly

✅ **GitHub Flow**

Reason:

- Simple
- Fast
- Easy to deploy frequently

---

## Large company with planned releases

✅ **GitFlow**

Reason:

- Better release management
- Supports hotfixes
- Good for big teams

---

## Example Open Source Project

**Kubernetes**

- Uses Pull Requests
- Merges into `main`
- Creates release branches like `release-x.y`

It mostly follows **GitHub Flow**, with release branches added when needed.

---

# Reflog (Recovery Tool)

Even if you accidentally use:

```bash
git reset --hard
```

Git usually remembers where HEAD was.

Check it using:

```bash
git reflog
```

Example:

```bash
git reflog

c3d4e5f HEAD@{1}
```

Restore the lost commit:

```bash
git reset --hard c3d4e5f
```

Or restore only that commit:

```bash
git cherry-pick c3d4e5f
```

---

# Quick Revision

## Git Reset

- Moves HEAD backwards.
- Can remove commits.
- Best for local commits.

### Types

- `--soft` → Keep changes staged.
- `--mixed` → Keep changes unstaged.
- `--hard` → Delete everything.

---

## Git Revert

- Creates a new commit.
- Original commit stays.
- Safe after pushing.

---

## Branching Strategies

| Strategy | Best For |
|-----------|----------|
| GitFlow | Large teams with scheduled releases |
| GitHub Flow | Startups and continuous deployment |
| Trunk-Based Development | Teams with strong CI/CD and automated testing |
