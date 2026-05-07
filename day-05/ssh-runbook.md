# 🔐 SSH Service – Linux Troubleshooting Runbook

**Date:** 07-05-2026

**Target Service:** `sshd` (OpenSSH Daemon)

---

## 1. Environment Basics

### ` uname -a `

Command Output:
```
Linux nandan-Victus 6.8.0-100-generic #100~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Mon Jan 19 17:10:19 UTC  x86_64 x86_64 x86_64 GNU/Linux
```

> **Note:** Kernel is 6.8.0 (Ubuntu 22.04 LTS HWE kernel). x86_64 architecture. PREEMPT_DYNAMIC indicates a low-latency preemptible kernel - common on laptops (Victus). No custom/patched kernel - stable Ubuntu base.


- nandan-Victus - your hostname, HP Victus laptop
- 6.8.0-100-generic - newer HWE (Hardware Enablement) kernel, not the default 5.15 - worth noting
- PREEMPT_DYNAMIC - this flag only appears on HWE kernels, good to mention

---

### `lsb_release -a`

```
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 22.04.5 LTS
Release:        22.04
Codename:       jammy
```

> **Note:** Running Ubuntu Jammy (22.04 LTS). Long-term support release - security patches are current.

---

## 2. Filesystem Sanity Check

### Create throwaway folder and copy a file

```bash
:~$ mkdir /tmp/runbook-demo
:~$ cp /etc/hosts /tmp/runbook-demo/hosts-copy && ls -l /tmp/runbook-demo
```

Command Output:
```
total 4
-rw-r--r-- 1 nandan nandan 380 May  7 09:14 hosts-copy
```

> **Note:** `/tmp` is writable, filesystem is healthy. File copy succeeded without errors — no disk I/O issues at this stage.

---

## 3. Snapshot: CPU & Memory

### Find SSH PID and inspect it

```bash
:~$ pgrep sshd
:~$ ps -o pid,pcpu,pmem,comm -p 1023
```

Command Output:

```
    PID %CPU %MEM COMMAND
    800  0.0  0.1  sshd
```

> **Note:** `sshd` PID is 800, nearly idle at 0.0% CPU and 0.1% memory. Expected behaviour — SSH daemon just sits and waits for incoming connections, consuming almost no resources.

---

### `free -h`

Command Output:

```
               total        used        free      shared  buff/cache   available
Mem:           7.4Gi       1.7Gi       2.5Gi       455Mi     3.2Gi      5.0Gi
Swap:          2.0Gi         0B        2.0Gi
```

> **Note:** Swap is completely unused - system is not memory-pressured. ~5.0 GiB available memory. SSH is not contributing to memory stress.

---

## 4. Snapshot: Disk & IO

### `df -h`

Command Output:

```
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           758M  2.8M  755M   1% /run
/dev/nvme0n1p6   96G   58G   34G  64% /
tmpfs           3.7G   38M  3.7G   1% /dev/shm
tmpfs           5.0M  4.0K  5.0M   1% /run/lock
efivarfs        256K  149K  103K  60% /sys/firmware/efi/efivars
/dev/nvme0n1p1  256M   99M  158M  39% /boot/efi
tmpfs           758M  116K  758M   1% /run/user/1000
```

> **Note:** Root filesystem (`/dev/nvme0n1p6`) is at 64% of 96GB - healthy but worth monitoring. NVMe drive confirms this is an SSD-based laptop. `/boot/efi` at 39% is fine. No volumes near full that could block SSH log writes.

---

### `du -sh /var/log`

Command Output:

```
434M     /var/log
```

> **Note:** Log directory is 434MB - getting large. Approaching the 500MB mark where log rotation should be reviewed. Run `sudo journalctl --vacuum-size=100M` to clean old journal logs if needed.

---

### `vmstat 1 3`

Command Output:

```
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd     free   buff    cache   si   so   bi   bo   in   cs  us sy  id wa st
 1  0      0  2645784 119456  3210204    0    0   76   43  116  189   1  0  98  0  0
 0  0      0  2635828 119456  3217504    0    0    0    0  370  515   0  0 100  0  0
 0  0      0  2635576 119456  3217276    0    0    0    0  370  556   0  0 100  0  0
```

> **Note:** CPU idle at ~100%, swap completely unused (swpd=0, si/so=0). ~2.6GB free memory available. Small block I/O on first sample (bi=76) is just background disk activity - settles to 0 immediately. System is quiet, SSH is not causing any load.

---

## 5. Snapshot: Network

### `ss -tulpn | grep ssh`

Command Output:

```
tcp   LISTEN 0      128    0.0.0.0:22   0.0.0.0:*   users:(("sshd",pid=800,fd=3))
tcp   LISTEN 0      128       [::]:22      [::]:*   users:(("sshd",pid=800,fd=4))
```

> **Note:** `sshd` is correctly listening on port 22, both IPv4 and IPv6. PID matches what we found earlier. No unexpected ports open.

---

### `ping -c 3 localhost`

Command Output:

```
PING localhost (127.0.0.1) 56(84) bytes of data.
64 bytes from localhost (127.0.0.1): icmp_seq=1 ttl=64 time=0.219 ms
64 bytes from localhost (127.0.0.1): icmp_seq=2 ttl=64 time=0.082 ms
64 bytes from localhost (127.0.0.1): icmp_seq=3 ttl=64 time=0.084 ms
--- localhost ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2074ms
rtt min/avg/max/mdev = 0.082/0.128/0.219/0.064 ms
```

> **Note:** Localhost is reachable with <1ms latency. 0% packet loss. Average response time is 0.128ms - network stack is perfectly healthy. SSH can reach local interfaces without issues.

---

## 6. Logs Reviewed

### `journalctl -u ssh -n 50`

Command Output:

```
May 04 23:04:42 nandan-Victus systemd[1]: Failed to start OpenBSD Secure Shell server.
May 04 23:04:43 nandan-Victus sshd[15135]: /etc/ssh/sshd_config line 14: no argument after keyword "Port22"
May 04 23:04:43 nandan-Victus sshd[15135]: /etc/ssh/sshd_config: terminating, 1 bad configuration options
May 04 23:04:43 nandan-Victus systemd[1]: ssh.service: Failed with result 'exit-code'.
May 04 23:04:43 nandan-Victus systemd[1]: ssh.service: Start request repeated too quickly.
May 04 23:07:18 nandan-Victus systemd[1]: Started OpenBSD Secure Shell server.
May 04 23:07:18 nandan-Victus sshd[15197]: Server listening on 0.0.0.0 port 22.
May 04 23:07:50 nandan-Victus sshd[15223]: Accepted password for nandan from 127.0.0.1 port 33658 ssh2
May 04 23:07:50 nandan-Victus sshd[15223]: pam_unix(sshd:session): session opened for user nandan(uid=1000) by (uid=0)
May 07 22:55:22 nandan-Victus sshd[800]: Server listening on 0.0.0.0 port 22.
May 07 22:55:22 nandan-Victus systemd[1]: Started OpenBSD Secure Shell server.
May 07 23:41:44 nandan-Victus sshd[6016]: error: kex_exchange_identification: client sent invalid protocol identifier "HEAD / HTTP/1.1"
May 07 23:41:44 nandan-Victus sshd[6016]: banner exchange: Connection from 127.0.0.1 port 35002: invalid format
```

> **Note:** ⚠️ Two interesting findings: (1) On May 04, SSH crashed 5 times due to a config typo - `Port22` instead of `Port 22` in `/etc/ssh/sshd_config` line 14. Fixed and restarted successfully at 23:07. (2) On May 07, an HTTP client accidentally hit SSH port 22 - `curl -I localhost:22` from our own drill caused the "invalid protocol" error. Not a real attack. Current boot shows SSH running cleanly with PID 800.

---

### `tail -n 50 /var/log/auth.log`

Command Output:

```
May  7 22:55:22 nandan-Victus sshd[800]: Server listening on 0.0.0.0 port 22.
May  7 22:55:22 nandan-Victus sshd[800]: Server listening on :: port 22.
May  7 22:56:36 nandan-Victus gdm-password]: pam_unix(gdm-password:session): session opened for user nandan(uid=1000) by (uid=0)
May  7 22:56:36 nandan-Victus systemd-logind[709]: New session 2 of user nandan.
May  7 23:17:01 nandan-Victus CRON[5599]: pam_unix(cron:session): session opened for user root(uid=0) by (uid=0)
May  7 23:17:02 nandan-Victus CRON[5599]: pam_unix(cron:session): session closed for user root
May  7 23:31:13 nandan-Victus sudo:   nandan : TTY=pts/0 ; PWD=/home/nandan ; USER=root ; COMMAND=/usr/bin/du -sh /var/log
May  7 23:39:25 nandan-Victus sudo:   nandan : TTY=pts/0 ; PWD=/home/nandan ; USER=root ; COMMAND=/usr/bin/ss -tulpn
May  7 23:41:44 nandan-Victus sshd[6016]: error: kex_exchange_identification: client sent invalid protocol identifier "HEAD / HTTP/1.1"
May  7 23:41:51 nandan-Victus sshd[6020]: error: kex_exchange_identification: client sent invalid protocol identifier "HEAD / HTTP/1.1"
```

> **Note:** ✅ No brute-force attempts or unauthorized logins found. Auth log shows normal activity - user `nandan` logged in via GDM (desktop), cron jobs running as root on schedule, and sudo commands from this drill session are all visible. The `kex_exchange_identification` errors are self-inflicted from running `curl -I localhost:22` during this drill - not a real threat.

---

## 7. Quick Findings

| Check | Status | Observation |
|---|---|---|
| CPU Usage | ✅ Normal | 0.0% - daemon idle, PID 800 |
| Memory | ✅ Normal | 0.1% - no pressure, 2.6GB free |
| Disk | ⚠️ Monitor | 64% root used, logs at 434MB - near threshold |
| Port Binding | ✅ Normal | Listening on :22 (IPv4 + IPv6) |
| Auth Logs | ✅ Clean | No brute-force or unauthorized attempts found |
| Swap | ✅ Normal | swpd=0 - swap completely unused |

---

## 8. If This Worsens — Next Steps

**1. Block brute-force IPs with `fail2ban`**

```bash
sudo apt install fail2ban -y
sudo systemctl enable --now fail2ban
sudo fail2ban-client status sshd   # verify SSH jail is active
```

> If brute-force attacks increase, check `/etc/fail2ban/jail.local` and tighten `maxretry` and `bantime`.


**2. Increase SSH log verbosity**

Edit `/etc/ssh/sshd_config`:

```
LogLevel VERBOSE
```

Then: `sudo systemctl restart sshd`

> This captures more detail about key exchange failures, which helps diagnose intermittent auth issues.


**3. Collect connection-level traces with `strace`**

```bash
sudo strace -p $(pgrep -o sshd) -e trace=network,read,write -o /tmp/sshd-trace.txt
```

> Use only during active incident. Trace captures exactly what sshd is reading/writing at the syscall level - critical when logs alone don't explain dropped connections.

---
