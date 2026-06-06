# Day 15 – Networking Concepts: DNS, IP, Subnets & Ports

---

## Task 1: DNS – How Names Become IPs

### What happens when you type `google.com` in a browser?

When you type `google.com`, your browser first checks its local DNS cache to see if it already knows the IP. If not, it asks the OS, which then queries a DNS resolver (usually your ISP's or a configured one like 8.8.8.8). The resolver works its way through the DNS hierarchy - root servers → TLD servers → authoritative nameservers - and finally returns the IP address. Your browser then uses that IP to send the actual HTTP request to Google's server.

### DNS Record Types

| Record | What it does |
|--------|--------------|
| **A** | Maps a domain name to an IPv4 address |
| **AAAA** | Maps a domain name to an IPv6 address |
| **CNAME** | Alias - points one domain to another domain instead of an IP |
| **MX** | Specifies which mail exchange servers handle email for the domain |
| **NS** | Nameserver - Tells the world which DNS server is authoritative for the domain |

### `dig google.com` - Output

```bash
$ dig google.com

; <<>> DiG 9.18.1 <<>> google.com
;; ANSWER SECTION:
google.com.     247     IN      A       142.250.183.78
```

- **A record:** `142.250.183.78` - this is the IPv4 address Google's domain resolves to
- **TTL:** `247` seconds - after this, the resolver will re-fetch the record instead of using cached data

---

## Task 2: IP Addressing

### What is an IPv4 address?

An IPv4 address is a 32-bit number used to identify a device on a network. It's written as four decimal numbers (0–255) separated by dots - for example, `192.168.1.10`. Each group is called an **octet** (8 bits), and together they make up the full address that tells traffic where to go.

### Public vs Private IPs

| Type | Description | Example |
|------|-------------|---------|
| **Public IP** | Routable over the internet; assigned by ISP | `8.8.8.8` (Google DNS) |
| **Private IP** | Used only inside local/internal networks; not internet-routable | `192.168.1.23` (home/LAN) |

### Private IP Ranges

```
10.0.0.0    – 10.255.255.255      (10.x.x.x) - Huge - 16 million IPs - Large companies, AWS VPCs, data centers
172.16.0.0  – 172.31.255.255      (172.16.x.x – 172.31.x.x) - Medium - 1 million IPs - Medium networks
192.168.0.0 – 192.168.255.255     (192.168.x.x) - Small - 65k IPs - Home routers, small offices
```

```
The important thing is the contract: no ISP will ever route these on the public internet. So 10.0.0.1 in your office and 10.0.0.1 in my office are completely separate — they never collide because they never leave their own networks.
```

```
every computer has a DNS server configured; by default it's usually your ISP's DNS (Jio, Airtel, BSNL — whoever gives you internet). 8.8.8.8 is just Google's option that you can manually switch to if you want.
```

### `ip addr show` - Output

```bash
$ ip addr show

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP>
    inet 172.31.45.12/20 brd 172.31.47.255 scope global eth0

1: lo: <LOOPBACK,UP,LOWER_UP>
    inet 127.0.0.1/8 scope host lo
```

- `172.31.45.12` → falls in the `172.16.x.x – 172.31.x.x` range → **private IP** (AWS EC2 internal)
- `127.0.0.1` → loopback address (localhost), not routable at all

---

## Task 3: CIDR & Subnetting

- CIDR (Classless Inter-Domain Routing): Compact way to show IP range & subnet size


### What does `/24` mean in `192.168.1.0/24`?

The `/24` is the **prefix length** - it means the first 24 bits of the address are the **network** portion, and the remaining 8 bits are available for **hosts**. In terms of subnet mask, `/24` = `255.255.255.0`. So `192.168.1.0/24` covers all addresses from `192.168.1.0` to `192.168.1.255`.

### Usable Hosts

- **/24** → 256 total − 2 (network + broadcast) = **254 usable hosts**
- **/16** → 65,536 total − 2 = **65,534 usable hosts**
- **/28** → 16 total − 2 = **14 usable hosts**

### Why do we subnet?

Instead of dumping every device into one giant network (which gets chaotic and insecure), subnetting lets you carve the network into smaller, manageable chunks. Each subnet is its own isolated segment - so a breach in one doesn't automatically expose others, broadcast traffic is reduced, and you can apply different security rules per segment. Basically: better organization, better security, less noise.

### CIDR Table

| CIDR | Subnet Mask | Total IPs | Usable Hosts |
|------|-------------|-----------|--------------|
| /24  | 255.255.255.0   | 256    | 254   |
| /16  | 255.255.0.0     | 65,536 | 65,534 |
| /28  | 255.255.255.240 | 16     | 14    |

---

## Task 4: Ports – The Doors to Services

### What is a port? Why do we need them?

A port is a logical number (0–65535) attached to a network connection that tells the OS which application should receive incoming data. Without ports, if two services (say, SSH and a web server) ran on the same machine, the OS would have no way to know which traffic goes where. Ports solve that - SSH listens on 22, HTTP on 80, and they can all share the same IP without stepping on each other.

### Common Ports

| Port  | Service |
|-------|---------|
| 22    | SSH - secure remote login |
| 80    | HTTP - unencrypted web traffic |
| 443   | HTTPS - encrypted web traffic |
| 53    | DNS - domain name resolution |
| 3306  | MySQL - relational database |
| 6379  | Redis - in-memory cache/store |
| 27017 | MongoDB - NoSQL document database |

### `ss -tulpn` - Output

```bash
$ ss -tulpn

Netid  State   Local Address:Port   Peer Address:Port   Process
tcp    LISTEN  0.0.0.0:22          0.0.0.0:*           users:(("sshd",pid=592,fd=3))
tcp    LISTEN  0.0.0.0:80          0.0.0.0:*           users:(("nginx",pid=700,fd=6))
```

- Port `22` → **sshd** running → SSH is active and accepting connections
- Port `80` → **nginx** running → web server is live and serving HTTP

---

## Task 5: Putting It Together

### You run `curl http://myapp.com:8080` - what networking concepts are involved?

First, **DNS** kicks in to resolve `myapp.com` into an IP address. Then a **TCP connection** is established to that IP on **port 8080** - port being the key detail here since it's non-standard (not the default 80). The OS uses the IP (from **IP addressing**) and the port together to route the request to the right service on the right machine. If the server is behind a subnet, **routing** rules determine how packets actually get there.

### Your app can't reach a database at `10.0.1.50:3306` - what do you check first?

1. **Basic connectivity** - `ping 10.0.1.50` to see if the host is reachable at all. If ping fails, it's a routing or firewall issue, not the database.
2. **Port availability** - `ss -tulpn` on the DB server to confirm MySQL is actually listening on 3306. Dead service = no connection.
3. **Firewall/Security Group rules** - check if port 3306 is blocked between the two machines (especially on AWS where Security Groups control this per-instance).

---

## What I Learned

1. **DNS is a multi-step lookup chain** - your browser doesn't magically know IPs; it goes through cache → resolver → authoritative servers, and TTL controls how long that answer is trusted before re-fetching.

2. **IP addressing has structure and intent** - public IPs are internet-facing, private IPs stay internal, and CIDR notation is how you define the boundary between "network" and "host" bits. Subnetting is essentially network segmentation with math.

3. **Ports are what make multi-service machines possible** - one IP, many services, all separated by port numbers. Knowing the common ones (22, 80, 443, 3306) is instant debugging power when something can't connect.

---

*Day 15 of #90DaysOfDevOps | #DevOpsKaJosh | #TrainWithShubham*
