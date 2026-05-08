# 🐳 Docker Daemon – Linux Troubleshooting Runbook

**Date:** 08-05-2026

**Target Service:** `docker` (Docker Engine Daemon)


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

### `cat /etc/os-release`

Command Output:

```
PRETTY_NAME="Ubuntu 22.04.5 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04.5 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
```

> **Note:** Ubuntu 22.04.5 LTS (Jammy Jellyfish) - latest point release of 22.04. Docker CE is officially supported and well-tested on this release.

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

> **Note:** `/tmp` is writable, filesystem is healthy. File copy succeeded without errors - no disk I/O issues at this stage.

---

## 3. Snapshot: CPU & Memory

### Find Docker daemon PID and inspect it

```bash
:~$ pgrep dockerd
:~$ ps -o pid,pcpu,pmem,comm -p 1287
```

Command Output:

```
    PID %CPU %MEM COMMAND
    1238  0.0  0.9 dockerd
```

> **Note:** Docker daemon PID is 1238, completely idle at 0.0% CPU and 0.9% memory. Lower than expected - no containers are currently running. Daemon is just sitting in background waiting for commands.

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

### `docker stats --no-stream`

Command Output:

```
CONTAINER ID   NAME      CPU %     MEM USAGE / LIMIT   MEM %     NET I/O   BLOCK I/O   PIDS

```

> **Note:** ✅ No containers currently running - output shows empty table with only headers. Docker daemon is healthy but idle. This is expected on a local learning environment with no active deployments.

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

### `docker system df`

Command Output:

```
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          18        6         2.816GB   1.497GB (53%)
Containers      8         0         11.57kB   11.57kB (100%)
Local Volumes   4         4         301.6MB   0B (0%)
Build Cache     42        0         53.38kB   53.38kB
```

> **Note:** ⚠️ 18 images total, only 6 active - 1.497GB (53%) of images are reclaimable. All 8 containers are stopped (0 active) - 100% of container disk is reclaimable. 4 volumes all in use so none can be pruned. Build cache is tiny at 53KB - already clean. Run `docker image prune -a` during off-hours to recover ~1.5GB.

---

### `du -sh /var/log`

Command Output:

```
451M     /var/log
```

> **Note:** Log directory is 451MB - getting large. Approaching the 500MB mark where log rotation should be reviewed. Run `sudo journalctl --vacuum-size=100M` to clean old journal logs if needed.


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

### `ls -la /var/run/docker.sock` or ss -tulpn | grep docker`

Command Output:

```
srw-rw---- 1 root docker 0 May  8 12:36 /var/run/docker.sock
```

> **Note:** ✅ Docker is using a Unix socket instead of TCP port - this is the **secure default**. No network port exposed at all. Only users in the `docker` group can access the socket locally. Much safer than exposing port 2375 over TCP.

---

### `docker version --format json | python3 -m json.tool`

Command Output:

```json
{
    "Client": {
        "Version": "28.2.2",
        "ApiVersion": "1.50",
        "Os": "linux",
        "Arch": "amd64",
        "Context": "default"
    },
    "Server": {
        "Version": "28.2.2",
        "ApiVersion": "1.50",
        "KernelVersion": "6.8.0-100-generic",
        "Os": "linux",
        "Arch": "amd64"
    }
}
```

> **Note:** ✅ Docker Engine v28.2.2 with API v1.50 - very recent version. Client and Server versions match perfectly. Running on kernel 6.8.0 (HWE). containerd v1.7.28 and runc v1.3.3 are also up to date. Daemon is fully responsive.

---

## 6. Logs Reviewed

### `journalctl -u docker -n 50`

Command Output:

```
May 08 12:37:00 nandan-Victus dockerd[1238]: level=info msg="Starting up"
May 08 12:37:00 nandan-Victus dockerd[1238]: level=info msg="[graphdriver] using prior storage driver: overlay2"
May 08 12:37:00 nandan-Victus dockerd[1238]: level=warning msg="error locating sandbox id 8a21d448...": sandbox not found
May 08 12:37:00 nandan-Victus dockerd[1238]: level=warning msg="error locating sandbox id 082916ab...": sandbox not found
May 08 12:37:00 nandan-Victus dockerd[1238]: level=warning msg="CDI setup error /etc/cdi: failed to monitor for changes: no such file or directory"
May 08 12:37:00 nandan-Victus dockerd[1238]: level=info msg="Daemon has completed initialization"
May 08 12:37:00 nandan-Victus dockerd[1238]: level=info msg="API listen on /run/docker.sock"
May 08 12:37:00 nandan-Victus systemd[1]: Started Docker Application Container Engine.
```

> **Note:** ⚠️ Two warnings on startup: (1) Multiple "error locating sandbox" warnings - these are leftover network sandbox references from previously stopped containers. Not critical, clears itself. (2) CDI setup error for `/etc/cdi` - CDI (Container Device Interface) directory missing, only matters if using GPU/special devices. Daemon completed initialization successfully and is listening on Unix socket.

---

### `sudo grep -i docker /var/log/syslog | tail -20`

Command Output:

```
May  8 12:37:00 nandan-Victus avahi-daemon[678]: Registering new address record for 172.17.0.1 on docker0.IPv4.
May  8 12:37:00 nandan-Victus NetworkManager[684]: device (docker0): state change: disconnected -> activated
May  8 12:37:00 nandan-Victus dockerd[1238]: level=warning msg="error locating sandbox id 8a21d448...: sandbox not found"
May  8 12:37:00 nandan-Victus dockerd[1238]: level=warning msg="error locating sandbox id 082916ab...: sandbox not found"
May  8 12:37:00 nandan-Victus dockerd[1238]: level=warning msg="CDI setup error /etc/cdi: no such file or directory"
May  8 12:37:00 nandan-Victus dockerd[1238]: level=info msg="Docker daemon" storage-driver=overlay2 version=28.2.2
May  8 12:37:00 nandan-Victus dockerd[1238]: level=info msg="Daemon has completed initialization"
May  8 12:37:00 nandan-Victus systemd[1]: Started Docker Application Container Engine.
```

> **Note:** ⚠️ Syslog corroborates journal findings. Docker bridge network `docker0` assigned IP `172.17.0.1` - normal default network. Sandbox warnings are leftover references from old stopped containers - not critical. CDI warnings are expected since no GPU devices are configured. Daemon started successfully.

---

## 7. Quick Findings

| Check | Status | Observation |
|---|---|---|
| CPU Usage | ✅ Normal | 0.0% daemon overhead - idle, no containers running |
| Memory | ✅ Normal | 0.9% memory usage, swap unused |
| Disk | ⚠️ Monitor | 1.497GB reclaimable images, 8 stopped containers |
| Docker API Port | ✅ Secure | Unix socket only - port 2375 not exposed |
| Container Health | ⚠️ Monitor | 0 active containers, 8 stopped - cleanup needed |
| Logs | ⚠️ Monitor | Sandbox warnings on startup - stale network references from old containers |

---

## 8. If This Worsens - Next Steps

**1. Disable unauthenticated Docker API immediately**

Edit `/lib/systemd/system/docker.service`:

```
# Remove: -H tcp://0.0.0.0:2375
# Replace with TLS-secured: -H tcp://0.0.0.0:2376 --tlsverify
```

Then:

```bash
:~$ sudo systemctl daemon-reload && sudo systemctl restart docker
```

> Until TLS is configured, block port 2375 with: `sudo ufw deny 2375`


**2. Reclaim disk space before root filesystem hits 80%**

```bash
:~$ docker system prune -af --volumes   # CAUTION: removes stopped containers + unused volumes
:~$ docker image prune -a               # safer: only remove unused images
```

> Schedule this monthly via cron. Alert at 75% disk usage with a monitoring tool.


**3. Trace misbehaving container with `docker inspect` + `strace`**

```bash
:~$ docker inspect web-app              # check restart count, exit codes
:~$ docker logs --tail 100 web-app      # last 100 lines of container stdout/stderr
:~$ sudo strace -p $(docker inspect --format '{{.State.Pid}}' web-app) -f -e trace=network
```

> If `RestartCount` in `docker inspect` is high (>3), the container is crash-looping. Check its entrypoint and env vars.

---
