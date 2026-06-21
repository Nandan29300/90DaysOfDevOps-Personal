# Day 19 – Shell Scripting Project: Log Rotation, Backup & Crontab

---

## 📚 Table of Contents

1. [Concepts Overview](#concepts-overview)
2. [Task 1 – Log Rotation Script](#task-1--log-rotation-script)
3. [Task 2 – Server Backup Script](#task-2--server-backup-script)
4. [Task 3 – Crontab Scheduling](#task-3--crontab-scheduling)
5. [Task 4 – Combined Maintenance Script](#task-4--combined-maintenance-script)
6. [Sample Outputs](#sample-outputs)
7. [Key Takeaways](#key-takeaways)
8. [Summary](#summary)
9. [Quick Reference / Cheat Sheet](#quick-reference--cheat-sheet)

---

## Concepts Overview

Before diving into the scripts, let's understand the core tools and commands used across all tasks.

### `find` – The Swiss Army Knife for File Discovery

```bash
find <path> <options> <action>
```

| Flag | Meaning | Example |
|------|---------|---------|
| `-name "*.log"` | Match by filename pattern | `find /var/log -name "*.log"` |
| `-mtime +7` | Modified MORE than 7 days ago | `find /tmp -mtime +7` |
| `-mtime -1` | Modified LESS than 1 day ago | `find . -mtime -1` |
| `-exec cmd {} \;` | Run command on each result | `find . -name "*.log" -exec gzip {} \;` |
| `-delete` | Delete matched files | `find . -name "*.tmp" -delete` |

> **Why `+7` means "older than 7 days":** The `+` means "greater than", i.e., the file's modification time is more than 7 days in the past.

### `gzip` – Compress Files

```bash
gzip filename.log       # Creates filename.log.gz and removes original
gzip -k filename.log    # Keep original, create .gz copy
gunzip filename.log.gz  # Decompress
```

### `tar` – Archive + Compress

```bash
tar -czf archive.tar.gz /path/to/source/
#   -c  = create
#   -z  = compress with gzip
#   -f  = specify filename
```

```bash
tar -tzf archive.tar.gz    # List contents (verify)
tar -xzf archive.tar.gz    # Extract
```

### `du` – Disk Usage (check file size)

```bash
du -sh file.tar.gz    # Human-readable size of a single file
du -sh /var/log/      # Total size of a directory
```

### `date` – Timestamps

```bash
date +%Y-%m-%d           # 2026-06-20
date +%Y-%m-%d_%H-%M-%S  # 2026-06-20_14-30-00
date                     # Full current date and time
```

---

## Task 1 – Log Rotation Script

### What is Log Rotation?

Log rotation is the process of managing growing log files by:
- **Compressing** old logs to save space
- **Deleting** very old archives to prevent disk bloat
- **Keeping recent logs** available for troubleshooting

Without log rotation, `/var/log/` can fill up your disk and crash your server!

### Script: `log_rotate.sh`

```bash
#!/bin/bash
# =============================================================================
# log_rotate.sh – Log Rotation Script
# Usage: ./log_rotate.sh <log_directory>
# Example: ./log_rotate.sh /var/log/myapp
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

validate_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        echo -e "${RED}[ERROR]${NC} Directory '$dir' does not exist. Exiting."
        exit 1
    fi
}

compress_old_logs() {
    local dir="$1"
    local count=0

    log "Scanning for .log files older than 7 days in: $dir"

    while IFS= read -r -d '' file; do
        if [ -s "$file" ]; then
            gzip "$file"
            log "Compressed: $file → ${file}.gz"
            ((count++)) || true
        else
            log "Skipped (empty): $file"
        fi
    done < <(find "$dir" -name "*.log" -mtime +7 -print0)

    echo -e "${GREEN}✔ Files compressed: $count${NC}"
    COMPRESSED_COUNT=$count
}

delete_old_archives() {
    local dir="$1"
    local count=0

    log "Scanning for .gz files older than 30 days in: $dir"

    while IFS= read -r -d '' file; do
        rm -f "$file"
        log "Deleted: $file"
        ((count++)) || true
    done < <(find "$dir" -name "*.gz" -mtime +30 -print0)

    echo -e "${GREEN}✔ Archives deleted: $count${NC}"
    DELETED_COUNT=$count
}

main() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <log_directory>"
        echo "Example: $0 /var/log/myapp"
        exit 1
    fi

    local LOG_DIR="$1"

    log "=== Log Rotation Started ==="
    validate_directory "$LOG_DIR"
    compress_old_logs "$LOG_DIR"
    delete_old_archives "$LOG_DIR"

    echo ""
    echo -e "${YELLOW}=== Log Rotation Summary ===${NC}"
    echo -e "  Directory  : $LOG_DIR"
    echo -e "  Compressed : ${COMPRESSED_COUNT} file(s)"
    echo -e "  Deleted    : ${DELETED_COUNT} file(s)"
    log "=== Log Rotation Complete ==="
}

main "$@"
```

### Code Walkthrough

| Section | What it does |
|---------|-------------|
| `set -euo pipefail` | Strict mode - script stops on any error |
| `validate_directory()` | Checks if the directory exists; exits with error if not |
| `compress_old_logs()` | Finds `.log` files older than 7 days and `gzip`s them |
| `delete_old_archives()` | Finds `.gz` files older than 30 days and deletes them |
| `while IFS= read -r -d '' file` | Safely reads `find -print0` output - handles spaces in filenames |
| `((count++))` | Arithmetic increment; counts files processed |
| `main "$@"` | Entry point that passes all script arguments |

> **Why `find ... -print0` and `read -d ''`?**
> Filenames can contain spaces. Using `-print0` separates results with null bytes (`\0`) instead of newlines, and `read -d ''` reads null-delimited input - making this space-safe.

---

## Task 2 – Server Backup Script

### What is a Server Backup?

A backup creates a compressed snapshot of a directory so you can restore it later. Best practices:
- **Timestamped filenames** - so you can identify when each backup was taken
- **Verify the archive** - confirm it was actually created
- **Retention policy** - automatically delete old backups to save storage

### Script: `backup.sh`

```bash
#!/bin/bash
# =============================================================================
# backup.sh – Server Backup Script
# Usage: ./backup.sh <source_directory> <backup_destination>
# Example: ./backup.sh /var/www/myapp /backups
# =============================================================================

set -euo pipefail

# ── Colour helpers ───────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error_exit() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# ── validate_source() ────────────────────────────────────────────────────────
validate_source() {
    local src="$1"
    [[ -d "$src" ]] || error_exit "Source directory '$src' does not exist. Exiting."
}

# ── create_backup() ──────────────────────────────────────────────────────────
create_backup() {
    local src="$1"
    local dest="$2"

    # Create destination if it doesn't exist
    mkdir -p "$dest"

    # Generate timestamped archive name: backup-2026-06-20.tar.gz
    local timestamp
    timestamp=$(date +%Y-%m-%d)
    ARCHIVE_NAME="backup-${timestamp}.tar.gz"
    ARCHIVE_PATH="${dest}/${ARCHIVE_NAME}"

    log "Creating archive: $ARCHIVE_NAME"
    tar -czf "$ARCHIVE_PATH" "$src"
}

# ── verify_backup() ──────────────────────────────────────────────────────────
verify_backup() {
    local archive="$1"

    if [[ -f "$archive" ]]; then
        ARCHIVE_SIZE=$(du -sh "$archive" | cut -f1)
        echo -e "${GREEN}✔ Archive verified: $archive${NC}"
        echo -e "  Size: ${ARCHIVE_SIZE}"
    else
        error_exit "Archive was NOT created. Backup failed!"
    fi
}

# ── cleanup_old_backups() – delete backups older than 14 days ────────────────
cleanup_old_backups() {
    local dest="$1"
    local count=0

    log "Removing backups older than 14 days from: $dest"

    while IFS= read -r -d '' file; do
        rm -f "$file"
        log "Removed old backup: $file"
        ((count++)) || true
    done < <(find "$dest" -name "backup-*.tar.gz" -mtime +14 -print0)

    echo -e "${GREEN}✔ Old backups deleted: $count${NC}"
}

# ── main() ───────────────────────────────────────────────────────────────────
main() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: $0 <source_directory> <backup_destination>"
        echo "Example: $0 /var/www/myapp /backups"
        exit 1
    fi

    local SRC="$1"
    local DEST="$2"

    log "=== Server Backup Started ==="
    validate_source "$SRC"
    create_backup "$SRC" "$DEST"
    verify_backup "$ARCHIVE_PATH"
    cleanup_old_backups "$DEST"

    echo ""
    echo -e "${YELLOW}=== Backup Summary ===${NC}"
    echo -e "  Source      : $SRC"
    echo -e "  Destination : $DEST"
    echo -e "  Archive     : $ARCHIVE_NAME"
    echo -e "  Size        : $ARCHIVE_SIZE"
    log "=== Backup Complete ==="
}

main "$@"
```

### Code Walkthrough

| Section | What it does |
|---------|-------------|
| `error_exit()` | Prints error message and exits with code 1 |
| `mkdir -p "$dest"` | Creates the backup dir if it doesn't exist; `-p` prevents error if already exists |
| `date +%Y-%m-%d` | Generates date string like `2026-06-20` for the filename |
| `tar -czf` | Creates a gzip-compressed tar archive |
| `du -sh` | Shows human-readable file size; `cut -f1` extracts just the size |
| `[[ -f "$archive" ]]` | File existence test - verifies backup was created |
| `find ... -name "backup-*.tar.gz" -mtime +14` | Targets only our backup files (not others) older than 14 days |

---

## Task 3 – Crontab Scheduling

### What is Cron?

Cron is a **time-based job scheduler** in Linux. It runs commands or scripts automatically at specified intervals - perfect for maintenance tasks like backups and log rotation.

### Cron Syntax - Fully Explained

```
* * * * *  /path/to/command
│ │ │ │ │
│ │ │ │ └── Day of week  (0–7, where 0 and 7 = Sunday)
│ │ │ └──── Month        (1–12)
│ │ └────── Day of month (1–31)
│ └──────── Hour         (0–23)
└────────── Minute       (0–59)
```

### Special Syntax Shortcuts

| Shortcut | Equivalent | Meaning |
|----------|-----------|---------|
| `@reboot` | - | Run once at startup |
| `@hourly` | `0 * * * *` | Every hour |
| `@daily` | `0 0 * * *` | Every day at midnight |
| `@weekly` | `0 0 * * 0` | Every Sunday at midnight |
| `@monthly` | `0 0 1 * *` | First day of every month |

### Cron Field Examples

| Expression | Meaning |
|------------|---------|
| `0 2 * * *` | Every day at 2:00 AM |
| `0 3 * * 0` | Every Sunday at 3:00 AM |
| `*/5 * * * *` | Every 5 minutes |
| `30 9 * * 1-5` | Weekdays at 9:30 AM |
| `0 0 1 * *` | First of every month at midnight |

### Current Crontab

```bash
# Check what's currently scheduled:
crontab -l

# Edit your crontab:
crontab -e

# Remove all cron jobs:
crontab -r
```

### Cron Entries for This Project

```bash
# ── Log Rotation: every day at 2 AM ──────────────────────────────────────────
0 2 * * * /home/ubuntu/scripts/log_rotate.sh /var/log/myapp >> /var/log/log_rotate.log 2>&1

# ── Server Backup: every Sunday at 3 AM ──────────────────────────────────────
0 3 * * 0 /home/ubuntu/scripts/backup.sh /var/www/myapp /backups >> /var/log/backup.log 2>&1

# ── Health Check: every 5 minutes ────────────────────────────────────────────
*/5 * * * * /home/ubuntu/scripts/health_check.sh >> /var/log/health_check.log 2>&1
```

> **What does `>> /var/log/backup.log 2>&1` mean?**
> - `>>` - Append stdout to the log file (don't overwrite)
> - `2>&1` - Redirect stderr (error output) to the same place as stdout
> So both normal output AND errors go into your log file.

### Cron Environment Warning

Cron runs with a minimal environment - your shell aliases and `$PATH` may not be available. Always use **absolute paths** in cron entries:

```bash
# BAD (cron might not find 'backup.sh')
0 3 * * 0 backup.sh /var/www /backups

# GOOD (always use full path)
0 3 * * 0 /home/ubuntu/scripts/backup.sh /var/www /backups
```

---

## Task 4 – Combined Maintenance Script

### What is a Maintenance Script?

A maintenance script combines multiple tasks (log rotation + backup) into a single scheduled operation, with unified logging. Instead of running two separate cron jobs, you run one - making it easier to trace what happened and when.

### Script: `maintenance.sh`

```bash
#!/bin/bash
# =============================================================================
# maintenance.sh – Combined Scheduled Maintenance
# Usage: ./maintenance.sh <log_dir> <src_dir> <backup_dest>
# Example: ./maintenance.sh /var/log/myapp /var/www/myapp /backups
# Cron: 0 1 * * * /home/ubuntu/scripts/maintenance.sh /var/log/myapp /var/www/myapp /backups
# =============================================================================

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
MAINTENANCE_LOG="/var/log/maintenance.log"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ── ts_log() – timestamped log to both terminal and log file ─────────────────
ts_log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo -e "${BLUE}${msg}${NC}"
    echo "$msg" >> "$MAINTENANCE_LOG"
}

# ── run_log_rotation() ───────────────────────────────────────────────────────
run_log_rotation() {
    local log_dir="$1"
    ts_log ">>> Starting Log Rotation for: $log_dir"

    if bash "${SCRIPT_DIR}/log_rotate.sh" "$log_dir" >> "$MAINTENANCE_LOG" 2>&1; then
        ts_log "✔ Log rotation completed successfully."
    else
        ts_log "✘ Log rotation encountered an error. Check $MAINTENANCE_LOG."
    fi
}

# ── run_backup() ─────────────────────────────────────────────────────────────
run_backup() {
    local src="$1"
    local dest="$2"
    ts_log ">>> Starting Backup: $src → $dest"

    if bash "${SCRIPT_DIR}/backup.sh" "$src" "$dest" >> "$MAINTENANCE_LOG" 2>&1; then
        ts_log "✔ Backup completed successfully."
    else
        ts_log "✘ Backup encountered an error. Check $MAINTENANCE_LOG."
    fi
}

# ── main() ───────────────────────────────────────────────────────────────────
main() {
    if [[ $# -ne 3 ]]; then
        echo "Usage: $0 <log_directory> <source_directory> <backup_destination>"
        echo "Example: $0 /var/log/myapp /var/www/myapp /backups"
        exit 1
    fi

    local LOG_DIR="$1"
    local SRC_DIR="$2"
    local BACKUP_DEST="$3"

    # Ensure the maintenance log directory exists
    mkdir -p "$(dirname "$MAINTENANCE_LOG")"

    ts_log "========================================"
    ts_log "=== Maintenance Window Started ==="
    ts_log "========================================"

    run_log_rotation "$LOG_DIR"
    run_backup "$SRC_DIR" "$BACKUP_DEST"

    ts_log "========================================"
    ts_log "=== Maintenance Window Complete ==="
    ts_log "========================================"
}

main "$@"
```

### Cron Entry for maintenance.sh

```bash
# Run full maintenance every day at 1 AM
0 1 * * * /home/ubuntu/scripts/maintenance.sh /var/log/myapp /var/www/myapp /backups
```

### Code Walkthrough

| Section | What it does |
|---------|-------------|
| `SCRIPT_DIR=$(dirname $(realpath "$0"))` | Gets the directory where the script lives - so it can call sibling scripts using relative paths safely |
| `ts_log()` | Logs to both terminal AND `/var/log/maintenance.log` with a timestamp |
| `>> "$MAINTENANCE_LOG" 2>&1` | Appends both stdout and stderr of child scripts to the maintenance log |
| `if bash "${SCRIPT_DIR}/log_rotate.sh"; then` | Runs the script and checks if it succeeded; logs success/failure |
| `mkdir -p "$(dirname "$MAINTENANCE_LOG")"` | Ensures `/var/log/` exists before writing to it |

---

## Sample Outputs

### log_rotate.sh
 
```
[2026-06-21 07:07:59] === Log Rotation Started ===
[2026-06-21 07:07:59] Scanning for .log files older than 7 days in: /home/ubuntu/testlogs/
[2026-06-21 07:07:59] Skipped (empty): /home/ubuntu/testlogs/recent.log
[2026-06-21 07:07:59] Compressed: /home/ubuntu/testlogs/error.log → /home/ubuntu/testlogs/error.log.gz
[2026-06-21 07:07:59] Compressed: /home/ubuntu/testlogs/app.log → /home/ubuntu/testlogs/app.log.gz
✔ Files compressed: 2
[2026-06-21 07:07:59] Scanning for .gz files older than 30 days in: /home/ubuntu/testlogs/
✔ Archives deleted: 0
 
=== Log Rotation Summary ===
  Directory  : /home/ubuntu/testlogs/
  Compressed : 2 file(s)
  Deleted    : 0 file(s)
[2026-06-21 07:07:59] === Log Rotation Complete ===
```

### backup.sh
 
```
[2026-06-21 06:22:36] === Server Backup Started ===
[2026-06-21 06:22:36] Creating archive: backup-2026-06-21.tar.gz
✔ Archive verified: /backups/backup-2026-06-21.tar.gz
  Size: 4.3M
[2026-06-21 06:22:37] Removing backups older than 14 days from: /backups
✔ Old backups deleted: 0
 
=== Backup Summary ===
  Source      : /var/log
  Destination : /backups
  Archive     : backup-2026-06-21.tar.gz
  Size        : 4.3M
[2026-06-21 06:22:37] === Backup Complete ===
```

### maintenance.sh
 
```
[2026-06-21 07:07:59] ========================================
[2026-06-21 07:07:59] === Maintenance Window Started ===
[2026-06-21 07:07:59] ========================================
[2026-06-21 07:07:59] >>> Starting Log Rotation for: /var/log
[2026-06-21 07:07:59] ✔ Log rotation completed successfully.
[2026-06-21 07:07:59] >>> Starting Backup: /var/log → /backups
[2026-06-21 07:08:00] ✔ Backup completed successfully.
[2026-06-21 07:08:00] ========================================
[2026-06-21 07:08:00] === Maintenance Window Complete ===
[2026-06-21 07:08:00] ========================================
```

### /var/log/maintenance.log
 
```
[2026-06-21 07:07:59] === Maintenance Window Started ===
[2026-06-21 07:07:59] >>> Starting Log Rotation for: /var/log
[2026-06-21 07:07:59] === Log Rotation Started ===
[2026-06-21 07:07:59] Scanning for .log files older than 7 days in: /var/log
[2026-06-21 07:07:59] Skipped (empty): /var/log/alternatives.log
[2026-06-21 07:07:59] Skipped (empty): /var/log/ubuntu-advantage-apt-hook.log
[2026-06-21 07:07:59] Skipped (empty): /var/log/apt/history.log
✔ Files compressed: 0
[2026-06-21 07:07:59] Scanning for .gz files older than 30 days in: /var/log
✔ Archives deleted: 0
=== Log Rotation Summary ===
  Directory  : /var/log
  Compressed : 0 file(s)
  Deleted    : 0 file(s)
[2026-06-21 07:07:59] === Log Rotation Complete ===
[2026-06-21 07:07:59] ✔ Log rotation completed successfully.
[2026-06-21 07:07:59] >>> Starting Backup: /var/log → /backups
[2026-06-21 07:07:59] === Server Backup Started ===
[2026-06-21 07:07:59] Creating archive: backup-2026-06-21.tar.gz
✔ Archive verified: /backups/backup-2026-06-21.tar.gz
  Size: 4.3M
[2026-06-21 07:08:00] Removing backups older than 14 days from: /backups
✔ Old backups deleted: 0
=== Backup Summary ===
  Source      : /var/log
  Destination : /backups
  Archive     : backup-2026-06-21.tar.gz
  Size        : 4.3M
[2026-06-21 07:08:00] === Backup Complete ===
[2026-06-21 07:08:00] ✔ Backup completed successfully.
[2026-06-21 07:08:00] === Maintenance Window Complete ===
```

### Error case (wrong directory)
 
```bash
$ ./log_rotate.sh /nonexistent/path
[ERROR] Directory '/nonexistent/path' does not exist. Exiting.
 
$ echo $?
1
```

---

## Key Takeaways

### 1. 🔐 `set -euo pipefail` is Your Safety Net

In production scripts, unexpected errors can cause partial execution - which is often worse than doing nothing. Strict mode ensures:
- `-e` → Script stops immediately on failure
- `-u` → No silent bugs from typos in variable names
- `-o pipefail` → Errors inside `cmd1 | cmd2` aren't swallowed

Always use it in real-world scripts.

### 2. 🗂️ `find` with `-mtime` and `-print0` is Powerful but Nuanced

`-mtime +7` doesn't mean "7 days ago exactly" - it means "more than 7 full 24-hour periods ago." Combine it with `-print0` and `read -d ''` to safely handle filenames with spaces or special characters. This is the production-grade pattern, not just the simple `find ... -exec`.

### 3. ⏰ Cron is Simple but Has Traps

Cron's minimal environment means your `~/.bashrc` aliases and `$PATH` don't exist. Scripts that work fine in your terminal can silently fail in cron. Always:
- Use **absolute paths** to scripts and commands
- Redirect output to a log file (`>> logfile 2>&1`)
- Test your script standalone before scheduling

### 4. 🔁 Composition > Duplication

The `maintenance.sh` script doesn't copy log rotation or backup logic - it **calls** the existing scripts. This is the Unix philosophy: small, focused tools that compose well. If you fix a bug in `log_rotate.sh`, `maintenance.sh` automatically gets the fix.

### 5. 📝 Always Log with Timestamps

A cron job runs silently in the background. Without timestamped logs, debugging "why did it fail last Tuesday?" is nearly impossible. The `ts_log()` pattern (write to terminal + append to file with timestamp) is a simple but powerful habit.

---

## Summary

Today's project brought together everything from Days 16–18 into real-world scripts that are genuinely useful in production Linux environments.

| Task | Script | Core Tools Used |
|------|--------|----------------|
| Log Rotation | `log_rotate.sh` | `find`, `gzip`, `mtime`, `set -euo pipefail` |
| Server Backup | `backup.sh` | `tar`, `date`, `du`, `find`, `mkdir -p` |
| Scheduling | Crontab entries | `crontab -e`, cron syntax |
| Combined | `maintenance.sh` | Script composition, `ts_log()`, `2>&1` |

**The bigger picture:** These three scripts form the foundation of any Linux server's maintenance routine. In production systems at companies like yours, these are often the first scripts a DevOps engineer writes - and they save hours of manual effort every week.

---

## Quick Reference / Cheat Sheet

```bash
# ─── FIND ──────────────────────────────────────────────────────────────────
find /path -name "*.log" -mtime +7           # Files older than 7 days
find /path -name "*.gz" -mtime +30 -delete   # Delete .gz older than 30 days
find /path -name "*.log" -mtime +7 -print0   # Null-delimited (space-safe)

# ─── GZIP ──────────────────────────────────────────────────────────────────
gzip file.log                                # Compress (removes original)
gunzip file.log.gz                           # Decompress
gzip -k file.log                             # Keep original

# ─── TAR ───────────────────────────────────────────────────────────────────
tar -czf archive.tar.gz /source/dir/        # Create compressed archive
tar -tzf archive.tar.gz                     # List contents (verify)
tar -xzf archive.tar.gz                     # Extract

# ─── DATE ──────────────────────────────────────────────────────────────────
date +%Y-%m-%d                              # 2026-06-20
date '+%Y-%m-%d %H:%M:%S'                  # 2026-06-20 14:30:00

# ─── DISK USAGE ────────────────────────────────────────────────────────────
du -sh file.tar.gz                          # Human-readable file size
du -sh /var/log/                            # Directory total size

# ─── CRONTAB ───────────────────────────────────────────────────────────────
crontab -l                                  # List current jobs
crontab -e                                  # Edit (opens $EDITOR)
crontab -r                                  # Remove all jobs (careful!)

# ─── CRON TIMING EXAMPLES ──────────────────────────────────────────────────
0 2 * * *    # Every day at 2:00 AM
0 3 * * 0    # Every Sunday at 3:00 AM
*/5 * * * *  # Every 5 minutes
0 0 1 * *    # First of every month at midnight

# ─── LOGGING PATTERN ───────────────────────────────────────────────────────
echo "$(date '+%Y-%m-%d %H:%M:%S'): message" >> /var/log/app.log
command >> /var/log/app.log 2>&1            # stdout + stderr to log file
```

---
