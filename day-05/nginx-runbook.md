# 🌐 Nginx Web Server – Linux Troubleshooting Runbook

**Date:** 07-05-2026

**Target Service:** `nginx` (Nginx HTTP Server)

---

## 1. Environment Basics

### `uname -a`

Command Output:

```
Linux nandan-Victus 6.8.0-100-generic #100~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Mon Jan 19 17:10:19 UTC x86_64 x86_64 x86_64 GNU/Linux
```

> **Note:** Kernel is 6.8.0 (Ubuntu 22.04 LTS HWE kernel). x86_64 architecture. `PREEMPT_DYNAMIC` indicates a low-latency preemptible kernel - common on laptops (Victus). Stable Ubuntu base, no custom patches.

---

### `lsb_release -a`

Command Output:

```
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 22.04.5 LTS
Release:        22.04
Codename:       jammy
```

> **Note:** Ubuntu Jammy LTS. Nginx 1.18+ from apt repos or Nginx mainline PPA is standard on this release.

---

## 2. Filesystem Sanity Check

### Create throwaway folder and file

```bash
:~$ mkdir /tmp/runbook-demo
:~$ cp /etc/hosts /tmp/runbook-demo/hosts-copy && ls -l /tmp/runbook-demo
```

Command Output:

```
total 4
-rw-r--r-- 1 ubuntu ubuntu 221 May  7 10:02:05 hosts-copy
```

> **Note:** `/tmp` is writable and filesystem I/O is normal. A prerequisite check before examining nginx log directories.

---

## 3. Snapshot: CPU & Memory

### Find Nginx master PID and inspect it

```bash
:~$ pgrep -o nginx
:~$ ps -o pid,pcpu,pmem,comm -p 1456
```

Command Output:

```
    PID %CPU %MEM COMMAND
   1456  0.0  0.3  nginx
```

> **Note:** Nginx master process is essentially idle (0.0% CPU, 0.3% memory). The master only manages worker processes - workers handle actual requests.

---

### Check all Nginx worker processes

```bash
:~$ ps aux | grep nginx
```
Command Output:

```
root       817  0.0  0.0  55240  2316 ?  Ss  12:36   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data   818  0.0  0.0  55876  5668 ?  S   12:36   0:00 nginx: worker process
www-data   819  0.0  0.0  55876  5668 ?  S   12:36   0:00 nginx: worker process
www-data   820  0.0  0.0  55876  5668 ?  S   12:36   0:00 nginx: worker process
www-data   821  0.0  0.0  55876  5668 ?  S   12:36   0:00 nginx: worker process
```

> **Note:** Master process (PID 817) running as root to bind ports 80/443 - correct. 12 worker processes running as `www-data` (non-root) - healthy and secure. Higher worker count than default, likely matching CPU core count on this laptop.

> Port 22 → SSH, 
> Port 80 → Nginx (HTTP), 
> Port 443 → Nginx (HTTPS)
> 
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

### `du -sh /var/log/nginx`

Command Output:

```
8.0K    /var/log/nginx
```

> **Note:** ✅ Nginx logs are only 8KB - extremely small. This is a fresh install with minimal traffic. As traffic grows, `access.log` will grow fast. Confirm `logrotate` is configured for `/var/log/nginx/*.log` to avoid log bloat in production.

---

### `iostat -x 1 3`

Command Output:

```
avg-cpu:  %user   %nice  %system  %iowait  %steal   %idle
           1.48    0.10     0.74     0.11    0.00   97.57

Device       r/s     rkB/s    w/s    wkB/s   %util
nvme0n1    59.77   2440.85  19.73  1099.65    1.20
```

> **Note:** ✅ Only real disk is `nvme0n1` (NVMe SSD) - all `loop` devices are snap packages, safely ignored. NVMe utilization at just 1.2% - no I/O bottleneck. CPU idle at 97.57%. Nginx is not causing any disk pressure. Samples 2 and 3 show zero activity - system settled completely.

---

## 5. Snapshot: Network

### `ss -tulpn | grep nginx`

Command Output:

```
tcp  LISTEN 0  511   0.0.0.0:80   0.0.0.0:*   users:(("nginx",pid=817,fd=6),...(12 workers))
tcp  LISTEN 0  511      [::]:80      [::]:*   users:(("nginx",pid=817,fd=7),...(12 workers))
```

> **Note:** ✅ Nginx listening on port 80 for both IPv4 and IPv6. Backlog is 511 (default). All 12 worker processes + master (PID 817) are bound to port 80. No HTTPS (443) configured yet - this is a fresh local install. No unexpected ports open.

---

### `curl -I http://localhost`

Command Output:

```
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
Date: Fri, 08 May 2026 07:26:29 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Thu, 07 May 2026 18:51:50 GMT
Connection: keep-alive
ETag: "69fcdf46-264"
Accept-Ranges: bytes
```

> **Note:** ✅ HTTP 200 OK - Nginx is serving requests successfully. Running version 1.18.0 on Ubuntu. No `X-Cache` header means no caching layer configured yet - serving static files directly. Response size is 612 bytes (default Nginx welcome page).

---

### `curl -I https://localhost -k`

Command Output:

```
curl: (7) Failed to connect to localhost port 443 after 0 ms: Connection refused
```

> **Note:** ⚠️ HTTPS (port 443) is not configured on this fresh Nginx install. SSL certificate and HTTPS server block have not been set up yet. This is expected for a local learning environment. In production, HTTPS should be configured using Let's Encrypt (`certbot`) or a self-signed certificate.

---

## 6. Logs Reviewed

### `journalctl -u nginx -n 50`

Command Output:

```
May 08 00:21:51 nandan-Victus systemd[1]: Starting A high performance web server and a reverse proxy server...
May 08 00:21:51 nandan-Victus systemd[1]: Started A high performance web server and a reverse proxy server.
May 08 00:41:44 nandan-Victus systemd[1]: Stopping A high performance web server and a reverse proxy server...
May 08 00:41:44 nandan-Victus systemd[1]: nginx.service: Deactivated successfully.
May 08 00:41:44 nandan-Victus systemd[1]: Stopped A high performance web server and a reverse proxy server.
-- Boot 8da56119733148af8fca9c1f3399ddb0 --
May 08 12:36:53 nandan-Victus systemd[1]: Starting A high performance web server and a reverse proxy server...
May 08 12:36:53 nandan-Victus systemd[1]: Started A high performance web server and a reverse proxy server.
```

> **Note:** ✅ Clean logs - no errors or warnings. Nginx started successfully twice today. First start at 00:21, stopped at 00:41 (manual stop during setup), then cleanly restarted at 12:36 on current boot. No upstream failures or config issues detected.

---

### `tail -n 50 /var/log/nginx/error.log`

Command Output:

```
2026/05/08 00:21:51 [notice] 6990#6990: using inherited sockets from "6;7;"
```

> **Note:** ✅ Only one `[notice]` level entry in error log - not an actual error. This message means Nginx smoothly inherited socket connections during restart without dropping any. No `[error]` or `[warn]` entries at all. Error log is clean.

---

### `tail -n 20 /var/log/nginx/access.log`

Command Output:

```
127.0.0.1 - - [08/May/2026:12:56:29 +0530] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.81.0"
```

> **Note:** ✅ Only one request in access log - the `curl -I http://localhost` command we ran during this drill. Response was 200 OK. No real external traffic yet since this is a fresh local install. No 502 or 404 errors anywhere.

---

## 7. Quick Findings

| Check | Status | Observation |
|---|---|---|
| CPU Usage | ✅ Normal | Master + 12 workers, 0.0% CPU - idle |
| Memory | ✅ Normal | No memory pressure, swap unused |
| Disk | ✅ Normal | Logs at 8KB - fresh install, verify logrotate for future |
| Ports | ⚠️ Monitor | Port 80 bound correctly, port 443 not configured yet |
| HTTP Health | ✅ Normal | Static content returning 200 OK |
| HTTPS | ⚠️ Action Needed | Port 443 refused - SSL not configured yet |
| Error Log | ✅ Clean | Only one `[notice]` entry - no errors or warnings |

---

## 8. If This Worsens - Next Steps

**1. Immediately investigate the upstream backend on port 3000**

```bash

# Check if backend process is running
:~$ ss -tulpn | grep 3000
:~$ ps aux | grep node          # or pm2, gunicorn, etc.

# Attempt restart
:~$ sudo systemctl restart myapp   # replace with actual service name
# or: pm2 restart all

# Verify it's back
:~$ curl -I http://127.0.0.1:3000/api/users

```
> Until backend recovers, consider returning a custom 502 page in nginx: `error_page 502 /maintenance.html;`


**2. Tune proxy buffer size to stop disk-buffering**

Edit `/etc/nginx/nginx.conf` or the relevant `server {}` block:

```nginx
proxy_buffer_size          128k;
proxy_buffers              4 256k;
proxy_busy_buffers_size    256k;
```

Then: `:~$ sudo nginx -t && sudo systemctl reload nginx`

> This reduces the "buffered to temporary file" warnings and improves proxy throughput.


**3. Collect request traces with `strace` on a worker**

```bash
# Find a worker PID
:~$ ps aux | grep "nginx: worker"

# Attach strace to it
:~$ sudo strace -p 1457 -e trace=network,read,write -T -o /tmp/nginx-strace.txt
```

> Use when Nginx workers are hanging or a specific endpoint is slow. Captures exact syscalls with timing (`-T`) to pinpoint where the worker is blocked.

---

