# 🐧 Linux Commands Cheat Sheet
> **Day 03 – #90DaysOfDevOps**  
> A practical toolkit for process management, file system operations, and network troubleshooting.

---

## ⚙️ Process Management
*Manage running tasks, monitor system resources, and control process execution.*

- `ps aux` – Display a full snapshot of **all** currently running processes (user, PID, CPU%, MEM%).
- `top` – Live, auto-refreshing view of processes sorted by CPU/memory usage. Press `q` to quit.
- `htop` – Interactive and colorful process viewer; easier to navigate than `top` (install if not present).
- `kill <pid>` – Send a signal (default: SIGTERM) to terminate the process with the given PID. Example: `kill 1234`.
- `killall <name>` – Kill **all** processes matching a given name. Example: `killall firefox`.
- `pkill <pattern>` – Kill processes by name pattern or attribute. Example: `pkill -u username` kills all processes of a user.
- `pgrep <name>` – Find and print PIDs of processes matching a name. Example: `pgrep nginx`.
- `bg %1` – Resume a suspended (Ctrl+Z) job in the **background**. The `%1` refers to job number 1.
- `fg %1` – Bring a **background** job back to the foreground.
- `command &` – Append `&` to any command to run it in the **background** from the start. Example: `./script.sh &`.

---

## 📂 File System
*Navigate, manipulate, inspect, and manage files and directories.*

- `pwd` – Print Working Directory — shows your current full path. Example output: `/home/user/projects`.
- `ls -lah` – List directory contents with **l**ong format, **a**ll hidden files, **h**uman-readable sizes.
- `cd /path/to/dir` – Change current directory. Use `cd ..` to go up one level, `cd ~` for home.
- `cp -r source dest` – Copy files or directories; `-r` flag is required for directories (recursive).
- `mv file.txt newname.txt` – Move or rename a file/directory.
- `rm -rf dir_name` – Remove files/directories forcefully and recursively. ⚠️ **Use with extreme caution.**
- `mkdir -p /a/b/c` – Create directory and all missing **parent** directories in one shot.
- `chmod 755 script.sh` – Change file permissions. `7=rwx`, `5=r-x`. Format: owner / group / others.
- `chown user:group file` – Change the **owner** and **group** of a file.
- `df -h` – Show overall disk space usage for all mounted filesystems in **human-readable** format.
- `du -sh folder/` – Show the **total size** of a specific directory. `-s` = summary, `-h` = human-readable.
- `find /path -name "*.log"` – Search for files by name, type, size, or modification time recursively.
- `grep "pattern" file.txt` – Search for a text pattern inside a file. Add `-r` to search recursively.
- `head -n 20 file.log` – Display the **first** 20 lines of a file (default is 10).
- `tail -f file.log` – Display the **last** lines of a file; `-f` **follows** new output live — perfect for logs.
- `wc -l file.txt` – Count lines (`-l`), words (`-w`), or characters (`-c`) in a file.

---

## 🌐 Networking Troubleshooting
*Diagnose connectivity, inspect interfaces, and transfer/query data.*

- `ip addr show` – Display all network interfaces and their assigned IP addresses (modern replacement for `ifconfig`).
- `ping -c 4 google.com` – Send 4 ICMP echo requests to test **reachability** of a host. Ctrl+C to stop.
- `curl -I https://example.com` – Fetch only **HTTP headers** from a URL. Useful to check server response codes.
- `dig google.com` – Perform a **DNS lookup** and display detailed query/response info. Great for debugging DNS.
- `traceroute google.com` – Trace the **hop-by-hop** route packets take to reach a destination host.
- `ss -tulnp` – **Socket statistics** — modern, faster replacement for `netstat`. Shows all TCP/UDP listening ports with the process using them. `-t`=TCP, `-u`=UDP, `-l`=listening, `-n`=numeric and not names, `-p`=process name and PID.
- `ss -s` — quick summary of socket counts
- `netstat -a` – Show all active TCP/UDP **listening ports** and their associated programs. (Legacy; prefer `ss` on modern systems.)
- `wget <url>` – Download a file from the internet directly to disk. Example: `wget https://example.com/file.zip`.
- `nslookup domain.com` – Quick DNS query to find the **IP address** of a domain.
- `host domain.com` – Simple DNS lookup; prints A, MX records. Simpler than `dig`.
- `whois domain.com` – Look up **registration info** (owner, registrar, expiry) for a domain name.

---

## 💡 Quick Tips

| Tip | Command |
|-----|---------|
| Find who is using port 80 | `sudo lsof -i :80` |
| Check last login history | `last` |
| Show command history | `history` |
| Clear terminal screen | `clear` or `Ctrl + L` |
| Run previous command as sudo | `sudo !!` |

---

> 📌 **Remember:** `man <command>` opens the manual for any command. When in doubt, read the man page!
