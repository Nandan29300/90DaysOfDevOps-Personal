# Day 08 – Cloud Server Setup: Docker, Nginx & Web Deployment

## 📋 Overview

Today's goal was to deploy a real web server on the cloud and practice practical server management skills used in production DevOps environments.

---

## 🎯 What I Did Today

- Launched a cloud instance on **AWS EC2 (Ubuntu 22.04 LTS)**
- Connected to the remote server securely via **SSH**
- Installed and configured **Nginx** web server
- Configured **Security Groups** to allow web traffic on port 80
- Extracted and saved **Nginx logs** to a file
- Verified the webpage is publicly accessible from the internet

---

## Part 1: Launch Cloud Instance & SSH Access

### Step 1: Create Cloud Instance (AWS EC2)

1. Logged into [AWS Console](https://console.aws.amazon.com)
2. Navigated to **EC2 Dashboard → Launch Instance**
3. Selected configuration:
   - **Name:** `my-devops-server`
   - **AMI:** Ubuntu Server 22.04 LTS (Free Tier eligible)
   - **Instance Type:** `t2.micro` (1 vCPU, 1 GB RAM)
   - **Key Pair:** Created `my-devops-key.pem` (RSA, .pem format)
   - **Security Group:** Allowed SSH (port 22), HTTP (port 80)
   - **Storage:** 8 GB (default)
4. Launched the instance and noted the **Public IPv4 Address**

### Step 2: Connect via SSH

Set correct permissions on the key file:

```bash
chmod 400 ~/Downloads/my-devops-key.pem
```

Connected to the remote server:

```bash
ssh -i ~/Downloads/my-devops-key.pem ubuntu@<your-instance-ip>
```

Verified the connection:

```bash
whoami           # Output: ubuntu
cat /etc/os-release   # Confirmed Ubuntu 22.04
curl ifconfig.me      # Confirmed public IP
```

> 📸 **Screenshot:** `ssh-connection.png` - Terminal showing successful SSH login

---

## Part 2: Install Nginx

### Step 1: Update System Packages

```bash
sudo apt update
sudo apt upgrade -y
```

This fetches the latest package lists and applies security patches before installing anything.

### Step 2: Install Nginx

```bash
sudo apt install nginx -y
```

### Step 3: Start & Enable Nginx

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

Enabling Nginx ensures it starts automatically on every server reboot.

### Step 4: Verify Nginx is Running

```bash
sudo systemctl status nginx
```

Expected output shows:

```
Active: active (running) ...
```

Also verified Nginx is listening on port 80:

```bash
sudo netstat -tulpn | grep :80
```

Tested locally on the server:

```bash
curl http://localhost
```

Output confirmed the Nginx welcome HTML page was being served correctly.

---

## Part 3: Security Group Configuration

### Inbound Rules Configured on AWS

| Type  | Protocol | Port | Source    | Description        |
|-------|----------|------|-----------|--------------------|
| SSH   | TCP      | 22   | My IP/32  | Secure SSH access  |
| HTTP  | TCP      | 80   | 0.0.0.0/0 | Public web traffic |

### Test Web Access from Browser

Opened browser and visited:

```
http://<your-instance-ip>
```

✅ The **Nginx Welcome Page** loaded successfully - confirming that:
- Nginx is running and serving traffic
- Security group correctly allows port 80
- The instance is publicly accessible

> 📸 **Screenshot:** `nginx-webpage.png` - Nginx welcome page in browser

---

## Part 4: Extract Nginx Logs

### Step 1: View Nginx Logs on Server

**Access Logs** (every request made to the server):

```bash
sudo tail -20 /var/log/nginx/access.log
```

**Error Logs** (errors and warnings):

```bash
sudo tail -20 /var/log/nginx/error.log
```

**Follow logs in real-time** (useful for live debugging):

```bash
sudo tail -f /var/log/nginx/access.log
```

### Step 2: Generate Traffic for Logs

Visited the following URLs from the browser to create log entries:

```
http://<your-ip>/
http://<your-ip>/test
http://<your-ip>/admin
http://<your-ip>/api/users
```

### Step 3: Save Logs to a File

```bash
sudo bash -c 'echo "=== NGINX ACCESS LOGS (Last 50 lines) ===" > nginx-logs.txt'
sudo bash -c 'tail -50 /var/log/nginx/access.log >> nginx-logs.txt'
sudo bash -c 'echo "" >> nginx-logs.txt'
sudo bash -c 'echo "=== NGINX ERROR LOGS (Last 50 lines) ===" >> nginx-logs.txt'
sudo bash -c 'tail -50 /var/log/nginx/error.log >> nginx-logs.txt'
```

Moved file to home directory and fixed ownership:

```bash
sudo mv nginx-logs.txt ~/
sudo chown $USER:$USER ~/nginx-logs.txt
```

### Step 4: Download Logs to Local Machine

Opened a **new local terminal** and ran:

```bash
# For AWS:
scp -i ~/Downloads/my-devops-key.pem ubuntu@<your-instance-ip>:~/nginx-logs.txt .

# For Utho:
scp root@<your-instance-ip>:~/nginx-logs.txt .
```

✅ Log file successfully downloaded to local machine.

---

## Commands Used

```bash
# Set key permissions
chmod 400 ~/Downloads/my-devops-key.pem

# SSH into server
ssh -i ~/Downloads/my-devops-key.pem ubuntu@<your-instance-ip>

# System update
sudo apt update
sudo apt upgrade -y

# Install Nginx
sudo apt install nginx -y

# Nginx service management
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
sudo systemctl reload nginx

# Verify Nginx
curl http://localhost
sudo netstat -tulpn | grep :80

# View logs
sudo tail -20 /var/log/nginx/access.log
sudo tail -20 /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log

# Save logs to file
sudo bash -c 'echo "=== NGINX ACCESS LOGS ===" > nginx-logs.txt'
sudo bash -c 'tail -50 /var/log/nginx/access.log >> nginx-logs.txt'
sudo bash -c 'echo "=== NGINX ERROR LOGS ===" >> nginx-logs.txt'
sudo bash -c 'tail -50 /var/log/nginx/error.log >> nginx-logs.txt'

# Download logs (on local machine)
scp -i my-devops-key.pem ubuntu@<ip>:~/nginx-logs.txt .
```

---

## Challenges Faced

### Challenge 1: Browser Showed "Connection Timed Out"

**Problem:** After installing Nginx, the welcome page was not accessible from the browser.

**Root Cause:** The AWS Security Group did not have an inbound rule for port 80.

**Solution:** Added an HTTP rule (port 80, source `0.0.0.0/0`) in the EC2 Security Group settings.

**Learning:** Always verify security group rules when deploying web services - the server may be running perfectly but unreachable due to firewall configuration.

---

### Challenge 2: SSH Key Permission Error

**Problem:** Got error: *"Permissions 0644 for 'my-devops-key.pem' are too open."*

**Root Cause:** The `.pem` key file had overly permissive file permissions.

**Solution:** Fixed it with:

```bash
chmod 400 my-devops-key.pem
```

**Learning:** SSH enforces strict permission checks on private key files as a security measure. Keys must be readable only by the owner.

---

## What I Learned

- **Cloud instances** are on-demand virtual servers - you can launch, configure, and terminate them in minutes, which forms the foundation of modern infrastructure.
- **SSH with key-based authentication** is more secure than passwords and is the industry standard for accessing remote Linux servers.
- **Security Groups** are virtual firewalls - only open ports that are genuinely needed (principle of least privilege).
- **Nginx** is not just a web server; it's a reverse proxy and load balancer used by Netflix, Dropbox, and Airbnb - understanding it is essential for deploying real applications.
- **Log analysis** is how engineers debug production issues; access logs show every request and error logs show what went wrong.

---

## Why This Matters for DevOps

| Skill | Real-World Application |
|---|---|
| Cloud provisioning | Launching servers for production deployments |
| SSH & remote access | Daily server management and incident response |
| Nginx configuration | Serving apps, reverse proxying backend services |
| Security groups | Protecting production infrastructure |
| Log management | Debugging, monitoring, and compliance audits |

Production incident response, scalable deployments, and security all rely on exactly these skills practiced today.

---

## Instance Details

| Field | Value |
|---|---|
| Cloud Provider | AWS EC2 |
| Instance Type | t2.micro |
| Operating System | Ubuntu 22.04 LTS |
| Public IP | `<your-instance-ip>` |
| Web Server | Nginx |

---

## 📁 Submission Checklist

- [x] `cloud-deployment.md` - this file
- [x] `nginx-logs.txt` - extracted server logs
- [x] `ssh-connection.png` - screenshot of SSH session
- [x] `nginx-webpage.png` - screenshot of Nginx in browser

---
