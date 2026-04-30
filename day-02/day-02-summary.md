# 📋 Day 02 — Summary & Learnings

---

##  What I Learned Today:

### Linux Architecture, Processes, systemd:

- Linux → "Linux is a kernel."
- Linux OS → "A Linux OS is a distribution combining the Linux kernel with user-space tools and software."
- Process → "A process is a running program in user space."
- System Call → "A system call is the interface through which a process interacts with the kernel."
- Kernel → "The kernel manages system resources and interacts with hardware via device drivers."
- Shell vs Terminal → "Terminal is the interface; shell is the command interpreter running inside it."

---
- Every process is born from a parent via `fork()` → `exec()`
- PID 1 is always systemd - it's the root of everything
- Zombie processes = finished but not cleaned up by parent. Usually harmless unless many pile up.

---
- It's not just a service manager - it handles boot order, dependencies, logs, and restarts
- `journalctl` is underrated - I used to `cat` log files but this is cleaner
- `enable` vs `start` - I finally understand the difference properly today

---

##  Concepts at a Glance:

| Topic | Key Takeaway |
|-------|-------------|
| Kernel | Core OS layer, manages hardware, you interact via system calls |
| User Space | Where apps and shell live |
| systemd | PID 1, starts everything, manages services and logs |
| fork() | How all processes are born |
| Zombie State | Dead process, parent hasn't cleaned it up |
| journalctl | Centralized logging — better than digging log files |

---

##  Commands I'm Taking Away:

```bash
pstree                        # Visual process tree
ps aux --forest               # Process tree with resource usage
systemctl status <service>    # First thing to run when something breaks
journalctl -u <service> -f    # Live service logs
journalctl -xe                # Recent system-wide errors
man <command>                 # Read documentation for any command
```

---
