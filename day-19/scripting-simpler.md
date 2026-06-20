# Day 19 - Shell Scripting Project: Log Rotation, Backup & Crontab

> **#90DaysOfDevOps | #DevOpsKaJosh | #TrainWithShubham**

---

## 📚 Table of Contents

1. [What Are We Building?](#what-are-we-building)
2. [Task 1 - Log Rotation Script](#task-1--log-rotation-script)
3. [Task 2 - Server Backup Script](#task-2--server-backup-script)
4. [Task 3 - Crontab Scheduling](#task-3--crontab-scheduling)
5. [Task 4 - Maintenance Script](#task-4--maintenance-script)
6. [Sample Outputs](#sample-outputs)
7. [Key Takeaways](#key-takeaways)
8. [Summary](#summary)
9. [Quick Reference Cheat Sheet](#quick-reference-cheat-sheet)

---

## What Are We Building?

| Script | What it does |
|--------|-------------|
| `log_rotate.sh` | Compresses old log files, deletes very old ones |
| `backup.sh` | Creates a timestamped zip of a folder |
| `maintenance.sh` | Runs both scripts together, saves output to a log file |
| Crontab entries | Schedules all of the above automatically |

---

## Task 1 - Log Rotation Script

### Why do we need this?

Log files grow every day. If you never clean them, your disk fills up and the server crashes.
Log rotation means:
- **Compress** logs older than 7 days → saves space
- **Delete** compressed logs older than 30 days → removes very old files

### Commands used

```bash
# Find .log files older than 7 days and compress them
find /var/log/myapp -name "*.log" -mtime +7 -exec gzip {} \;

# Find .gz files older than 30 days and delete them
find /var/log/myapp -name "*.gz" -mtime +30 -delete
```

> **What does `-mtime +7` mean?**
> `mtime` = modification time. `+7` = more than 7 days old. So this finds files that haven't changed in over 7 days.

> **What does `-exec gzip {} \;` mean?**
> For each file found, run `gzip` on it. `{}` is replaced by the filename. `\;` ends the command.

### Script: `log_rotate.sh`

```bash
#!/bin/bash
# log_rotate.sh
# Usage: ./log_rotate.sh /var/log/myapp

# Step 1: Take the directory as an argument
LOG_DIR=$1

# Step 2: Check if the directory exists, exit if not
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory '$LOG_DIR' does not exist."
    exit 1
fi

echo "Starting log rotation for: $LOG_DIR"

# Step 3: Compress .log files older than 7 days
echo "Compressing .log files older than 7 days..."
COMPRESSED=$(find "$LOG_DIR" -name "*.log" -mtime +7)

find "$LOG_DIR" -name "*.log" -mtime +7 -exec gzip {} \;

# Count how many were compressed
COUNT_COMPRESSED=$(echo "$COMPRESSED" | grep -c "." || echo 0)
echo "Files compressed: $COUNT_COMPRESSED"

# Step 4: Delete .gz files older than 30 days
echo "Deleting .gz files older than 30 days..."
DELETED=$(find "$LOG_DIR" -name "*.gz" -mtime +30)

find "$LOG_DIR" -name "*.gz" -mtime +30 -delete

COUNT_DELETED=$(echo "$DELETED" | grep -c "." || echo 0)
echo "Files deleted: $COUNT_DELETED"

echo "Log rotation done!"
```

### How to run

```bash
chmod +x log_rotate.sh
./log_rotate.sh /var/log/myapp
```

---

## Task 2 - Server Backup Script

### Why do we need this?

Backups let you restore your files if something goes wrong (accidental delete, crash, hack, etc.).
This script:
- Takes a source folder and a backup destination
- Creates a compressed `.tar.gz` archive with today's date in the name
- Checks the archive was actually created
- Deletes backups older than 14 days

### Commands used

```bash
# Get today's date
date +%Y-%m-%d        # Output: 2026-06-20

# Create a compressed archive
tar -czf backup-2026-06-20.tar.gz /var/www/myapp

# Check file size
du -sh backup-2026-06-20.tar.gz

# Check if a file exists
if [ -f "backup-2026-06-20.tar.gz" ]; then
    echo "Backup exists!"
fi
```

> **What does `tar -czf` mean?**
> - `c` = create a new archive
> - `z` = compress it using gzip
> - `f` = the next argument is the filename

### Script: `backup.sh`

```bash
#!/bin/bash
# backup.sh
# Usage: ./backup.sh /var/www/myapp /backups

# Step 1: Take source and destination as arguments
SOURCE=$1
DEST=$2

# Step 2: Check if source directory exists
if [ ! -d "$SOURCE" ]; then
    echo "Error: Source directory '$SOURCE' does not exist."
    exit 1
fi

# Step 3: Create destination folder if it doesn't exist
mkdir -p "$DEST"

# Step 4: Create a timestamped archive name
TODAY=$(date +%Y-%m-%d)
ARCHIVE_NAME="backup-${TODAY}.tar.gz"
ARCHIVE_PATH="${DEST}/${ARCHIVE_NAME}"

echo "Creating backup: $ARCHIVE_NAME"
tar -czf "$ARCHIVE_PATH" "$SOURCE"

# Step 5: Verify the archive was created
if [ -f "$ARCHIVE_PATH" ]; then
    SIZE=$(du -sh "$ARCHIVE_PATH" | cut -f1)
    echo "Backup created successfully!"
    echo "Archive : $ARCHIVE_NAME"
    echo "Size    : $SIZE"
else
    echo "Error: Backup failed! Archive not found."
    exit 1
fi

# Step 6: Delete backups older than 14 days
echo "Cleaning up backups older than 14 days..."
find "$DEST" -name "backup-*.tar.gz" -mtime +14 -delete
echo "Cleanup done."
```

### How to run

```bash
chmod +x backup.sh
./backup.sh /var/www/myapp /backups
```

---

## Task 3 - Crontab Scheduling

### What is Cron?

Cron is a **scheduler** built into Linux. It lets you run scripts automatically at any time — daily, weekly, every 5 minutes, etc.

Think of it like setting an alarm, but for scripts.

### Cron Syntax

```
* * * * *  command_to_run
│ │ │ │ │
│ │ │ │ └── Day of week  (0=Sunday, 6=Saturday)
│ │ │ └──── Month        (1-12)
│ │ └────── Day of month (1-31)
│ └──────── Hour         (0-23)
└────────── Minute       (0-59)
```

### Reading the syntax: simple examples

| Cron entry | What it means |
|-----------|--------------|
| `0 2 * * *` | Every day at 2:00 AM (`*` = any) |
| `0 3 * * 0` | Every Sunday at 3:00 AM (0 = Sunday) |
| `*/5 * * * *` | Every 5 minutes (`*/5` = every 5) |
| `0 1 * * *` | Every day at 1:00 AM |

### Check what's currently scheduled

```bash
crontab -l
```

If nothing is scheduled, you'll see: `no crontab for <username>`

### Cron entries for this project

```bash
# Run log rotation every day at 2 AM
0 2 * * * /home/ubuntu/scripts/log_rotate.sh /var/log/myapp

# Run backup every Sunday at 3 AM
0 3 * * 0 /home/ubuntu/scripts/backup.sh /var/www/myapp /backups

# Run a health check every 5 minutes
*/5 * * * * /home/ubuntu/scripts/health_check.sh
```

> ⚠️ **Important:** Use the **full path** to scripts in crontab. Cron doesn't know your shortcuts.
> Bad: `./backup.sh` | Good: `/home/ubuntu/scripts/backup.sh`

### How to add these to crontab

```bash
crontab -e      # Opens editor, paste the lines above, save and exit
crontab -l      # Verify they were saved
```

---

## Task 4 - Maintenance Script

### What is this?

Instead of running log rotation and backup separately, we combine them in one script.
It also saves all output to `/var/log/maintenance.log` with timestamps so you can check what happened later.

### Script: `maintenance.sh`

```bash
#!/bin/bash
# maintenance.sh
# Usage: ./maintenance.sh
# Cron: 0 1 * * * /home/ubuntu/scripts/maintenance.sh

LOG_FILE="/var/log/maintenance.log"

# Helper: print message with timestamp, save to log file too
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Maintenance Started ==="

# Run log rotation
log "Running log rotation..."
bash /home/ubuntu/scripts/log_rotate.sh /var/log/myapp >> "$LOG_FILE" 2>&1
log "Log rotation done."

# Run backup
log "Running backup..."
bash /home/ubuntu/scripts/backup.sh /var/www/myapp /backups >> "$LOG_FILE" 2>&1
log "Backup done."

log "=== Maintenance Complete ==="
```

> **What does `tee -a "$LOG_FILE"` mean?**
> `tee` prints to the screen AND saves to the file at the same time.
> `-a` means append (don't overwrite the file).

> **What does `>> "$LOG_FILE" 2>&1` mean?**
> `>>` = append output to the log file.
> `2>&1` = also send errors to the same place (not just success messages).

### Cron entry for maintenance.sh

```bash
# Run full maintenance every day at 1 AM
0 1 * * * /home/ubuntu/scripts/maintenance.sh
```

---

## Sample Outputs

### log_rotate.sh

```
Starting log rotation for: /var/log/myapp
Compressing .log files older than 7 days...
Files compressed: 3
Deleting .gz files older than 30 days...
Files deleted: 1
Log rotation done!
```

### backup.sh

```
Creating backup: backup-2026-06-20.tar.gz
Backup created successfully!
Archive : backup-2026-06-20.tar.gz
Size    : 47M
Cleaning up backups older than 14 days...
Cleanup done.
```

### /var/log/maintenance.log

```
[2026-06-20 01:00:00] === Maintenance Started ===
[2026-06-20 01:00:00] Running log rotation...
[2026-06-20 01:00:01] Log rotation done.
[2026-06-20 01:00:01] Running backup...
[2026-06-20 01:00:06] Backup done.
[2026-06-20 01:00:06] === Maintenance Complete ===
```

### Error case (wrong directory)

```bash
$ ./log_rotate.sh /wrong/path
Error: Directory '/wrong/path' does not exist.

$ echo $?
1
```

---

## Key Takeaways

### 1. `find` + `-mtime` is how Linux manages old files

```bash
find /path -name "*.log" -mtime +7   # files older than 7 days
find /path -name "*.gz"  -mtime +30  # files older than 30 days
```

This one command replaces hours of manual checking. It's the backbone of log rotation everywhere.

### 2. Always check if a directory or file exists before using it

```bash
if [ ! -d "$DIR" ]; then
    echo "Error: directory not found"
    exit 1
fi
```

Without this check, your script will throw confusing errors. With it, you get a clean message and a graceful exit.

### 3. Cron uses full paths — always

Cron runs in a minimal environment. It doesn't know about your `$PATH` or aliases.
- ❌ `./backup.sh`
- ✅ `/home/ubuntu/scripts/backup.sh`

### 4. Timestamped logs = easier debugging

```bash
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup done." >> /var/log/maintenance.log
```

When something fails at 2 AM while you're sleeping, this log tells you exactly what happened and when.

### 5. Compose small scripts, don't repeat yourself

`maintenance.sh` doesn't copy the backup or log rotation logic. It just **calls** the other scripts. If you fix a bug in `backup.sh`, `maintenance.sh` automatically benefits too.

---

## Summary

| Concept | What we used |
|---------|-------------|
| Find old files | `find -name -mtime` |
| Compress files | `gzip`, `tar -czf` |
| Check existence | `if [ ! -d ]`, `if [ -f ]` |
| Timestamps | `date +%Y-%m-%d` |
| File size | `du -sh` |
| Logging | `tee -a`, `>> file 2>&1` |
| Scheduling | `crontab -e`, cron syntax |

Today we applied everything from Days 16-18 to build real scripts that are actually used in production Linux environments. Log rotation and backups are the first things any DevOps engineer sets up on a new server.

---

## Quick Reference Cheat Sheet

```bash
# ── FIND ─────────────────────────────────────────────────────────────────────
find /path -name "*.log" -mtime +7          # Files older than 7 days
find /path -name "*.gz" -mtime +30 -delete  # Delete .gz older than 30 days
find /path -name "*.log" -mtime +7 -exec gzip {} \;  # Compress old logs

# ── GZIP ─────────────────────────────────────────────────────────────────────
gzip file.log        # Compress → creates file.log.gz
gunzip file.log.gz   # Decompress

# ── TAR ──────────────────────────────────────────────────────────────────────
tar -czf archive.tar.gz /folder/   # Create compressed archive
tar -tzf archive.tar.gz            # List contents
tar -xzf archive.tar.gz            # Extract

# ── DATE ─────────────────────────────────────────────────────────────────────
date +%Y-%m-%d              # 2026-06-20
date '+%Y-%m-%d %H:%M:%S'  # 2026-06-20 14:30:00

# ── DISK USAGE ───────────────────────────────────────────────────────────────
du -sh file.tar.gz    # Human-readable size
du -sh /var/log/      # Directory size

# ── CRONTAB ──────────────────────────────────────────────────────────────────
crontab -l   # List current jobs
crontab -e   # Edit jobs
crontab -r   # Remove ALL jobs (careful!)

# ── CRON TIMING ──────────────────────────────────────────────────────────────
0 2 * * *     # Every day at 2 AM
0 3 * * 0     # Every Sunday at 3 AM
*/5 * * * *   # Every 5 minutes
0 1 * * *     # Every day at 1 AM

# ── LOGGING ──────────────────────────────────────────────────────────────────
echo "$(date): message" >> /var/log/app.log   # Append with timestamp
command >> log.txt 2>&1                        # Stdout + stderr to file
echo "msg" | tee -a log.txt                   # Print + append to file
```

---

*Day 19 Complete ✅ | Next: Day 20*

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#ShellScripting` `#Linux`
