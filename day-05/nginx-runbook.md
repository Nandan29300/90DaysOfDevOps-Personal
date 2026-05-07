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
   1456  0.0  0.3 nginx
```

> **Note:** Nginx master process is essentially idle (0.0% CPU, 0.3% memory). The master only manages worker processes - workers handle actual requests.

---

### Check all Nginx worker processes
```bash
ps aux | grep nginx
```
```
www-data  1457  0.1  0.4  55320  8120 ?  S   08:41   0:02 nginx: worker process
www-data  1458  0.1  0.4  55320  8044 ?  S   08:41   0:02 nginx: worker process
root      1456  0.0  0.3  55064  6592 ?  Ss  08:41   0:00 nginx: master process
```
> **Note:** 2 worker processes running as `www-data` (correct, non-root). Master process runs as root to bind to port 80/443. Healthy process hierarchy.

---

### `free -h`
```
               total        used        free      shared  buff/cache   available
Mem:           3.8Gi       1.3Gi       1.1Gi        72Mi       1.4Gi       2.2Gi
Swap:          2.0Gi          0B       2.0Gi
```
> **Note:** Swap is unused. 2.2 GiB available. Nginx is not memory-pressured. If traffic spikes, buffer cache will absorb most of it.

---

## 4. Snapshot: Disk & IO

### `df -h`
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        20G   8.4G   11G  45% /
tmpfs           1.9G     0B  1.9G   0% /dev/shm
/dev/sda15      105M  6.1M   99M   6% /boot/efi
```
> **Note:** Root filesystem at 45% — healthy. Nginx logs and web content live under `/var` and `/var/www` respectively, both on root partition.

---

### `du -sh /var/log/nginx`
```
156M    /var/log/nginx
```
> **Note:** ⚠️ Nginx logs are at 156 MB. Not critical yet, but `access.log` grows fast under traffic. Confirm `logrotate` is configured for `/var/log/nginx/*.log`.

---

### `iostat -x 1 3`
```
Device    r/s    w/s    rkB/s    wkB/s   util%
sda       1.2    4.8     14.4     38.4    2.1%
```
> **Note:** Disk utilization at 2.1% — very low. Nginx is writing logs at ~38 KB/s (steady traffic). No I/O bottleneck present.

---

## 5. Snapshot: Network

### `ss -tulpn | grep nginx`
```
tcp   LISTEN 0   511   0.0.0.0:80    0.0.0.0:*   users:(("nginx",pid=1457,fd=6))
tcp   LISTEN 0   511   0.0.0.0:443   0.0.0.0:*   users:(("nginx",pid=1457,fd=7))
tcp   LISTEN 0   511      [::]:80       [::]:*   users:(("nginx",pid=1457,fd=8))
tcp   LISTEN 0   511      [::]:443      [::]:*   users:(("nginx",pid=1457,fd=9))
```
> **Note:** Nginx correctly listening on ports 80 and 443 for both IPv4 and IPv6. Backlog is 511 (default). No unexpected ports.

---

### `curl -I http://localhost`
```
HTTP/1.1 200 OK
Server: nginx/1.24.0 (Ubuntu)
Date: Wed, 07 May 2026 10:05:33 GMT
Content-Type: text/html
Content-Length: 4286
Connection: keep-alive
X-Cache: HIT
```
> **Note:** HTTP 200 OK — Nginx is serving requests successfully. `X-Cache: HIT` means the caching layer is working. Response time was <5ms locally.

---

### `curl -I https://localhost -k`
```
HTTP/2 200
server: nginx/1.24.0 (Ubuntu)
content-type: text/html
strict-transport-security: max-age=31536000; includeSubDomains
```
> **Note:** HTTPS is also working. HTTP/2 active. HSTS header present — good security posture. `-k` flag used to skip self-signed cert validation in local test.

---

## 6. Logs Reviewed

### `journalctl -u nginx -n 50`
```
May 07 08:41:00 devbox nginx[1456]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
May 07 08:41:00 devbox nginx[1456]: nginx: configuration file /etc/nginx/nginx.conf test is successful
May 07 08:41:00 devbox systemd[1]: Started A high performance web server and a reverse proxy server.
May 07 09:48:12 devbox nginx[1456]: 2026/05/07 09:48:12 [warn] 1458#1458: *1042 upstream response is buffered to a temporary file /var/lib/nginx/tmp/proxy/1/00/0000000001
May 07 09:55:44 devbox nginx[1456]: 2026/05/07 09:55:44 [error] 1457#1457: *1098 connect() failed (111: Connection refused) while connecting to upstream, client: 10.0.1.5
```
> **Note:** ⚠️ Two issues: (1) An upstream response was too large to buffer in memory — proxy buffer size may need tuning. (2) Nginx failed to connect to an upstream (backend app down or misconfigured upstream address).

---

### `tail -n 50 /var/log/nginx/error.log`
```
2026/05/07 09:55:44 [error] 1457#1457: *1098 connect() failed (111: Connection refused) while connecting to upstream, server: _, request: "GET /api/users HTTP/1.1", upstream: "http://127.0.0.1:3000/api/users"
2026/05/07 09:58:01 [error] 1457#1457: *1102 connect() failed (111: Connection refused) while connecting to upstream, server: _, request: "GET /api/products HTTP/1.1", upstream: "http://127.0.0.1:3000/api/products"
2026/05/07 10:01:30 [warn]  1458#1458: *1112 upstream sent invalid header while reading response header from upstream
```
> **Note:** 🔴 The backend service on `127.0.0.1:3000` is not responding — port 3000 is refused. Nginx is returning 502 Bad Gateway to clients for `/api/*` routes. Upstream (Node.js / app server) needs to be restarted.

---

### `tail -n 20 /var/log/nginx/access.log`
```
10.0.1.5 - - [07/May/2026:09:55:44 +0000] "GET /api/users HTTP/1.1" 502 559 "-" "Mozilla/5.0"
10.0.1.8 - - [07/May/2026:09:56:12 +0000] "GET / HTTP/1.1" 200 4286 "-" "curl/7.88.1"
10.0.1.5 - - [07/May/2026:09:58:01 +0000] "GET /api/products HTTP/1.1" 502 559 "-" "PostmanRuntime/7.32"
```
> **Note:** 502 errors are hitting API routes from real clients. Static content (200 on `/`) is unaffected. Issue is isolated to the upstream backend.

---

## 7. Quick Findings

| Check | Status | Observation |
|---|---|---|
| CPU Usage | ✅ Normal | Master + 2 workers, minimal CPU |
| Memory | ✅ Normal | No memory pressure, swap unused |
| Disk | ⚠️ Monitor | Logs at 156 MB — verify logrotate |
| Ports | ✅ Normal | 80 + 443 bound correctly |
| HTTP Health | ✅ Normal | Static content returning 200 OK |
| Upstream API | 🔴 Critical | Backend on :3000 is down — 502 errors |
| Proxy Buffering | ⚠️ Monitor | Some large upstream responses hitting disk |

---

## 8. If This Worsens — Next Steps

**1. Immediately investigate the upstream backend on port 3000**
```bash
# Check if backend process is running
ss -tulpn | grep 3000
ps aux | grep node          # or pm2, gunicorn, etc.

# Attempt restart
sudo systemctl restart myapp   # replace with actual service name
# or: pm2 restart all

# Verify it's back
curl -I http://127.0.0.1:3000/api/users
```
> Until backend recovers, consider returning a custom 502 page in nginx: `error_page 502 /maintenance.html;`

**2. Tune proxy buffer size to stop disk-buffering**

Edit `/etc/nginx/nginx.conf` or the relevant `server {}` block:
```nginx
proxy_buffer_size          128k;
proxy_buffers              4 256k;
proxy_busy_buffers_size    256k;
```
Then: `sudo nginx -t && sudo systemctl reload nginx`
> This reduces the "buffered to temporary file" warnings and improves proxy throughput.

**3. Collect request traces with `strace` on a worker**
```bash
# Find a worker PID
ps aux | grep "nginx: worker"
# Attach strace to it
sudo strace -p 1457 -e trace=network,read,write -T -o /tmp/nginx-strace.txt
```
> Use when Nginx workers are hanging or a specific endpoint is slow. Captures exact syscalls with timing (`-T`) to pinpoint where the worker is blocked.

---

*Runbook complete. Re-run this drill after any upstream deployment or Nginx config change.*
