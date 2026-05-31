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
# Output (relevant section):
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP>
#     inet 192.168.1.10/24 brd 192.168.1.255 scope global eth0
```

**Observation:**
- `hostname -I` gives a quick flat list of all IPs assigned to the machine.
- `ip addr show` shows the full interface info including subnet mask (`/24` = 255.255.255.0) and broadcast address.
- This machine is on a private `192.168.x.x` network (RFC 1918), meaning it's behind NAT.

---

### 2. Reachability - Ping

```bash
ping -c 4 google.com
# Output:
# PING google.com (142.250.183.78) 56(84) bytes of data.
# 64 bytes from bom12s14-in-f14.1e100.net (142.250.183.78): icmp_seq=1 ttl=118 time=9.34 ms
# 64 bytes from bom12s14-in-f14.1e100.net (142.250.183.78): icmp_seq=2 ttl=118 time=9.71 ms
# 64 bytes from bom12s14-in-f14.1e100.net (142.250.183.78): icmp_seq=3 ttl=118 time=9.58 ms
# 64 bytes from bom12s14-in-f14.1e100.net (142.250.183.78): icmp_seq=4 ttl=118 time=9.12 ms
#
# --- google.com ping statistics ---
# 4 packets transmitted, 4 received, 0% packet loss, time 3004ms
# rtt min/avg/max/mdev = 9.12/9.43/9.71/0.23 ms
```

**Observation:**
- 0% packet loss - the host is reachable and the path is clean.
- Average latency ~9.4 ms - typical for a nearby Google datacenter (likely Mumbai/Bengaluru PoP from India).
- `ttl=118` means the packet crossed about 10 hops (TTL starts at 128 for Windows targets, each hop decrements by 1).
- `ping` uses **ICMP** (L3 - Internet layer). It tests raw IP reachability, not TCP/application health.

---

### 3. Path - Traceroute

```bash
traceroute google.com
# Output:
# traceroute to google.com (142.250.183.78), 30 hops max, 60 byte packets
#  1  _gateway (192.168.1.1)        0.812 ms   0.753 ms   0.741 ms
#  2  10.0.0.1 (10.0.0.1)           3.241 ms   3.198 ms   3.162 ms
#  3  103.21.244.1                   5.812 ms   5.774 ms   5.736 ms
#  4  * * *                          (timeout - firewall blocking ICMP)
#  5  74.125.242.193                 7.234 ms   7.112 ms   7.098 ms
#  6  108.170.253.113                8.641 ms   8.598 ms   8.562 ms
#  7  142.250.183.78                 9.412 ms   9.374 ms   9.336 ms
#
# 7 hops to google.com
```

**Observation:**
- Hop 1 (`192.168.1.1`) is my default gateway - local router, sub-1 ms.
- Hop 4 shows `* * *` (timeout) - this is normal; many ISP or transit routers drop ICMP TTL-exceeded messages for security. It doesn't mean the path is broken.
- Total path is only 7 hops - pretty lean routing. Traffic hits a Google edge node quickly.
- Latency grows gradually, which is healthy. A sudden spike at one hop would flag a congested link.

---

### 4. Ports - Listening Services

```bash
ss -tulpn
# Output:
# Netid  State   Recv-Q  Send-Q  Local Address:Port   Peer Address:Port  Process
# tcp    LISTEN  0       128     0.0.0.0:22           0.0.0.0:*          users:(("sshd",pid=845,fd=3))
# tcp    LISTEN  0       128     127.0.0.1:631        0.0.0.0:*          users:(("cupsd",pid=923,fd=7))
# tcp    LISTEN  0       80      0.0.0.0:3306         0.0.0.0:*          users:(("mysqld",pid=1102,fd=21))
# udp    UNCONN  0       0       0.0.0.0:68           0.0.0.0:*          users:(("dhclient",pid=312,fd=6))
# udp    UNCONN  0       0       127.0.0.53:53        0.0.0.0:*          users:(("systemd-r",pid=289,fd=14))
```

**Observation:**
- `sshd` on port **22** - SSH daemon, listening on all interfaces (`0.0.0.0`). Remote login is enabled.
- `cupsd` on port **631** - CUPS printing service, only on localhost (`127.0.0.1`), not externally reachable.
- `mysqld` on port **3306** - MySQL database, listening on all interfaces. In production, this should be restricted to localhost unless remote DB access is intentional.
- `systemd-resolved` on port **53** (UDP, localhost) - local DNS resolver.
- `-tulpn` flags: `-t` TCP, `-u` UDP, `-l` listening only, `-p` show process, `-n` no DNS resolution (show raw IPs/ports).

---

### 5. Name Resolution - DNS Check

```bash
dig google.com
# Output:
# ; <<>> DiG 9.18.1-1ubuntu1 <<>> google.com
# ;; ANSWER SECTION:
# google.com.     143     IN      A       142.250.183.78
#
# ;; Query time: 4 msec
# ;; SERVER: 127.0.0.53#53 (127.0.0.53)
# ;; WHEN: Sun May 31 10:22:41 IST 2026

# Or quick shorthand:
dig +short google.com
# Output:
# 142.250.183.78
```

```bash
nslookup google.com
# Output:
# Server:   127.0.0.53
# Address:  127.0.0.53#53
#
# Non-authoritative answer:
# Name:  google.com
# Address: 142.250.183.78
```

**Observation:**
- `google.com` resolves to `142.250.183.78` - a Google anycast IP.
- Query time is **4 ms** - DNS resolution itself is very fast.
- The resolver is `127.0.0.53` - this is `systemd-resolved`, the local stub resolver. It forwards to upstream DNS (typically your ISP's or 8.8.8.8).
- `TTL: 143` seconds - this record will be cached for ~2.4 minutes. Short TTL means Google can rotate IPs quickly (useful for load balancing and failover).

---

### 6. HTTP Check - Status Code

```bash
curl -I https://google.com
# Output:
# HTTP/2 301
# location: https://www.google.com/
# content-type: text/html; charset=UTF-8
# server: gws
# x-xss-protection: 0
# x-frame-options: SAMEORIGIN

curl -I https://www.google.com
# Output:
# HTTP/2 200
# content-type: text/html; charset=ISO-8859-1
# server: gws
# x-xss-protection: 0
# x-frame-options: SAMEORIGIN
# cache-control: private, max-age=0
```

**Observation:**
- `google.com` returns **HTTP 301** (Moved Permanently) → redirects to `www.google.com`. This is standard canonical URL enforcement.
- `www.google.com` returns **HTTP 200 OK** - site is up and serving.
- `server: gws` = Google Web Server.
- `-I` sends a HEAD request (only headers, no body) - fast way to check if a URL is alive without downloading the full page.

---

### 7. Connections Snapshot

```bash
netstat -an | head -20
# Output:
# Active Internet connections (servers and established)
# Proto Recv-Q Send-Q Local Address         Foreign Address        State
# tcp        0      0 0.0.0.0:22            0.0.0.0:*              LISTEN
# tcp        0      0 127.0.0.1:631         0.0.0.0:*              LISTEN
# tcp        0      0 0.0.0.0:3306          0.0.0.0:*              LISTEN
# tcp        0      0 192.168.1.10:22       192.168.1.5:54821      ESTABLISHED
# tcp        0      0 192.168.1.10:56432    142.250.183.78:443     ESTABLISHED
# tcp6       0      0 :::22                 :::*                   LISTEN
# udp        0      0 0.0.0.0:68            0.0.0.0:*
# udp        0      0 127.0.0.53:53         0.0.0.0:*
```

**Observation:**
- **LISTEN** entries: 3 TCP services waiting for incoming connections (SSH, CUPS, MySQL) + IPv6 SSH.
- **ESTABLISHED** entries: 2 active connections - one incoming SSH session (someone is connected to this machine), one outgoing HTTPS connection to Google.
- `Recv-Q` and `Send-Q` both 0 - no backlog, system is healthy. Non-zero values here can indicate a slow/overloaded service.

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
# * Connected to localhost (127.0.0.1) port 22 (#0)
# SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.6
```

### Step 3: Interpretation

**Result: Port 22 is reachable. SSH service is up and responding with its banner (`SSH-2.0-OpenSSH_8.9p1`).**

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

## 🚀 Learn in Public

Practiced the core networking toolkit today - `ping`, `traceroute`, `dig`, `ss`, `curl -I`, and `nc`. Found that `traceroute google.com` showed a `* * *` at hop 4 (ISP router dropping ICMP probes), but the path only took 7 hops total to reach Google. Running `curl -I https://google.com` returned a 301 redirect before finally hitting 200 on `www.google.com` - a nice reminder that even simple URLs can have redirect chains you don't see in the browser.

`#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham`
