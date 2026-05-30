# Day 13 - Linux Volume Management (LVM)

## 📌 Task Overview

**Goal:** Learn LVM to manage storage flexibly - create, extend, and mount volumes using real EBS disks attached to EC2.

**📺 Reference:** [Linux LVM Tutorial](https://youtu.be/Evnf2AAt7FQ?si=ncnfQYySYtK_2K3c)

---

## 🔧 Before You Start

### Step 1: Create EBS Volumes in AWS Console

1. Go to **AWS Console → EC2 → Elastic Block Store → Volumes**
2. Click **Create Volume** and create 3 volumes:
   - Volume 1: **10 GiB**
   - Volume 2: **12 GiB**
   - Volume 3: **14 GiB**
3. Make sure all 3 are in the **same Availability Zone** as your EC2 instance
4. **Attach all 3 volumes** to your running EC2 instance

### Step 2: Switch to Root User

```bash
sudo -i
# or
sudo su
```

### Step 3: Verify Disks Are Attached

```bash
lsblk
```

You should see your 3 new disks:

```
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda       8:0    0    8G  0 disk
└─sda1    8:1    0    8G  0 part /
sdb       8:16   0   10G  0 disk
sdc       8:32   0   12G  0 disk
sdd       8:48   0   14G  0 disk
```

> 📸 _[Screenshot: lsblk showing sdb, sdc, sdd attached]_

---

## 📋 Key Concepts

| Term | Description |
|------|-------------|
| **LVM** | Logical Volume Manager - flexible disk management in Linux |
| **Physical Volume (PV)** | Raw EBS disk added to LVM via `pvcreate` |
| **Volume Group (VG)** | A storage pool made by combining multiple PVs |
| **Logical Volume (LV)** | A virtual partition carved from a VG - this is what you format and mount |

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
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda       8:0    0    8G  0 disk
└─sda1    8:1    0    8G  0 part /
sdb       8:16   0   10G  0 disk
sdc       8:32   0   12G  0 disk
sdd       8:48   0   14G  0 disk

# pvs, vgs, lvs → No output (LVM not yet configured)
```

> 📸 _[Screenshot: lsblk and df -h output]_

---

### Task 2: Create Physical Volumes (PV)

Create a Physical Volume on **all 3 EBS disks**:

```bash
pvcreate /dev/sdb /dev/sdc /dev/sdd
pvs
```

**Sample Output:**

```
Physical volume "/dev/sdb" successfully created.
Physical volume "/dev/sdc" successfully created.
Physical volume "/dev/sdd" successfully created.

PV         VG   Fmt  Attr PSize   PFree
/dev/sdb        lvm2 ---  10.00g  10.00g
/dev/sdc        lvm2 ---  12.00g  12.00g
/dev/sdd        lvm2 ---  14.00g  14.00g
```

> 📸 _[Screenshot: pvcreate and pvs output]_

---

### Task 3: Create Volume Group (VG)

Combine all 3 PVs into one Volume Group called `devops-vg`:

```bash
vgcreate devops-vg /dev/sdb /dev/sdc /dev/sdd
vgs
```

**Sample Output:**

```
Volume group "devops-vg" successfully created

VG        #PV #LV #SN Attr   VSize   VFree
devops-vg   3   0   0 wz--n- 35.99g  35.99g
```

> All 3 disks (10G + 12G + 14G = ~36G) are now **pooled into one group!**

> 📸 _[Screenshot: vgcreate and vgs output]_

---

### Task 4: Create Logical Volume (LV)

Carve out a 500M Logical Volume called `app-data` from `devops-vg`:

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
| `lsblk` | List all block devices (disks) |
| `pvcreate /dev/sdb /dev/sdc /dev/sdd` | Create Physical Volumes on all 3 disks |
| `pvs` | View Physical Volumes |
| `vgcreate devops-vg /dev/sdb /dev/sdc /dev/sdd` | Create Volume Group from all 3 PVs |
| `vgs` | View Volume Groups |
| `lvcreate -L 500M -n app-data devops-vg` | Create a 500M Logical Volume |
| `lvs` | View Logical Volumes |
| `mkfs.ext4` | Format LV with ext4 filesystem |
| `mount` | Mount the LV to a directory |
| `lvextend -L +200M` | Extend the LV by 200M |
| `resize2fs` | Resize filesystem after extending |
| `df -h` | Check mounted filesystem usage |

---

## 🧠 What I Learned

1. **LVM lets you combine multiple disks into one pool** - I attached 3 separate EBS volumes (10G + 12G + 14G) and merged them into a single 36G Volume Group. This is something traditional partitioning simply cannot do.

2. **The PV → VG → LV layered architecture gives real flexibility** - Instead of being stuck with fixed partition sizes, LVM lets you allocate storage dynamically from the pool as your application needs grow.

3. **Extending volumes online is safe and easy** - Using `lvextend` + `resize2fs`, I grew a mounted filesystem from 500M to 700M with zero downtime. This is extremely useful in production DevOps environments where you can't afford to stop services.

---

## 📁 Submission

```bash
git add 2026/day-13/day-13-lvm.md
git commit -m "Day 13 - Linux LVM task completed with EBS volumes"
git push
```

---

## 🌐 Learn in Public

Share your progress on LinkedIn!

```
Completed Day 13 of #90DaysOfDevOps - Linux LVM! 💾
Attached 3 EBS volumes (10G+12G+14G) to EC2, created PVs, pooled them
into a Volume Group, carved out Logical Volumes, and extended storage
online without any downtime!

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
```

---

*Happy Learning! 🚀 — TrainWithShubham*
