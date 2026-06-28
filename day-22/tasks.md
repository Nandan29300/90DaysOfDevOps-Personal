# Day 22 – Git Tasks Execution

---

## Task 1: Install and Configure Git

### Step 1 - Verify Git is installed

```bash
git --version
```

**Output:**
```
git version 2.43.0
```

---

### Step 2 - Set up your Git identity

```bash
git config --global user.name "Nandan"
git config --global user.email "nandan@gmail.com"
```

---

### Step 3 - Verify your configuration

```bash
git config --list
```

**Output:**
```
user.name=Nandan
user.email=nandan@gmail.com
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
```

---

## Task 2: Create Your Git Project

### Step 1 - Create a new folder

```bash
mkdir devops-git-practice
cd devops-git-practice
```

---

### Step 2 - Initialize it as a Git repository

```bash
git init
```

**Output:**
```
Initialized empty Git repository in /home/nandan/devops-git-practice/.git/
```

---

### Step 3 - Check the status

```bash
git status
```

**Output:**
```
On branch master

No commits yet

nothing to commit (create/copy files and use "git add" to track)
```

**What Git is telling you:**
- You're on the `master` branch
- No commits yet - repo is brand new
- Nothing to commit - no files exist yet

---

### Step 4 - Explore the hidden `.git/` directory

```bash
ls -la .git/
```

**Output:**
```
drwxrwxr-x 7 nandan nandan 4096 Jun 28 10:00 .
drwxrwxr-x 3 nandan nandan 4096 Jun 28 10:00 ..
-rw-rw-r-- 1 nandan nandan   23 Jun 28 10:00 HEAD
drwxrwxr-x 2 nandan nandan 4096 Jun 28 10:00 branches
-rw-rw-r-- 1 nandan nandan   92 Jun 28 10:00 config
-rw-rw-r-- 1 nandan nandan   73 Jun 28 10:00 description
drwxrwxr-x 2 nandan nandan 4096 Jun 28 10:00 hooks
drwxrwxr-x 2 nandan nandan 4096 Jun 28 10:00 info
drwxrwxr-x 4 nandan nandan 4096 Jun 28 10:00 objects
drwxrwxr-x 4 nandan nandan 4096 Jun 28 10:00 refs
```

| File/Folder | What it does |
|---|---|
| `HEAD` | Points to the current branch you're on |
| `config` | Repo-level Git config |
| `objects/` | Stores all commits, files, trees as blobs |
| `refs/` | Stores branch and tag pointers |
| `hooks/` | Scripts that run on Git events |

---

## Task 3: Create Your Git Commands Reference

### Step 1 - Create the file

```bash
touch git-commands.md
```

### Step 2 - Check status again

```bash
git status
```

**Output:**
```
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        git-commands.md

nothing added to commit but untracked files present
```

> Git sees the file but is NOT tracking it yet. You need to `git add` it first.

---

## Task 4: Stage and Commit

### Step 1 - Stage the file

```bash
git add git-commands.md
```

---

### Step 2 - Check what's staged

```bash
git status
```

**Output:**
```
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
        new file:   git-commands.md
```

---

### Step 3 - Commit with a meaningful message

```bash
git commit -m "docs: add git-commands.md with setup and basic workflow commands"
```

**Output:**
```
[master (root-commit) a1b2c3d] docs: add git-commands.md with setup and basic workflow commands
 1 file changed, 45 insertions(+)
 create mode 100644 git-commands.md
```

---

### Step 4 - View your commit history

```bash
git log
```

**Output:**
```
commit a1b2c3d4e5f6789012345678901234567890abcd
Author: Nandan <nandan@example.com>
Date:   Sat Jun 28 10:15:00 2025 +0530

    docs: add git-commands.md with setup and basic workflow commands
```

---

## Task 5: Make More Changes and Build History

### Commit 2 - Add "Viewing Changes" section to git-commands.md

```bash
# open the file and add Viewing Changes section
nano git-commands.md

# check what changed
git diff

# stage and commit
git add git-commands.md
git commit -m "docs: add Viewing Changes section with diff, log, show commands"
```

**Output:**
```
[master b2c3d4e] docs: add Viewing Changes section with diff, log, show commands
 1 file changed, 18 insertions(+)
```

---

### Commit 3 - Add "Undoing Changes" section

```bash
nano git-commands.md

git diff

git add git-commands.md
git commit -m "docs: add Undoing Changes section with restore, reset, revert"
```

**Output:**
```
[master c3d4e5f] docs: add Undoing Changes section with restore, reset, revert
 1 file changed, 22 insertions(+)
```

---

### Commit 4 - Add day-22-notes.md

```bash
touch day-22-notes.md
# paste your Q&A answers into it

git add day-22-notes.md
git commit -m "docs: add day-22-notes with Git concepts Q&A"
```

**Output:**
```
[master d4e5f6a] docs: add day-22-notes with Git concepts Q&A
 1 file changed, 60 insertions(+)
 create mode 100644 day-22-notes.md
```

---

### View full history in compact format

```bash
git log --oneline
```

**Output:**
```
d4e5f6a (HEAD -> master) docs: add day-22-notes with Git concepts Q&A
c3d4e5f docs: add Undoing Changes section with restore, reset, revert
b2c3d4e docs: add Viewing Changes section with diff, log, show commands
a1b2c3d docs: add git-commands.md with setup and basic workflow commands
```

> 📸 **Screenshot this output for your submission!**

---

### Check what changed between commits

```bash
git diff HEAD~1 HEAD
```

This shows exactly what was added or removed in the last commit vs the one before it.

---

## Task 6: Understand the Git Workflow

> Answers are in `day-22-notes.md`

---

## Final Folder Structure

```
devops-git-practice/
├── git-commands.md       ← your living Git reference
└── day-22-notes.md       ← Q&A answers
```

---
