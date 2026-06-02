# Day 14 - Networking Fundamentals & Hands-on Checks

---

## 📚 Quick Concepts

### OSI Model (L1-L7) vs TCP/IP Stack

| OSI Layer | Name | TCP/IP Layer | Examples |
|-----------|------|--------------|---------|
| L7 | Application | Application | HTTP, HTTPS, DNS, SSH, FTP |
| L6 | Presentation | Application | SSL/TLS, encoding, compression, encryption/decryption |
| L5 | Session | Application | Session management |
| L4 | Transport | Transport | TCP, UDP (ports live here) |
| L3 | Network | Internet | IP, ICMP, routing |
| L2 | Data Link | Network Access | Ethernet, MAC addresses, ARP(Address Resolution Protocol) |
| L1 | Physical | Network Access | Cables, NICs, Wi-Fi signals |

- **OSI** is the theoretical 7-layer model used to *reason about* where things break. Each layer has a clear responsibility.
- **TCP/IP** is the practical 4-layer model the internet actually runs on - it collapses the top 3 OSI layers into one "Application" layer.
- **ARP** converts IP address → MAC address, also IP is logical, MAC is physical - ARP bridges the two

---

### Where Protocols Sit in the Stack

| Protocol | Layer (OSI) | Layer (TCP/IP) | Purpose |
|----------|-------------|----------------|---------|
| IP | L3 - Network | Internet | Addressing & routing packets across networks |
| TCP | L4 - Transport | Transport | Reliable, ordered delivery (connection-oriented) |
| UDP | L4 - Transport | Transport | Fast, connectionless delivery (no guarantees) |
| DNS | L7 - Application | Application | Resolves domain names → IP addresses |
| HTTP | L7 - Application | Application | Web traffic (plain text) |
| HTTPS | L7 - Application | Application | HTTP - L7 (Application) encrypted over TLS (L6 (Encryption) / L5 (Session) in OSI terms) |

---

### Real-World Example

```
curl https://example.com
```

Breaking it down layer by layer:

```
Application Layer  →  curl sends an HTTP GET request
                       DNS resolves "example.com" → 93.184.216.34
Transport Layer    →  TCP 3-way handshake on port 443
                       TLS handshake for HTTPS encryption
Internet Layer     →  IP packets routed from your machine to 93.184.216.34
Link Layer         →  Ethernet/Wi-Fi frames carry packets on local network
```

> One command = 4 layers working together, every single time you hit a URL.

---

## 🖥️ Hands-on Checklist & Command Outputs

> **Target host for all checks:** `google.com`

---

### 1. Identity - Your IP Address

```bash
hostname -I
# Output:
# 192.168.1.10

# Or with more detail:
ip addr show
2: enX0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc fq_codel state UP group default qlen 1000
    link/ether 0a:ff:fb:22:25:dd brd ff:ff:ff:ff:ff:ff
    inet 172.31.19.100/20 metric 100 brd 172.31.31.255 scope global dynamic enX0
```

**Observation:**
- `hostname -I` gives a quick flat list of all IPs assigned to the machine.
- `ip addr show` shows the full interface info including subnet mask (`/20` = 4096 IPs) and broadcast address.
- This is an AWS EC2 instance - interface enX0, private IP `172.31.19.100` on a VPC subnet (RFC 1918), behind NAT. mtu 9001 = jumbo frames enabled by AWS.

---

### 2. Reachability - Ping

```bash
ping -c 4 google.com
# Output:
# PING google.com (142.251.16.102) 56(84) bytes of data.
# 64 bytes from bl-in-f102.1e100.net (142.251.16.102): icmp_seq=1 ttl=106 time=1.73 ms
# 64 bytes from bl-in-f102.1e100.net (142.251.16.102): icmp_seq=2 ttl=106 time=1.64 ms
# 64 bytes from bl-in-f102.1e100.net (142.251.16.102): icmp_seq=3 ttl=106 time=1.72 ms
# 64 bytes from bl-in-f102.1e100.net (142.251.16.102): icmp_seq=4 ttl=106 time=1.67 ms
#
# --- google.com ping statistics ---
# 4 packets transmitted, 4 received, 0% packet loss, time 3005ms
# rtt min/avg/max/mdev = 1.639/1.688/1.725/0.037 ms
```

**Observation:**
- 0% packet loss - host is fully reachable and path is clean.
- Average latency **~1.68 ms** - very low because this EC2 instance is in the same AWS region as Google's edge node (`bl-in-f102` = likely Mumbai PoP).
- `ttl=106` means ~22 hops consumed (TTL starts at 128, decrements each hop).
- `ping` uses **ICMP** (L3 – Internet layer). Tests raw IP reachability, not TCP/application health.

---

### 3. Path - Traceroute

```bash
traceroute google.com
# Output:
# traceroute to google.com (142.251.167.100), 30 hops max, 60 byte packets
#  1  240.64.220.131 (240.64.220.131)  0.964 ms 240.64.220.128 (240.64.220.128)  0.724 ms  0.747 ms
#  2  99.82.14.78 (99.82.14.78)        1.199 ms 99.82.14.178 (99.82.14.178)      1.179 ms  1.776 ms
#  3  * 99.82.14.77 (99.82.14.77)      1.458 ms 99.82.14.79 (99.82.14.79)        1.443 ms
#  4  192.178.240.207                   1.423 ms 192.178.97.147                   0.882 ms  2.034 ms
#  5  192.178.242.24                    2.186 ms 192.178.242.26                   2.253 ms  2.064 ms
#  6  216.239.63.235                    2.428 ms 142.251.49.187                   2.186 ms  1.503 ms
#  7  142.251.236.105                   2.485 ms 142.250.215.189                  2.375 ms  3.748 ms
#  8  172.253.67.20                     2.438 ms 142.250.209.96                   1.273 ms  2.112 ms
#  9  216.239.62.193                    1.593 ms 216.239.63.195                   2.085 ms  2.666 ms
# 10  * * *
# ...
# 19  ww-in-f100.1e100.net (142.251.167.100)  1.752 ms
```

**Observation:**
- Hop 1 (`240.64.220.x`) is the **AWS internal gateway** - sub-1 ms, expected.
- Hops 2–3 (`99.82.x.x`) are **AWS backbone** network - traffic stays inside AWS infrastructure initially.
- From hop 4 onwards (`192.178.x.x`, `216.239.x.x`) - already inside **Google's own network**. AWS and Google have direct peering, so traffic jumps to Google very fast.
- Hops 10–18 show `* * *` - Google's internal routers drop ICMP probes (normal, not a problem).
- Final hop 19 reaches `142.251.167.100` with **1.75 ms** - extremely fast, entire path is only ~2ms average.
- Total 19 hops but latency stays flat throughout - clean, well-peered path.

---

### 4. Ports - Listening Services

```bash
ss -tulpn
# Output:
# Netid  State   Recv-Q  Send-Q   Local Address:Port      Peer Address:Port
# udp    UNCONN  0       0        127.0.0.54:53           0.0.0.0:*
# udp    UNCONN  0       0        127.0.0.53%lo:53        0.0.0.0:*
# udp    UNCONN  0       0        172.31.19.100%enX0:68   0.0.0.0:*
# udp    UNCONN  0       0        127.0.0.1:323           0.0.0.0:*
# tcp    LISTEN  0       4096     127.0.0.54:53           0.0.0.0:*
# tcp    LISTEN  0       4096     127.0.0.53%lo:53        0.0.0.0:*
# tcp    LISTEN  0       511      0.0.0.0:80              0.0.0.0:*
# tcp    LISTEN  0       4096     0.0.0.0:22              0.0.0.0:*
# tcp    LISTEN  0       511      [::]:80                 [::]:*
# tcp    LISTEN  0       4096     [::]:22                 [::]:*
```

**Observation:**
- **Port 22 (SSH)** - listening on all interfaces (`0.0.0.0` + `[::]` IPv6). Remote login is enabled.
- **Port 80 (HTTP)** - a web server is running and exposed on all interfaces, both IPv4 and IPv6.
- **Port 53 (DNS)** - `systemd-resolved` running as local DNS stub resolver (localhost only, `127.0.0.53` and `127.0.0.54`).
- **Port 68 (UDP/DHCP)** - DHCP client on `enX0`, how this EC2 instance gets its IP from AWS automatically.
- **Port 323 (UDP)** - `chronyd` NTP time sync service, localhost only.
- `-tulpn` flags: `-t` TCP, `-u` UDP, `-l` listening only, `-p` show process, `-n` no DNS resolution (show raw IPs/ports).


---

### 5. Name Resolution - DNS Check

```bash
dig google.com
# Output:
# ; <<>> DiG 9.20.18-1ubuntu2.1-Ubuntu <<>> google.com
# ;; ANSWER SECTION:
# google.com.   178   IN   A   142.251.167.101
# google.com.   178   IN   A   142.251.167.102
# google.com.   178   IN   A   142.251.167.113
# google.com.   178   IN   A   142.251.167.138
# google.com.   178   IN   A   142.251.167.139
# google.com.   178   IN   A   142.251.167.100
#
# ;; Query time: 0 msec
# ;; SERVER: 127.0.0.53#53 (127.0.0.53) (UDP)
# ;; WHEN: Tue Jun 02 15:49:25 UTC 2026
```

**Observation:**
- `google.com` returns **6 A records** - Google uses multiple IPs for load balancing and redundancy.
- Query time is **0 ms** - response was served from local DNS cache instantly.
- Resolver is `127.0.0.53` - `systemd-resolved` stub resolver.
- `TTL: 178` seconds - record expires in ~3 minutes, after which a fresh lookup hits upstream DNS.
- All IPs are in `142.251.167.x` range - Google anycast addresses, likely same Mumbai PoP seen in traceroute.


```
# Or quick shorthand:
dig +short google.com
# Output:
# 142.251.167.113
# 142.251.167.139
# 142.251.167.101
# 142.251.167.100
# 142.251.167.138
# 142.251.167.102
```

```bash
nslookup google.com
# Output:
# Server:		127.0.0.53
# Address:	127.0.0.53#53
#
# Non-authoritative answer:
# Name:	google.com
# Address: 142.251.167.102
# Name:	google.com
# Address: 142.251.167.113
# Name:	google.com
# Address: 142.251.167.100
# Name:	google.com
# Address: 142.251.167.139
# Name:	google.com
# Address: 142.251.167.138
# Name:	google.com
# Address: 142.251.167.101
# Name:	google.com
# Address: 2607:f8b0:4004:c17::71
# Name:	google.com
# Address: 2607:f8b0:4004:c17::8a
# Name:	google.com
# Address: 2607:f8b0:4004:c17::65
# Name:	google.com
# Address: 2607:f8b0:4004:c17::66
```

**Observation:**
- `google.com` resolves to **6 IPv4 + 4 IPv6 addresses** - Google serves both A and AAAA records, fully dual-stack.
- The resolver is `127.0.0.53` - `systemd-resolved`, the local stub resolver. It forwards to upstream DNS.
- `TTL: 178` seconds - record cached for ~3 minutes. Short TTL lets Google rotate IPs quickly for load balancing and failover.
- Query time **0 ms** - already cached from earlier `dig` command.
- `2607:f8b0:...` are Google's **IPv6 anycast** addresses - `nslookup` showed these because it queries both A and AAAA by default, unlike `dig google.com` which only queried A records.

---

### 6. HTTP Check - Status Code

```bash
curl -I https://google.com
# Output:
# HTTP/2 301
# location: https://www.google.com/
# content-type: text/html; charset=UTF-8
# content-security-policy-report-only: object-src 'none';base-uri 'self';...
# date: Tue, 02 Jun 2026 16:04:56 GMT
# expires: Thu, 02 Jul 2026 16:04:56 GMT
# cache-control: public, max-age=2592000
# server: gws
# content-length: 220
# x-xss-protection: 0
# x-frame-options: SAMEORIGIN
# alt-svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000
```

**Observation:**
- `google.com` returns **HTTP 301** (Moved Permanently) → redirects to `https://www.google.com/`. Standard canonical URL enforcement.
- `cache-control: max-age=2592000` - this redirect is cached for **30 days** by browsers.
- `server: gws` = Google Web Server.
- `alt-svc: h3=":443"` - server advertises **HTTP/3 (QUIC)** support. Your client can upgrade on next request.
- `-I` sends a HEAD request - headers only, no body. Fast way to check if a URL is alive.

---

```bash
curl -I https://www.google.com
# Output:
# HTTP/2 200
# content-type: text/html; charset=ISO-8859-1
# date: Tue, 02 Jun 2026 16:05:07 GMT
# server: gws
# x-xss-protection: 0
# x-frame-options: SAMEORIGIN
# cache-control: private
# set-cookie: AEC=...; expires=Sun, 29-Nov-2026; Secure; HttpOnly; SameSite=lax
# set-cookie: NID=531=...; expires=Wed, 02-Dec-2026; HttpOnly
# alt-svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000
```

**Observation:**
- `www.google.com` returns **HTTP 200 OK** - site is up and serving.
- `cache-control: private` - response is user-specific, not cacheable by CDN/proxies.
- `set-cookie` - Google sets **AEC** (anti-abuse) and **NID** (preferences) cookies on first visit.
- `alt-svc: h3=":443"` - HTTP/3 (QUIC) advertised here too, consistent with the 301 response.
- `expires` matches `date` exactly - effectively no caching, page fetched fresh every time.
---

### 7. Connections Snapshot

```bash
netstat -an | head -20
# Output:
# Active Internet connections (servers and established)
# Proto Recv-Q Send-Q Local Address               Foreign Address          State
# tcp        0      0 127.0.0.54:53               0.0.0.0:*                LISTEN
# tcp        0      0 127.0.0.53:53               0.0.0.0:*                LISTEN
# tcp        0      0 0.0.0.0:80                  0.0.0.0:*                LISTEN
# tcp        0      0 0.0.0.0:22                  0.0.0.0:*                LISTEN
# tcp        0      0 172.31.19.100:54882         169.254.169.254:80       TIME_WAIT
# tcp        0      0 172.31.19.100:54884         169.254.169.254:80       TIME_WAIT
# tcp        0      0 172.31.19.100:22            152.57.61.231:36134      ESTABLISHED
# tcp        0    396 172.31.19.100:22            152.57.61.231:46080      ESTABLISHED
# tcp        0      0 172.31.19.100:35242         142.251.153.119:443      TIME_WAIT
# tcp        0      0 172.31.19.100:56440         142.251.16.139:443       TIME_WAIT
# tcp6       0      0 :::80                       :::*                     LISTEN
# tcp6       0      0 :::22                       :::*                     LISTEN
# udp        0      0 127.0.0.54:53               0.0.0.0:*
# udp        0      0 172.31.19.100:68            0.0.0.0:*
```

**Observation:**
- **LISTEN**: SSH (22) and HTTP (80) waiting for connections, both IPv4 and IPv6.
- **ESTABLISHED**: 2 active SSH sessions from `152.57.61.231` - that's you connected to this machine. One has `Send-Q=396` meaning 396 bytes queued to send (this very terminal session).
- **TIME_WAIT**: 4 connections closing down - 2 to `169.254.169.254` (AWS metadata service, EC2 internal) and 2 to Google `142.251.x.x:443` (from our earlier `curl` commands).
- `169.254.169.254` is the **AWS EC2 metadata endpoint** - EC2 instances query this for instance info, IAM credentials, etc.

---

## 🔍 Mini Task: Port Probe & Interpret

### Step 1: Identified Listening Port

From `ss -tulpn` output above → **SSH on port 22** (`sshd`, listening on `0.0.0.0:22`)

### Step 2: Test Connectivity to the Port

```bash
nc -zv localhost 22
# Output:
# Connection to localhost (127.0.0.1) 22 port [tcp/ssh] succeeded!
```

Or via curl:

```bash
curl -v telnet://localhost:22
# Output:
* Host localhost:22 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:22...
* Established connection to localhost (::1 port 22) from ::1 port 34912 
SSH-2.0-OpenSSH_10.2p1 Ubuntu-2ubuntu3.2
```

### Step 3: Interpretation

**Result: Port 22 is reachable. SSH service is up and responding with its banner (`SSH-2.0-OpenSSH_20.2p1`).**

If it were *not* reachable, the next checks would be:
1. **Is the service running?** → `systemctl status sshd`
2. **Is a firewall blocking it?** → `sudo ufw status` or `sudo iptables -L -n | grep 22`
3. **Is something else occupying that port?** → `sudo ss -tulpn | grep :22`

---

## 💡 Reflection

### Which command gives the fastest signal when something is broken?

**`ping`** is my first reflex - it gives an immediate binary answer: is the host alive on the network or not? Zero output or 100% packet loss = network/routing problem. From there:
- If `ping` passes but the app fails → move up to L7 (`curl -I`)
- If `ping` fails but the host is supposedly up → check routing/DNS (`traceroute`, `dig`)

The **"ping → curl" combo** gives you a full L3-to-L7 health check in two commands.

---

### What layer would you inspect if...

**DNS fails?**
→ Start at the **Application layer** (is the DNS config correct? `/etc/resolv.conf`), then drop to **Internet/Transport** (can I reach the DNS server IP at all? `ping 8.8.8.8`). DNS failure is usually misconfigured resolver or a UDP port 53 being blocked by a firewall.

**HTTP 500 appears?**
→ This is purely an **Application layer** issue. The network is fine - the server received your request but crashed processing it. Check:
- Application/web server logs (`journalctl -u nginx`, `tail -f /var/log/app/error.log`)
- Service health (`systemctl status <service>`)
- Recent code deployments or config changes

---

### Two follow-up checks in a real incident

1. **`journalctl -u <service-name> --since "10 minutes ago"`**
   Pulls recent logs for the failing service. Most production incidents leave a clear error trail in logs - "connection refused", "OOM killed", "permission denied".

2. **`ss -tulpn` + `curl -I http://localhost:<port>`**
   Verifies the service is actually listening on its expected port, and that it responds locally. If it works on localhost but not externally, the problem is firewall rules or network routing - not the app itself.

---

## 📋 Command Quick Reference

| Command | What it checks | OSI Layer |
|---------|---------------|-----------|
| `ping` | Host reachability via ICMP | L3 - Network |
| `traceroute` | Hop-by-hop path to host | L3 - Network |
| `dig` / `nslookup` | DNS resolution | L7 - Application |
| `ss -tulpn` | Listening ports & processes | L4 - Transport |
| `curl -I <url>` | HTTP response code | L7 - Application |
| `nc -zv <host> <port>` | TCP port reachability | L4 - Transport |
| `netstat -an` | Active connections snapshot | L4 - Transport |
| `ip addr show` | Local IP configuration | L3 - Network |

---

Practiced the core networking toolkit today - `ping`, `traceroute`, `dig`, `ss`, `curl -I`, and `nc`. 
Found that `traceroute google.com` took 19 hops but latency stayed flat at ~2ms throughout - traffic jumped straight onto Google's own network by hop 4 (`192.178.x.x`). 
Running `curl -I https://google.com` returned a 301 redirect to `www.google.com` which then hit 200 - a reminder that even simple URLs have redirect chains hidden from the browser. 
Also spotted 2 `TIME_WAIT` connections to `169.254.169.254` in `netstat` - the AWS EC2 metadata endpoint quietly running in the background.

---
