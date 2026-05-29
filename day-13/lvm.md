# Day 13 - Linux Volume Management (LVM)

## 📌 Task Overview

**Goal:** Learn LVM to manage storage flexibly - create, extend, and mount volumes.

**📺 Reference:** [Linux LVM Tutorial](https://youtu.be/Evnf2AAt7FQ?si=ncnfQYySYtK_2K3c)

---

## 🔧 Before You Start

Switch to root user:

```bash
sudo -i
# or
sudo su
```

No spare disk? Create a virtual one using a loopback device:

```bash
dd if=/dev/zero of=/tmp/disk1.img bs=1M count=1024
losetup -fP /tmp/disk1.img
losetup -a   # Note the device name (e.g., /dev/loop0)
```

---

## 📋 Key Concepts

| Term | Description |
|------|-------------|
| **LVM** | Logical Volume Manager - a tool for flexible disk space management in Linux |
| **Physical Volume (PV)** | Raw disk or loop device added to LVM via `pvcreate` |
| **Volume Group (VG)** | A storage pool made from one or more PVs via `vgcreate` |
| **Logical Volume (LV)** | A virtual partition carved from a VG via `lvcreate` |

---

## ✅ Challenge Tasks

### Task 1: Check Current Storage

```bash
lsblk
pvs
vgs
lvs
df -h
```

**Sample Output:**

```
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda           8:0    0   20G  0 disk
├─sda1        8:1    0   20G  0 part /
loop0         7:0    0    1G  0 loop

# pvs, vgs, lvs → No output (LVM not yet configured)
```

> 📸 _[Screenshot: lsblk and df -h output]_

---

### Task 2: Create Physical Volume

```bash
pvcreate /dev/loop0   # Use your actual loop device
pvs
```

**Sample Output:**

```
Physical volume "/dev/loop0" successfully created.

PV         VG   Fmt  Attr PSize   PFree
/dev/loop0      lvm2 ---  1.00g  1.00g
```

> 📸 _[Screenshot: pvcreate and pvs output]_

---

### Task 3: Create Volume Group

```bash
vgcreate devops-vg /dev/loop0
vgs
```

**Sample Output:**

```
Volume group "devops-vg" successfully created

VG        #PV #LV #SN Attr   VSize  VFree
devops-vg   1   0   0 wz--n- 1.00g 1.00g
```

> 📸 _[Screenshot: vgcreate and vgs output]_

---

### Task 4: Create Logical Volume

```bash
lvcreate -L 500M -n app-data devops-vg
lvs
```

**Sample Output:**

```
Logical volume "app-data" created.

LV       VG        Attr       LSize   Pool Origin Data%  Meta%
app-data devops-vg -wi-a----- 500.00m
```

> 📸 _[Screenshot: lvcreate and lvs output]_

---

### Task 5: Format and Mount

```bash
mkfs.ext4 /dev/devops-vg/app-data
mkdir -p /mnt/app-data
mount /dev/devops-vg/app-data /mnt/app-data
df -h /mnt/app-data
```

**Sample Output:**

```
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 512000 1k blocks and 128016 inodes
...

Filesystem                        Size  Used Avail Use% Mounted on
/dev/mapper/devops--vg-app--data  488M  1.6M  452M   1% /mnt/app-data
```

> 📸 _[Screenshot: mkfs and df -h /mnt/app-data output]_

---

### Task 6: Extend the Volume

```bash
lvextend -L +200M /dev/devops-vg/app-data
resize2fs /dev/devops-vg/app-data
df -h /mnt/app-data
```

**Sample Output:**

```
Size of logical volume devops-vg/app-data changed from 500.00 MiB to 700.00 MiB.
Logical volume devops-vg/app-data successfully resized.

resize2fs 1.45.5 (07-Jan-2020)
The filesystem on /dev/devops-vg/app-data is now 716800 (1k) blocks long.

Filesystem                        Size  Used Avail Use% Mounted on
/dev/mapper/devops--vg-app--data  683M  2.1M  647M   1% /mnt/app-data
```

> 📸 _[Screenshot: lvextend, resize2fs, and final df -h output]_

---

## 💡 Commands Summary

| Command | Purpose |
|---------|---------|
| `lsblk` | List block devices |
| `pvs` / `pvcreate` | View / Create Physical Volume |
| `vgs` / `vgcreate` | View / Create Volume Group |
| `lvs` / `lvcreate` | View / Create Logical Volume |
| `mkfs.ext4` | Format LV with ext4 filesystem |
| `mount` | Mount the LV to a directory |
| `lvextend` | Extend the size of an LV |
| `resize2fs` | Resize the filesystem after extending |
| `df -h` | Check mounted filesystem usage |

---

## 🧠 What I Learned

1. **LVM provides flexible storage management** - Unlike fixed partitions, LVM allows you to grow, shrink, or move storage on the fly without downtime, which is critical in production DevOps environments.

2. **The PV → VG → LV layered architecture is powerful** - By abstracting physical disks into volume groups and then into logical volumes, LVM lets you pool multiple disks and allocate storage dynamically as application needs change.

3. **You can safely extend volumes without data loss** - Using `lvextend` + `resize2fs`, I was able to grow a mounted filesystem from 500M to 700M while it remained online. However, shrinking volumes requires caution and a backup first.

---
