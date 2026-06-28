# Day 22 Notes - Git Fundamentals Q&A

---

### Q1. What is the difference between `git add` and `git commit`?

`git add` moves your changes into the **staging area** - it's like putting files in a box and saying "I want these in the next snapshot."

`git commit` actually **takes that snapshot** - it permanently saves everything in the staging area to the repo history with a message and timestamp.

Think of it like this:
- `git add` = putting items in a shopping cart
- `git commit` = actually checking out and placing the order

You can `git add` multiple files one by one and then do a single `git commit` to bundle them all together in one logical change.

---

### Q2. What does the staging area do? Why doesn't Git just commit directly?

The staging area (also called the **index**) acts as a buffer between your working files and your commit history.

It lets you:
- Pick **exactly which changes** go into a commit, even if you've touched 10 files
- Review what you're about to commit before making it permanent (`git diff --staged`)
- Group **related changes** into one commit even if your working directory is messy

If Git committed everything directly on save, you'd end up with noisy, meaningless history. The staging area gives you control and intention over your commits.

---

### Q3. What information does `git log` show you?

`git log` shows the full commit history of the repo. For each commit, it shows:

- **Commit hash** - a unique 40-character SHA-1 ID (like a fingerprint for that commit)
- **Author** - who made the commit (name + email from `git config`)
- **Date** - when the commit was made
- **Commit message** - what the commit does

`git log --oneline` gives you the short hash + message only - much cleaner for getting a quick overview.

---

### Q4. What is the `.git/` folder and what happens if you delete it?

The `.git/` folder **is** the repository. It stores everything Git knows about your project:
- The entire commit history
- Branch references
- Your staged changes (index)
- Configuration
- All the blobs (file snapshots) and trees (directory snapshots)

If you delete `.git/`, your project folder becomes a plain folder again. Git will have **no memory** of any commits, branches, or history. Your actual files stay, but the version control is gone forever (unless you have a remote backup).

> Rule: never manually delete or edit files inside `.git/` unless you know exactly what you're doing.

---

### Q5. What is the difference between a working directory, staging area, and repository?

These are the **three zones** Git uses to manage changes:

```
Working Directory   →  git add  →  Staging Area  →  git commit  →  Repository
(your actual files)                 (index/cache)                   (.git/ history)
```

| Zone | What it is | Git command to move out of it |
|---|---|---|
| **Working Directory** | Files you see and edit on disk right now | `git add` |
| **Staging Area** | A "pre-commit" holding zone - changes queued for the next commit | `git commit` |
| **Repository** | Permanent history stored in `.git/` - all your commits | (already saved) |

An analogy:
- Working Directory = your **rough draft** on paper
- Staging Area = **what you've marked to include** in the final version
- Repository = **the published book** - permanent and versioned
