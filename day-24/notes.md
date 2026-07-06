# Day 24 – Advanced Git: Merge, Rebase, Stash & Cherry Pick

---

## Task 1: Git Merge - Hands-On

### 📌 What this task asked
- Create `feature-login` from `main`, add commits, merge back → observe if it's fast-forward or a merge commit
- Create `feature-signup`, add commits, but also commit on `main` first → merge and observe the difference
- Intentionally create a merge conflict and resolve it

### 📖 Concept - explained simply
When you run `git merge <branch>`, Git looks at how far the two branches have drifted apart before deciding *how* to combine them:

- **If your current branch hasn't changed at all since the other branch was created** - imagine `main` just sitting still while `feature-login` moved ahead - Git doesn't need to do any real "merging." It just slides the `main` pointer forward to match `feature-login`'s latest commit. This is called a **fast-forward merge**. No new commit is created; it's like `main` never even needed to catch up on its own, it just teleports forward.

- **If both branches have moved forward independently** - say `main` got a new commit *while* `feature-signup` was also getting new commits - there's no single straight line connecting them anymore. Git has to create a brand-new **merge commit** that has **two parents** (one commit from each branch), stitching both timelines together.

- **A merge conflict** happens when Git tries to auto-combine both branches but finds that **the exact same line(s)** of the **same file** were edited differently in each branch. Git has no way to guess which version you want, so it pauses everything, inserts conflict markers directly into the file, and asks you to manually pick (or combine) the correct content before finishing the merge.

Conflict markers look like this inside the file:
```
<<<<<<< HEAD
Hello from main
=======
Hello from feature
>>>>>>> feature-conflict
```
Everything between `<<<<<<<` and `=======` is *your current branch's* version; everything between `=======` and `>>>>>>>` is the *incoming branch's* version. You edit the file to keep whatever is correct, delete the markers, then stage and commit.

### 💻 Hands-on

**Part A - Fast-forward merge:**
```bash
git checkout -b feature-login
echo "login page v1" >> login.txt
git add login.txt
git commit -m "feat: add login page skeleton"
echo "login page v2" >> login.txt
git commit -am "feat: add login validation"

git checkout main
git merge feature-login
```
**Observation:** `main` hadn't moved, so Git just fast-forwarded the pointer. No merge commit - history stayed a straight line.

**Part B - Real merge commit:**
```bash
git checkout -b feature-signup
echo "signup page v1" >> signup.txt
git add signup.txt
git commit -m "feat: add signup page"

git checkout main
echo "main update" >> readme.txt
git commit -am "chore: update readme on main"

git checkout main
git merge feature-signup
```
**Observation:** `main` had diverged (it had a commit `feature-signup` didn't have), so Git created a **merge commit** with two parents instead of fast-forwarding.

**Part C - Intentional conflict:**
```bash
# On main
echo "Hello from main" > shared.txt
git commit -am "main: edit shared.txt"

git checkout -b feature-conflict
echo "Hello from feature" > shared.txt
git commit -am "feature: edit shared.txt"

git checkout main
git merge feature-conflict
# CONFLICT (content): Merge conflict in shared.txt
```
I opened `shared.txt`, manually resolved the conflict markers, kept the correct content, then:
```bash
git add shared.txt
git commit -m "fix: resolve merge conflict in shared.txt"
```

### ✅ Answers
- **What is a fast-forward merge?** When the current branch hasn't diverged at all, Git just moves the branch pointer forward to the other branch's tip - no new commit, history stays linear.
- **When does Git create a merge commit instead?** When both branches have independent commits (they've diverged) - Git combines them into a new commit with two parents.
- **What is a merge conflict?** When the same lines in the same file were changed differently on both branches, so Git can't auto-decide and asks a human to resolve it manually.

---

## Task 2: Git Rebase - Hands-On

### 📌 What this task asked
- Create `feature-dashboard` from `main`, add 2–3 commits
- Move `main` ahead with a new commit
- Rebase `feature-dashboard` onto `main`
- Compare the resulting history graph to a merge

### 📖 Concept - explained simply
**Rebase answers a different question than merge.** Instead of asking "how do I combine two separate timelines?", rebase asks: **"What if my branch had started *after* the latest changes on main, instead of before them?"**

Here's what actually happens step by step:
1. Git temporarily "removes" all the commits that exist only on your branch (like taking them off to the side).
2. It moves your branch's starting point up to the latest commit on `main`.
3. It **replays your commits one by one, in order, on top of that new starting point** - as if you had written them just now, starting from where `main` currently is.

Because each replayed commit now has a *different parent* than before, Git has to generate a **brand-new commit hash** for each one - even if the code change and message are identical to the original. The old commits aren't edited; they're technically replaced by new copies, and the old ones become orphaned.

**Why this matters for history:** a merge keeps the real, messy, parallel story ("these two things happened at the same time and then joined"). A rebase erases that parallel story and makes it look like everything happened one-after-another in a single straight line - cleaner to read, but it's a *rewritten* version of events, not the literal truth of what happened.

**Why rebase is dangerous on shared/pushed commits:** if you've already pushed commits and a teammate has pulled them (or built more commits on top of them), and you then rebase and force-push, you are replacing those commits with new ones (new hashes). Your teammate's Git history now refers to commits that no longer exist upstream. When they try to push/pull, Git gets confused - duplicated commits, painful conflicts, or lost work can result. The rule of thumb: **only rebase commits that exist only in your own local/private branch.**

### 💻 Hands-on
```bash
git checkout -b feature-dashboard main
echo "widget 1" >> dashboard.txt
git commit -am "feat: add widget 1"
echo "widget 2" >> dashboard.txt
git commit -am "feat: add widget 2"
echo "widget 3" >> dashboard.txt
git commit -am "feat: add widget 3"

git checkout main
echo "main hotfix" >> readme.txt
git commit -am "fix: quick hotfix on main"

git checkout feature-dashboard
git rebase main
```

**Observation with `git log --oneline --graph --all`:** After the rebase, `feature-dashboard`'s three commits now sit directly **on top of** main's hotfix commit, all in one straight vertical line. There's no "diamond"/fork shape like a merge would show, and no merge commit - it looks exactly as if I had branched off *after* the hotfix happened.

### ✅ Answers
- **What does rebase actually do to your commits?** It sets your branch's unique commits aside, moves your branch's base to the latest commit of the target branch, then replays your commits on top one by one - each gets a new hash because its parent changed.
- **How is the history different from a merge?** Merge preserves the real parallel timeline with a two-parent merge commit. Rebase rewrites history into a clean, linear sequence with no merge commit - it shows what it would look like *if* the work had happened sequentially, not what actually happened.
- **Why should you never rebase commits that have been pushed and shared with others?** Because rebase replaces old commits with new ones (new hashes). If others already have the old commits, force-pushing a rebase breaks their history and causes conflicts/duplicated commits/lost work.
- **When would you use rebase vs merge?** Rebase for cleaning up your own private/local branch before sharing it, or to update your feature branch with the latest `main` without extra merge-commit clutter. Merge for combining already-shared work, or when you want the true history of divergence and integration preserved (e.g. pull requests into `main`).

---

## Task 3: Squash Commit vs Merge Commit

### 📌 What this task asked
- Create `feature-profile` with 4–5 small commits, merge with `--squash` → check how many commits landed on `main`
- Create `feature-settings`, merge normally (no squash) → compare history
- Answer what squash does, when to use it, and its trade-off

### 📖 Concept - explained simply
A normal merge brings across **every individual commit** from the feature branch, plus (usually) one merge commit tying them together. If your feature branch had commits like "wip", "fix typo", "formatting", "oops forgot semicolon" - all of that noise ends up permanently in `main`'s history.

**Squash merge takes a shortcut:** instead of bringing across each individual commit, Git calculates the *total combined difference* your branch introduces (as if all those commits were flattened into one), stages that as one big change, and lets you write **one single commit message** for the whole feature. The original small commits still technically exist on the feature branch, but `main` never sees them individually - only the one squashed commit.

**Trade-off:** You get a clean, readable `main` log (one line per feature). But you lose the ability to see *who* changed *what*, *when*, at a granular level - which matters if you ever need `git bisect` (binary-search which exact small commit introduced a bug) or want to `git revert` just one small piece of a feature instead of the whole thing.

### 💻 Hands-on

**Squash merge:**
```bash
git checkout -b feature-profile main
echo "a" >> profile.txt && git commit -am "wip: add profile file"
echo "b" >> profile.txt && git commit -am "fix typo"
echo "c" >> profile.txt && git commit -am "formatting"
echo "d" >> profile.txt && git commit -am "small tweak"
echo "e" >> profile.txt && git commit -am "final cleanup"

git checkout main
git merge --squash feature-profile
git commit -m "feat: add user profile page"
```
**Observation:** `git log` on `main` shows only **ONE new commit**. All 5 small commits were flattened into that single commit - the messy individual history never touched `main`.

**Regular merge (for comparison):**
```bash
git checkout -b feature-settings main
echo "s1" >> settings.txt && git commit -am "feat: add settings toggle"
echo "s2" >> settings.txt && git commit -am "feat: add settings save button"

git checkout main
git merge feature-settings
```
**Observation:** This time, both individual commits from `feature-settings` appear on `main`, plus a merge commit (since `main` had already moved ahead due to the earlier squash commit) - the full step-by-step history is preserved.

### ✅ Answers
- **What does squash merging do?** Combines all commits from a branch into a single new commit on the target branch, discarding the individual commit-by-commit history.
- **When would you use squash merge vs regular merge?** Squash when the branch has messy/noisy WIP commits you don't need individually. Regular merge when each commit is meaningful and you want that granularity preserved for review/debugging.
- **What is the trade-off of squashing?** Cleaner `main` history, but loss of granular detail - harder to `bisect` or revert a single small change within the feature after it's squashed.

---

## Task 4: Git Stash - Hands-On

### 📌 What this task asked
- Start editing a file without committing, then try switching branches
- Use `git stash` to save the work-in-progress
- Switch branches, do other work, switch back, then `git stash pop`
- Stash multiple times, list all stashes, apply a specific one

### 📖 Concept - explained simply
Git normally won't let you switch branches if it would silently overwrite uncommitted changes that conflict with the branch you're switching to - it'll throw an error like `Your local changes would be overwritten by checkout`. But you're not ready to commit yet (the work is half-done). This is exactly the problem **stash** solves.

Think of `git stash` as a **clipboard/shelf for unfinished work**: it takes your uncommitted changes (staged and unstaged), tucks them away safely, and gives you back a clean working directory - as if you had never touched anything. You can then freely switch branches, do whatever's urgent, and come back later to pull your unfinished work back out exactly where you left it.

You can stash **multiple times** - each stash gets pushed onto a list (`stash@{0}` is the most recent, `stash@{1}` the one before that, etc.), and you can choose to bring back a specific one instead of just the latest.

**`apply` vs `pop`** - the key difference is whether the stash is deleted after restoring:
- `git stash apply` → restores the changes but **keeps a copy in the stash list** (good if you might want to apply that same stash again, e.g. to a different branch).
- `git stash pop` → restores the changes and **removes it from the list** (good for a simple one-time restore).

### 💻 Hands-on
```bash
# Start editing without committing
echo "wip changes" >> dashboard.txt

# Try to switch branches
git checkout main
# Git either carries the change over (if no conflict) or blocks the switch
# with "error: Your local changes would be overwritten by checkout"

git stash push -m "wip dashboard changes"
git checkout main
echo "some other work" >> readme.txt
git commit -am "chore: unrelated work on main"

git checkout feature-dashboard
git stash pop
```

**Multiple stashes + selective apply:**
```bash
echo "change A" >> file1.txt
git stash push -m "stash A"

echo "change B" >> file2.txt
git stash push -m "stash B"

git stash list
# stash@{0}: On feature-dashboard: stash B
# stash@{1}: On feature-dashboard: stash A

git stash apply stash@{1}   # applies "stash A" specifically, without removing it from the list
```

### ✅ Answers
- **What is the difference between `git stash pop` and `git stash apply`?** Both restore the changes into your working directory; `apply` keeps the stash in the list afterward, `pop` deletes it after restoring.
- **When would you use stash in a real-world workflow?** When you're mid-way through uncommitted work and something urgent (e.g. a production bug) forces you to switch branches immediately - stash lets you shelve your unfinished work cleanly instead of making a messy "wip" commit, and pick it back up later exactly as you left it.

---

## Task 5: Cherry Picking

### 📌 What this task asked
- Create `feature-hotfix` with 3 commits with different changes
- Switch to `main` and cherry-pick **only the second** commit
- Verify via `git log` that only that one commit landed on `main`

### 📖 Concept - explained simply
Sometimes you don't want an *entire* branch merged into `main` - you just want **one specific commit** from it. Maybe the branch has an unfinished feature, but one of its commits happens to be a critical bug fix that needs to go live right now.

`git cherry-pick <commit-hash>` does exactly this: it looks at what that **one commit** changed, and re-applies that exact change onto your current branch, wrapping it in a **brand-new commit** (new hash, but same content/message by default) - without touching or bringing over any of the other commits from that branch.

This is powerful, but it comes with a few gotchas:
- **Conflicts** can happen if the surrounding code on `main` has changed since that commit was made.
- **Duplicate commits**: if that branch is later merged normally, Git will see the original commit and the cherry-picked copy as two *different* commits (different hashes) even though they represent the same change - this can clutter history or occasionally cause redundant conflicts.
- **Missing context**: if the commit you're picking depends on something introduced in an *earlier* commit on that branch (a helper function, a variable, etc.) that you didn't also bring over, cherry-picking it alone can break the build.

### 💻 Hands-on
```bash
git checkout -b feature-hotfix main
echo "fix 1" >> hotfix.txt && git commit -am "fix: null pointer in login"
echo "fix 2" >> hotfix.txt && git commit -am "fix: broken signup redirect"
echo "fix 3" >> hotfix.txt && git commit -am "fix: typo in error message"

git log --oneline
# a1b2c3d fix: typo in error message
# d4e5f6g fix: broken signup redirect     <-- I want only this one
# h7i8j9k fix: null pointer in login

git checkout main
git cherry-pick d4e5f6g
git log --oneline
```
**Verification:** `git log` on `main` shows only the "fix: broken signup redirect" commit was added, as a new commit with a new hash. The other two commits from `feature-hotfix` are **not** present on `main`.

### ✅ Answers
- **What does cherry-pick do?** Applies the change from one specific commit onto your current branch as a new commit, without bringing over the rest of the source branch's commits.
- **When would you use cherry-pick in a real project?** Shipping a critical bug fix from an unfinished feature branch straight to `main`/a release branch; backporting a fix to an older release branch; grabbing one useful commit from a branch that isn't otherwise ready to merge.
- **What can go wrong with cherry-picking?** Merge conflicts if surrounding code changed; duplicate commits if the branch is later merged normally too; broken builds if the picked commit depended on context from an earlier commit you didn't also bring over.

---

## Key Takeaways (for quick revision)

| Concept | One-line meaning |
|---|---|
| **Fast-forward merge** | No divergence → pointer just slides forward, no new commit |
| **Merge commit** | Branches diverged → new commit with 2 parents, real history preserved |
| **Merge conflict** | Same lines/file changed differently on both branches → manual resolution needed |
| **Rebase** | Replays your commits on top of a new base → clean linear history, but rewrites hashes - never do on shared/pushed commits |
| **Squash merge** | Collapses many small commits into one clean commit on target branch → simpler history, less granularity |
| **Stash** | Temporary shelf for uncommitted work so you can safely switch branches and return later |
| **Cherry-pick** | Surgically applies one specific commit to another branch, independent of the rest of its source branch |

## Quick Reference - Commands Used Today

| Scenario | Command |
|---|---|
| Fast-forward merge | `git merge <branch>` (when no divergence) |
| Merge with conflict | `git merge <branch>` → resolve → `git add` → `git commit` |
| Abort a messy merge | `git merge --abort` |
| Rebase onto main | `git checkout feature && git rebase main` |
| Continue/abort rebase | `git rebase --continue` / `git rebase --abort` |
| Squash merge | `git merge --squash <branch>` → `git commit -m "msg"` |
| Save WIP work | `git stash push -m "message"` |
| List stashes | `git stash list` |
| Apply specific stash | `git stash apply stash@{n}` |
| Restore + delete stash | `git stash pop` |
| Delete a stash | `git stash drop stash@{n}` |
| Cherry-pick a commit | `git cherry-pick <commit-hash>` |
| Continue/abort cherry-pick | `git cherry-pick --continue` / `git cherry-pick --abort` |
| Visualize all branches | `git log --oneline --graph --all` |
