# 📝 Day 04 Summary - Linux Processes and Services

**Topic:** Processes, Services & Logs on Ubuntu Linux

---

## What I Practiced Today

Today's focus was getting comfortable with three core Linux skills every DevOps engineer uses daily: monitoring processes, managing services with `systemctl`, and reading logs with `journalctl`.

---

## Commands I Ran

### 🔵 Process Commands

| Command | Purpose |
|---|---|
| `ps aux` | Listed all running processes with CPU/memory usage |
| `ps aux --sort=-%mem \| head -n 11` | Found top 10 memory consumers |
| `pgrep -a sshd` | Located all SSH daemon processes and their PIDs |
| `top -n 1 -b` | Captured a real-time system snapshot in batch mode |

**What stood out:** SSH creates 3 separate processes per session - main listener, a privileged child, and the actual user shell. That explains why `pgrep sshd` shows multiple PIDs even with one active connection.

---

### 🔵 Service Commands

| Command | Purpose |
|---|---|
| `systemctl status ssh` | Checked SSH health, uptime, and recent logs |
| `systemctl list-units --type=service --state=running` | Listed all 18 currently running services |
| `systemctl is-enabled ssh` | Confirmed SSH auto-starts on reboot |

**What stood out:** The `systemctl status` output combines service state AND recent logs in one view - very useful for quick diagnostics without running a separate `journalctl` command.

---

### 🔵 Log Commands

| Command | Purpose |
|---|---|
| `journalctl -u ssh -n 30 --no-pager` | Viewed last 30 SSH service log entries |
| `journalctl -u ssh -f` | Followed SSH logs live in real-time |
| `sudo tail -n 30 /var/log/auth.log` | Read authentication events (logins, sudo) |

**What stood out:** Found brute-force login attempts in the logs - an external IP (`103.45.67.89`) tried `admin`, `root`, and `test` in quick succession. This is completely normal on internet-facing servers and why `fail2ban` exists.

---

## Service I Inspected: SSH (`sshd`)

I chose SSH because it's the entry point to any Linux server - understanding it deeply matters for DevOps work.

**What I learned about SSH:**
- Runs as `root` but spawns user-owned processes after auth
- Uses public key authentication (more secure than passwords)
- Logs every connection attempt 0 great for security auditing
- Only uses ~3.2 MB of memory - extremely lightweight for what it does

---

## Troubleshooting Scenario I Practiced

Simulated a broken SSH config (`Port22` instead of `Port 22`) and walked through the full debug cycle:

```
systemctl status → journalctl logs → sshd -t → fix config → sshd -t → start → verify
```

**Key insight:** Always validate config with `sudo sshd -t` before restarting - it catches syntax errors without breaking the running service.

---

## Concepts That Clicked Today

**Process States (STAT column in `ps`):**
- `S` = Sleeping (waiting for input/event)
- `R` = Running (actively using CPU)
- `Z` = Zombie (finished but parent hasn't cleaned up)
- `s` = Session leader
- `l` = Multi-threaded

**systemd Service States:**
- `active (running)` = healthy, process is alive
- `active (exited)` = one-time task that completed successfully
- `inactive (dead)` = not running (may be normal or a problem)
- `failed` = crashed or errored out

**journalctl vs /var/log files:**
- `journalctl` = structured, queryable, faster for filtering
- `/var/log/*.log` = plain text, traditional, works with `grep`/`tail`
- Both exist on Ubuntu; systemd services primarily log to journal

---

## Security Note from Today

While reading `auth.log`, I noticed a pattern that every Linux admin should recognize:

```
Failed password for invalid user admin from 103.45.67.89
Failed password for invalid user root from 103.45.67.89
Failed password for invalid user test from 103.45.67.89
```

This is an **automated brute-force scan** - bots continuously scan the internet for open SSH ports and try common usernames. Defenses:
- Use SSH key authentication (disable password auth)
- Change default port 22 (security through obscurity, but reduces noise)
- Install `fail2ban` to auto-block IPs after N failed attempts
- Use firewall rules to restrict SSH access to known IPs only

---

## Resources I Used

- `man systemctl` - built-in manual pages
- `man journalctl`
- Class notes from Day 02 (file permissions) and Day 03 (networking)
- [systemd documentation](https://www.freedesktop.org/wiki/Software/systemd/)

---
