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
NAME     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0      7:0    0 28.2M  1 loop /snap/amazon-ssm-agent/13009
loop1      7:1    0   74M  1 loop /snap/core22/2411
loop2      7:2    0 48.4M  1 loop /snap/snapd/26382
loop3      7:3    0 49.3M  1 loop /snap/snapd/26865
xvda     202:0    0    8G  0 disk
├─xvda1  202:1    0  6.9G  0 part /
├─xvda13 202:13   0 1023M  0 part /boot
├─xvda14 202:14   0    4M  0 part
└─xvda15 202:15   0  106M  0 part /boot/efi
xvdf     202:80   0   10G  0 disk
xvdg     202:96   0   12G  0 disk
xvdh     202:112  0   14G  0 disk
```

> 📸 **[Below Screenshot: Before lsblk showing sdf(xvdf), sdg(xvdg), sdh(xvdh) attached]**

> <img width="1270" height="715" alt="1" src="https://github.com/user-attachments/assets/d5fb698d-0950-4b9b-a985-ceabeb19752a" />

---

> 📸 **[Below Screenshot: After lsblk showing sdf(xvdf), sdg(xvdg), sdh(xvdh) attached]**

> <img width="1069" height="364" alt="2" src="https://github.com/user-attachments/assets/ec6905e5-7b0a-4857-b2ac-64546bb4ce48" />

---

## 📋 Key Concepts

| Term | Description |
|------|-------------|
| **LVM** | Logical Volume Manager - flexible disk management in Linux |
| **Physical Volume (PV)** | Raw EBS disk added to LVM via `pvcreate` |
| **Volume Group (VG)** | A storage pool made by combining multiple PVs |
| **Logical Volume (LV)** | A virtual partition carved from a VG - this is what you format and mount |

---

```
Real Disks (EBS)
  xvdf (10G) + xvdg (12G) + xvdh (14G)
       ↓
  Make each disk a PV (Physical Volume)
  = just telling LVM "hey, use these disks"
       ↓
  Combine all PVs into one VG (Volume Group)
  = one big pool of 36G
       ↓
  Cut pieces from VG as LV (Logical Volume)
  = "give me 500M from that pool"
       ↓
  Format & Mount the LV
  = now you can actually use it!
```

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
NAME     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0      7:0    0 28.2M  1 loop /snap/amazon-ssm-agent/13009
loop1      7:1    0   74M  1 loop /snap/core22/2411
loop2      7:2    0 48.4M  1 loop /snap/snapd/26382
loop3      7:3    0 49.3M  1 loop /snap/snapd/26865
xvda     202:0    0    8G  0 disk
├─xvda1  202:1    0  6.9G  0 part /
├─xvda13 202:13   0 1023M  0 part /boot
├─xvda14 202:14   0    4M  0 part
└─xvda15 202:15   0  106M  0 part /boot/efi
xvdf     202:80   0   10G  0 disk
xvdg     202:96   0   12G  0 disk
xvdh     202:112  0   14G  0 disk

# pvs, vgs, lvs → No output (LVM not yet configured)

Filesystem      Size  Used Avail Use% Mounted on
/dev/root       6.7G  2.4G  4.3G  36% /
tmpfs           476M     0  476M   0% /dev/shm
tmpfs           191M  920K  190M   1% /run
tmpfs           476M     0  476M   0% /tmp
/dev/xvda13     989M   95M  827M  11% /boot
/dev/xvda15     105M  6.3M   99M   7% /boot/efi
tmpfs            96M  8.0K   96M   1% /run/user/1000

```

> 📸 **[Below Screenshot: lsblk and df -h output]**

> <img width="1097" height="702" alt="3" src="https://github.com/user-attachments/assets/f062a098-ecc6-417e-83b6-ad845cd82d6f" />

---

### Task 2: Create Physical Volumes (PV)

Create a Physical Volume on **all 3 EBS disks**:

```bash
pvcreate /dev/sdb /dev/sdc /dev/sdd
pvs
```

**Sample Output:**

```
Physical volume "/dev/xvdf" successfully created.
Physical volume "/dev/xvdg" successfully created.
Physical volume "/dev/xvdh" successfully created.

PV         VG Fmt  Attr PSize  PFree
/dev/xvdf     lvm2 ---  10.00g 10.00g
/dev/xvdg     lvm2 ---  12.00g 12.00g
/dev/xvdh     lvm2 ---  14.00g 14.00g
```

> 📸 **[Below Screenshot: pvcreate and pvs output]**

> <img width="1127" height="252" alt="4" src="https://github.com/user-attachments/assets/4675526b-eb67-431a-ac6c-02fe9143d850" />

---

### Task 3: Create Volume Group (VG)

Combine all 3 PVs into one Volume Group called `devops-vg`:

```bash
vgcreate devops-vg /dev/xvdf /dev/xvdg /dev/xvdh
vgs
```

**Sample Output:**

```
Volume group "devops-vg" successfully created

VG        #PV #LV #SN Attr   VSize   VFree
devops-vg   3   0   0 wz--n- <35.99g <35.99g

```

> All 3 disks (10G + 12G + 14G = ~36G) are now **pooled into one group!**

---

### Task 4: Create Logical Volume (LV)

Carve out a 10GB Logical Volume called `app-data` from `devops-vg`:

```bash
lvcreate -L 10G -n app-data devops-vg
lvs
```

**Sample Output:**

```
Logical volume "app-data" created.

LV       VG        Attr       LSize   Pool Origin Data%  Meta% Move Log Cpy%Sync Convert
app-data devops-vg -wi-a----- 10.00g
```

> 📸 **[Below Screenshot: lvcreate and lvs output]**
 
> <img width="1127" height="252" alt="5" src="https://github.com/user-attachments/assets/8f71866c-1324-424f-b554-932859d3e369" />

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
mke2fs 1.47.2 (1-Jan-2025)
Creating filesystem with 2621440 4k blocks and 655360 inodes
Filesystem UUID: 012add3f-fa14-46c0-a35c-534c29101321
Superblock backups stored on blocks:
    32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632
Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

Filesystem                        Size  Used Avail Use% Mounted on
/dev/mapper/devops--vg-app--data  9.8G  2.1M  9.3G   1% /mnt/app-data
```

> 📸 **[Below Screenshot: mkfs and df -h /mnt/app-data output]**

> <img width="1134" height="722" alt="6" src="https://github.com/user-attachments/assets/103902e0-ab91-4887-a28b-befdba5e75c5" />


---

### Task 6: Extend the Volume

```bash
lvextend -L +1G /dev/devops-vg/app-data
resize2fs /dev/devops-vg/app-data
df -h /mnt/app-data
```

**Sample Output:**

```
Size of logical volume devops-vg/app-data changed from 10.00 GiB (2560 extents) to 11.00 GiB (2816 extents).
Logical volume devops-vg/app-data successfully resized.

resize2fs 1.47.2 (1-Jan-2025)
Filesystem at /dev/devops-vg/app-data is mounted on /mnt/app-data; on-line resizing required
old_desc_blocks = 2, new_desc_blocks = 2
The filesystem on /dev/devops-vg/app-data is now 2883584 (4k) blocks long.

Filesystem                        Size  Used Avail Use% Mounted on
/dev/mapper/devops--vg-app--data   11G  2.1M   11G   1% /mnt/app-data
```


> 📸 **[Below Screenshot: lvextend, resize2fs, and final df -h output]**

> <img width="1132" height="803" alt="7" src="https://github.com/user-attachments/assets/0213c6cf-b690-4e32-aa93-4856fa570c7a" />

---

Since **/mnt/app-data** is **mounted** above, it's usable now!
# create a file
```
touch /mnt/app-data/hello.txt
```

# create a folder
```
mkdir /mnt/app-data/myfolder
```

# verify
```
ls /mnt/app-data
```

Think of it like a USB drive - once you plug it in (mount), you can store files in it. When you unplug it (unmount), files stay safe inside the disk! 🎯

---

**We can Unmount also**:
```
umount /mnt/app-data
```

⚠️ Before Unmounting - Check if it's busy:
```
lsof /mnt/app-data
```

If any process is using it, unmount will fail. Make sure you're not inside that directory when unmounting!

# Wrong - you're inside the mounted dir
cd /mnt/app-data
umount /mnt/app-data   # ❌ will fail - device busy

# Correct - go out first
cd ~
umount /mnt/app-data   # ✅ works

---

## 💡 Commands Summary

| Command | Purpose |
|---------|---------|
| `lsblk` | List all block devices (disks) |
| `pvcreate /dev/xvdf /dev/xvdg /dev/xvdh` | Create Physical Volumes on all 3 disks |
| `pvs` | View Physical Volumes |
| `vgcreate devops-vg /dev/xvdf /dev/xvdg /dev/xvdh` | Create Volume Group from all 3 PVs |
| `vgs` | View Volume Groups |
| `lvcreate -L 10G -n app-data devops-vg` | Create a 10G Logical Volume |
| `lvs` | View Logical Volumes |
| `mkfs.ext4` | Format LV with ext4 filesystem |
| `mount` | Mount the LV to a directory |
| `lvextend -L +1G` | Extend the LV by 1G |
| `resize2fs` | Resize filesystem after extending |
| `df -h` | Check mounted filesystem usage |

---

## 🧠 What I Learned

1. **LVM lets you combine multiple disks into one pool** - I attached 3 separate EBS volumes (10G + 12G + 14G) and merged them into a single 36G Volume Group. This is something traditional partitioning simply cannot do.

2. **The PV → VG → LV layered architecture gives real flexibility** - Instead of being stuck with fixed partition sizes, LVM lets you allocate storage dynamically from the pool as your application needs grow.

3. **Extending volumes online is safe and easy** - Using `lvextend` + `resize2fs`, I grew a mounted filesystem from 10G to 11G with zero downtime. This is extremely useful in production DevOps environments where you can't afford to stop services.

---
