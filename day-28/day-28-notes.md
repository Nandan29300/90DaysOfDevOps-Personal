# Day 28 – Revision: Days 1–27

> **Goal:** Consolidate the Linux, networking, shell scripting, Git, and GitHub work completed so far. This is a revision day: no new topic, just practice, verification, and identifying the next areas to strengthen.

---

## 1. Journey recap

| Days | Area | Evidence in this repository |
| --- | --- | --- |
| 01–12 | DevOps foundations and Linux administration | Learning plan, command notes, process/service practice, user and permissions exercises, and the first revision |
| 13–15 | Storage and networking | LVM loopback/EBS notes plus networking fundamentals and concepts |
| 16–21 | Shell scripting and automation | Scripting exercises, log-analyzer project, and a personal shell cheat sheet |
| 22–26 | Git, GitHub, and GitHub CLI | Git command reference and daily workflow notes |
| 27 | Developer presence | GitHub profile and repository-organization notes |

The folder-per-day structure is consistent, while reusable reference material stays easy to find:

- [Shell scripting cheat sheet](../day-21/shell_scripting_cheatsheet.md)
- [Git and GitHub command reference](../day-22/git-commands.md)
- [First revision: Days 1–11](../day-12/revision.md)

---

## 2. Self-assessment

Legend: **Confident** = can perform and explain without notes; **Revisit** = understand the idea but need more hands-on repetition; **Practice next** = not yet strong enough to rely on in a real task.

### Linux and networking

| Skill | Assessment | Revision note |
| --- | --- | --- |
| Navigate, create, move, and remove files/directories | Confident | Regularly used `pwd`, `ls`, `mkdir -p`, `cp`, `mv`, and careful `rm`. |
| Inspect and manage processes | Confident | Use `ps`, `pgrep`, `top`, `kill`, and job control for investigation. |
| Manage services with systemd | Confident | Start with `systemctl status`; then inspect `journalctl` when needed. |
| Read/edit text with nano or vim | Confident | Comfortable editing configuration and text files. |
| Diagnose CPU, memory, and disk pressure | Confident | Use `top`, `free -h`, `df -h`, and `du -sh`. |
| Explain filesystem hierarchy | Confident | Can explain `/`, `/etc`, `/var`, `/home`, `/tmp`, `/usr`, and `/proc`. |
| Manage users, groups, and passwords | Confident | Practised `useradd`, `groupadd`, `usermod`, `id`, and `passwd`. |
| Set permissions and ownership | Confident | Can use symbolic/octal `chmod`, `chown`, and `chgrp`; verify with `ls -l`. |
| Create and extend LVM storage | Revisit | Know the PV → VG → LV model; need more repeat practice with resize and recovery planning. |
| Check connectivity and listening ports | Confident | Use `ping`, `curl`, `ss -ltnp`, `ip`, `dig`, and `nslookup`. |
| Explain DNS, addressing, subnets, and ports | Revisit | DNS and common ports are solid; subnet calculations need more timed practice. |

### Shell scripting

| Skill | Assessment | Revision note |
| --- | --- | --- |
| Variables, input, and arguments | Confident | Quote variables and validate required arguments. |
| Conditions and `case` | Confident | Use `if` for checks and `case` for readable multi-option input. |
| `for`, `while`, and `until` loops | Confident | Choose loops based on list iteration, condition, or retry behavior. |
| Functions and arguments | Confident | Use functions to make scripts smaller and reusable. |
| `grep`, `awk`, `sed`, `sort`, `uniq` | Confident | Applied to log analysis and text processing. |
| Strict mode, traps, and failure handling | Revisit | Understand `set -euo pipefail`; need to make it a default habit in every new script. |
| Schedule jobs with cron | Confident | Can create and inspect a user crontab. |

### Git and GitHub

| Skill | Assessment | Revision note |
| --- | --- | --- |
| Initialize, stage, commit, and inspect history | Confident | Normal daily workflow is comfortable. |
| Create and switch branches | Confident | Use `git switch -c <branch>` for new work. |
| Push, fetch, and pull | Confident | Can explain local versus remote-tracking state. |
| Explain clone versus fork | Confident | Clone copies a repository locally; a fork is a server-side copy under another account/namespace. |
| Merge branches | Confident | Understand fast-forward and merge-commit outcomes. |
| Rebase a branch | Revisit | Understand the model; need more conflict-resolution repetition before using it on important work. |
| Stash and restore work | Confident | Use a named stash before switching context. |
| Cherry-pick a commit | Revisit | Know the command; need more practice identifying the safe commit and handling conflicts. |
| Compare squash and regular merge | Confident | Choose based on whether branch-level history is valuable. |
| Reset and revert | Confident | Use `revert` for shared history and keep `reset --hard` for disposable local work only. |
| Explain GitFlow, GitHub Flow, and trunk-based development | Confident | Can select a workflow based on release cadence and team needs. |
| Use GitHub CLI for repos, issues, PRs, and Actions | Confident | The command reference includes the workflows practised on Day 26. |

---

## 3. Three targeted refreshers

### A. LVM: from disk to usable filesystem

LVM adds a flexible layer between disks and filesystems. A **physical volume** (PV) is a disk or partition prepared for LVM. PVs belong to a **volume group** (VG), a storage pool. A **logical volume** (LV) is allocated from that pool and then formatted and mounted like a normal partition.

Safe loopback practice flow (use a disposable image, not a production disk):

```bash
# Create a disposable 1 GiB virtual disk for practice.
truncate -s 1G lvm-practice.img
sudo losetup --find --show lvm-practice.img

# Replace /dev/loopX with the device returned above.
sudo pvcreate /dev/loopX
sudo vgcreate practice-vg /dev/loopX
sudo lvcreate --name data-lv --size 512M practice-vg
sudo mkfs.ext4 /dev/practice-vg/data-lv

sudo mkdir -p /mnt/lvm-practice
sudo mount /dev/practice-vg/data-lv /mnt/lvm-practice
df -h /mnt/lvm-practice
```

The important verification commands are `pvs`, `vgs`, `lvs`, `lsblk`, and `df -h`. Before extending a live filesystem, verify the filesystem type and use its matching growth command (`resize2fs` for ext4; `xfs_growfs` for XFS). Never shrink or remove a volume without a tested backup.

### B. DNS and subnetting

DNS turns a name into an IP address. A client typically checks local sources/cache, asks its configured recursive resolver, and that resolver follows the DNS hierarchy until it can return a cached or authoritative answer.

```bash
dig example.com A +short
dig example.com MX
nslookup example.com
ip route
ss -ltnp
```

For IPv4 subnetting, the prefix length determines host bits: `/24` leaves 8 host bits and has 256 total addresses; `/26` leaves 6 host bits and has 64 total addresses. In a traditional IPv4 subnet, usable hosts are total addresses minus network and broadcast addresses. The key habit is to calculate the block size and identify the network, broadcast, and usable range before assigning an address.

### C. Rebase and cherry-pick safely

Rebase rewrites the current branch’s commits so they appear on top of a newer base. It produces a tidy linear history, but because commit IDs change it should not be used to rewrite a branch that others are already using.

```bash
# Update a private feature branch with the latest main branch.
git fetch origin
git switch feature/my-change
git rebase origin/main

# If there is a conflict: resolve it, stage the resolution, then continue.
git add <resolved-file>
git rebase --continue
# Or abandon the rebase safely.
git rebase --abort

# Apply one known-good commit to the current branch.
git cherry-pick <commit-sha>
```

Cherry-pick copies one commit’s patch onto the current branch. It is useful for an isolated bug fix, but it can duplicate work if the same change is later merged another way. Inspect the commit first with `git show <commit-sha>`.

---

## 4. Quick-fire answers

1. **What does `chmod 755 script.sh` do?**  It gives the owner read, write, and execute permissions (`7`), and gives group and others read and execute permissions (`5` each). It makes a script executable by everyone but writable only by its owner.

2. **What is the difference between a process and a service?**  A process is any running program with a PID. A service is usually a long-running, managed process that performs a system function and is commonly controlled by a service manager such as systemd.

3. **How do you find which process is using port 8080?**  Run `sudo ss -ltnp 'sport = :8080'`. `sudo lsof -i :8080` is another useful option.

4. **What does `set -euo pipefail` do?**  `-e` stops on an unhandled command failure, `-u` treats an unset variable as an error, and `pipefail` makes a pipeline fail when any command in it fails instead of only checking the final command. It makes failures visible earlier, but commands expected to fail need explicit handling.

5. **What is the difference between `git reset --hard` and `git revert`?**  `reset --hard` moves the current branch and discards staged and working-tree changes; it rewrites local history and is dangerous. `revert` creates a new commit that reverses an earlier commit, preserving shared history.

6. **Which branching strategy fits five developers shipping weekly?**  GitHub Flow is a practical default: short-lived feature branches, pull requests, CI, and a continuously deployable `main` branch. If releases require a stabilization period, add a short-lived release branch; do not add full GitFlow complexity unless the release process genuinely needs it.

7. **What does `git stash` do and when would you use it?**  It temporarily saves uncommitted tracked changes and restores a clean working tree. Use it to switch branches or investigate an urgent issue without making a work-in-progress commit. Prefer `git stash push -m "description"` so the stash is identifiable.

8. **How do you schedule a script for every day at 3 AM?**  Add this entry with `crontab -e`: `0 3 * * * /absolute/path/to/script.sh >> /absolute/path/to/script.log 2>&1`. Use absolute paths because cron has a minimal environment.

9. **What is the difference between `git fetch` and `git pull`?**  `git fetch` downloads remote commits and updates remote-tracking references without changing the current branch. `git pull` performs a fetch and then integrates the configured upstream branch, usually by merge or rebase.

10. **What is LVM and why use it instead of regular partitions?**  LVM is Logical Volume Management: it pools storage from one or more physical volumes into volume groups, then allocates logical volumes. It makes storage allocation, extension, snapshots, and multi-disk management more flexible than fixed traditional partitions.

---

## 5. Teach it back: Git branching

A Git branch is like making a safe copy of a document before trying a new idea. The main branch holds the version people trust. A feature branch lets one person change the login screen, fix a bug, or write documentation without disturbing that trusted version. Other people can keep working on their own branches at the same time. When the work is reviewed and tested, the feature branch is merged back into the main branch. If the experiment does not work, the branch can be deleted and the main version remains safe. This lets a team make changes in parallel without overwriting one another’s work.

---

## 6. Final repository review

- Daily work from Day 1 through Day 28 is grouped in `day-01` through `day-28`.
- The reusable Git reference is maintained in [`day-22/git-commands.md`](../day-22/git-commands.md).
- The reusable shell reference is maintained in [`day-21/shell_scripting_cheatsheet.md`](../day-21/shell_scripting_cheatsheet.md).
- Day 20 scripts are retained as executable `.sh` files, alongside their explanation.
- Before pushing, use `git status`, review with `git diff --check`, and confirm no secrets or local environment files are staged.

## Next practice targets

1. Perform LVM extension and filesystem growth end-to-end on a disposable loopback disk.
2. Solve a small set of subnetting exercises until the network/broadcast/host range can be calculated quickly.
3. Rebase and cherry-pick in a throwaway Git repository, including intentionally resolving one conflict.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
