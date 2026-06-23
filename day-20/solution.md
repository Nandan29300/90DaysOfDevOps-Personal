# Day 20 – Bash Scripting Challenge: Log Analyzer and Report Generator

## Overview

As a system administrator, analyzing log files daily is one of the most routine yet critical tasks. Doing it manually across dozens of servers is slow, error-prone, and exhausting. This challenge automates the entire workflow — parsing logs, counting errors, surfacing critical events, ranking top failures, and generating a clean summary report — all with a single Bash script.

---

## Script: `log_analyzer.sh`

```bash
#!/bin/bash

# ============================================================
#  log_analyzer.sh — Daily Log Analyzer & Report Generator
#  Day 20 | 90DaysOfDevOps | @TrainWithShubham
# ============================================================

set -euo pipefail

# ---------- Colors ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ============================================================
# TASK 1 — Input Validation
# ============================================================

if [[ $# -eq 0 ]]; then
    echo -e "${RED}[ERROR]${RESET} No log file provided."
    echo -e "Usage: $0 <path-to-log-file>"
    exit 1
fi

LOG_FILE="$1"

if [[ ! -f "$LOG_FILE" ]]; then
    echo -e "${RED}[ERROR]${RESET} File not found: '$LOG_FILE'"
    exit 1
fi

echo -e "${GREEN}[INFO]${RESET} Analyzing log file: ${BOLD}$LOG_FILE${RESET}"
echo ""

# ============================================================
# TASK 2 — Error Count
# ============================================================

TOTAL_LINES=$(wc -l < "$LOG_FILE")
ERROR_COUNT=$(grep -cE "ERROR|Failed" "$LOG_FILE" || true)

echo -e "${CYAN}${BOLD}--- Error Summary ---${RESET}"
echo -e "Total lines processed : ${BOLD}$TOTAL_LINES${RESET}"
echo -e "Total errors found    : ${RED}${BOLD}$ERROR_COUNT${RESET}"
echo ""

# ============================================================
# TASK 3 — Critical Events
# ============================================================

echo -e "${CYAN}${BOLD}--- Critical Events ---${RESET}"

CRITICAL_LINES=$(grep -n "CRITICAL" "$LOG_FILE" || true)

if [[ -z "$CRITICAL_LINES" ]]; then
    echo "No critical events found."
else
    while IFS= read -r line; do
        LINE_NUM="${line%%:*}"
        LINE_CONTENT="${line#*:}"
        echo -e "Line ${BOLD}${LINE_NUM}${RESET}:${LINE_CONTENT}"
    done <<< "$CRITICAL_LINES"
fi
echo ""

# ============================================================
# TASK 4 — Top 5 Error Messages
# ============================================================

echo -e "${CYAN}${BOLD}--- Top 5 Error Messages ---${RESET}"

grep "ERROR" "$LOG_FILE" \
    | awk '{$1=$2=$3=""; print $0}' \
    | sed 's/^ *//' \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -5 \
    | while read -r count msg; do
        printf "%-5s %s\n" "$count" "$msg"
      done
echo ""

# ============================================================
# TASK 5 — Summary Report
# ============================================================

DATE=$(date +%Y-%m-%d)
REPORT_FILE="log_report_${DATE}.txt"

TOP_5=$(grep "ERROR" "$LOG_FILE" \
    | awk '{$1=$2=$3=""; print $0}' \
    | sed 's/^ *//' \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -5)

CRITICAL_EVENTS=$(grep -n "CRITICAL" "$LOG_FILE" || true)

cat > "$REPORT_FILE" << REPORT
============================================================
           DAILY LOG ANALYSIS REPORT
============================================================
Date of Analysis  : $(date "+%Y-%m-%d %H:%M:%S")
Log File          : $LOG_FILE
------------------------------------------------------------

SUMMARY
-------
Total Lines Processed : $TOTAL_LINES
Total Errors Found    : $ERROR_COUNT

------------------------------------------------------------

TOP 5 ERROR MESSAGES
--------------------
$(echo "$TOP_5" | while read -r count msg; do printf "%-5s %s\n" "$count" "$msg"; done)

------------------------------------------------------------

CRITICAL EVENTS
---------------
$(if [[ -z "$CRITICAL_EVENTS" ]]; then
    echo "No critical events found."
else
    while IFS= read -r line; do
        LINE_NUM="${line%%:*}"
        LINE_CONTENT="${line#*:}"
        echo "Line $LINE_NUM: $LINE_CONTENT"
    done <<< "$CRITICAL_EVENTS"
fi)

------------------------------------------------------------
             End of Report
============================================================
REPORT

echo -e "${GREEN}[INFO]${RESET} Report saved to: ${BOLD}${REPORT_FILE}${RESET}"
echo ""

# ============================================================
# TASK 6 (Optional) — Archive Processed Log
# ============================================================

ARCHIVE_DIR="archive"

if [[ ! -d "$ARCHIVE_DIR" ]]; then
    mkdir -p "$ARCHIVE_DIR"
    echo -e "${GREEN}[INFO]${RESET} Created archive directory: ${BOLD}${ARCHIVE_DIR}/${RESET}"
fi

mv "$LOG_FILE" "$ARCHIVE_DIR/"
echo -e "${GREEN}[INFO]${RESET} Archived log to: ${BOLD}${ARCHIVE_DIR}/$(basename "$LOG_FILE")${RESET}"
echo ""
echo -e "${GREEN}${BOLD}✓ Analysis complete!${RESET}"
```

---

## How to Run

```bash
# Make it executable
chmod +x log_analyzer.sh

# Run against a log file
./log_analyzer.sh sample_log.log
```

---

## Sample Output

Running against `sample_log.log` (50 lines):

```
[INFO] Analyzing log file: sample_log.log

--- Error Summary ---
Total lines processed : 50
Total errors found    : 33

--- Critical Events ---
Line 9: 2026-06-01 00:30:01 CRITICAL Disk space below threshold
Line 25: 2026-06-01 01:32:55 CRITICAL Database connection lost
Line 37: 2026-06-01 02:21:58 CRITICAL Memory usage exceeded 95%
Line 47: 2026-06-01 03:00:19 CRITICAL Network interface eth1 down

--- Top 5 Error Messages ---
11    Connection timed out to database
5     Permission denied: /etc/shadow
5     File not found: /var/data/config.json
4     Disk I/O error on /dev/sdb
1     Out of memory: kill process 7890

[INFO] Report saved to: log_report_2026-06-22.txt
[INFO] Created archive directory: archive/
[INFO] Archived log to: archive/sample_log.log

✓ Analysis complete!
```

### Generated Report (`log_report_2026-06-22.txt`)

```
============================================================
           DAILY LOG ANALYSIS REPORT
============================================================
Date of Analysis  : 2026-06-22 11:23:50
Log File          : sample_log.log
------------------------------------------------------------

SUMMARY
-------
Total Lines Processed : 50
Total Errors Found    : 33

------------------------------------------------------------

TOP 5 ERROR MESSAGES
--------------------
11    Connection timed out to database
5     Permission denied: /etc/shadow
5     File not found: /var/data/config.json
4     Disk I/O error on /dev/sdb
1     Out of memory: kill process 7890

------------------------------------------------------------

CRITICAL EVENTS
---------------
Line 9: 2026-06-01 00:30:01 CRITICAL Disk space below threshold
Line 25: 2026-06-01 01:32:55 CRITICAL Database connection lost
Line 37: 2026-06-01 02:21:58 CRITICAL Memory usage exceeded 95%
Line 47: 2026-06-01 03:00:19 CRITICAL Network interface eth1 down

------------------------------------------------------------
             End of Report
============================================================
```

---

## Commands and Tools Used

| Tool / Command | What It Does | Where Used |
|---|---|---|
| `grep -cE "ERROR\|Failed"` | Counts lines matching either pattern using extended regex | Task 2 – Error count |
| `grep -n "CRITICAL"` | Searches for pattern and prints matching line numbers | Task 3 – Critical events |
| `awk '{$1=$2=$3=""; print}'` | Clears the first 3 fields (date, time, level) to isolate the message | Task 4 – Message extraction |
| `sed 's/^ *//'` | Strips leading whitespace left behind after awk clears fields | Task 4 – Cleanup |
| `sort` | Alphabetically sorts lines so identical messages are adjacent | Task 4 – Pre-grouping |
| `uniq -c` | Counts consecutive duplicate lines and prepends the count | Task 4 – Counting occurrences |
| `sort -rn` | Sorts numerically in reverse (highest count first) | Task 4 – Ranking |
| `head -5` | Takes only the top 5 results | Task 4 – Limiting output |
| `wc -l` | Counts total lines in the file | Task 2 – Line count |
| `date +%Y-%m-%d` | Generates today's date for the report filename | Task 5 – Naming |
| `cat > file << HEREDOC` | Writes a multi-line block directly to a file | Task 5 – Report generation |
| `mkdir -p` | Creates directory (and parents) without error if it exists | Task 6 – Archive setup |
| `mv` | Moves the processed log into the archive directory | Task 6 – Archiving |
| `set -euo pipefail` | Strict mode: exit on error, treat unset vars as errors, catch pipe failures | All tasks – Safety |
| `[[ $# -eq 0 ]]` | Checks if zero arguments were passed | Task 1 – Validation |
| `[[ ! -f "$LOG_FILE" ]]` | Checks if the given path is not a regular file | Task 1 – Validation |

---

## Definitions and Concepts Explained

### `grep`

`grep` (Global Regular Expression Print) scans a file line by line and prints lines that match a given pattern.

```bash
grep "ERROR" logfile.log          # basic match
grep -c "ERROR" logfile.log       # count matching lines
grep -n "CRITICAL" logfile.log    # show line numbers
grep -cE "ERROR|Failed" logfile.log  # match either pattern (extended regex)
```

The `-E` flag enables **extended regular expressions**, letting you use `|` for OR logic without escaping.

---

### `awk`

`awk` is a field-processing tool. By default it splits each line on whitespace and calls each chunk `$1`, `$2`, `$3`...

In this script, log lines follow this format:

```
2026-06-01 00:05:23 ERROR Connection timed out to database
  $1           $2    $3   $4       $5     $6   $7   $8
```

By setting `$1=$2=$3=""`, we blank out the date, time, and log level — leaving just the actual error message. Combined with `sed 's/^ *//'` to strip the trailing spaces, we get clean, deduplicated message strings.

---

### `sort | uniq -c | sort -rn`

This is the classic "frequency ranking" pipeline in shell scripting:

```
sort              → groups identical lines together
uniq -c           → counts consecutive duplicates, outputs: "  11 Connection timed out"
sort -rn          → sorts by that number, highest first (-r = reverse, -n = numeric)
head -5           → keeps only top 5
```

This chain is fundamental — it appears in log analysis, access log parsing, word frequency counters, and almost any "find the most common X" problem.

---

### `set -euo pipefail`

Three safety switches combined into one line:

| Flag | What It Does |
|---|---|
| `-e` | Exit immediately if any command returns a non-zero status |
| `-u` | Treat any unset variable as an error (prevents silent bugs from typos) |
| `-o pipefail` | A pipe fails if **any** command in it fails, not just the last one |

Without this, a script can silently continue after a failure, producing incorrect output or corrupting data.

---

### Heredoc (`<< HEREDOC`)

A heredoc lets you write a multi-line string directly in the script and redirect it into a command (like `cat > file`). Everything between the two markers is treated as a literal block — no need to echo each line separately.

```bash
cat > report.txt << EOF
Line 1
Line 2
EOF
```

You can also embed live variables and command substitutions (`$(...)`) inside a heredoc, which is how the report is dynamically generated here.

---

### String Manipulation with `%%` and `#`

When parsing `grep -n` output like `9:2026-06-01 00:30:01 CRITICAL ...`:

```bash
LINE_NUM="${line%%:*}"    # Delete from first ':' to end  → "9"
LINE_CONTENT="${line#*:}" # Delete up to and including first ':' → "2026-06-01..."
```

These are **parameter expansion operators** built into Bash — faster than spawning a new `cut` or `awk` process for simple splits.

---

## Key Takeaways

**1. `grep + awk + sort + uniq` is the core log analysis pipeline.**
This combination is not specific to this challenge — it's used in production monitoring, security audits, and access log analysis everywhere. Once you internalize this pipeline, you can answer "what's the most common X in this file?" for any log format in seconds.

**2. Always validate inputs before doing any work.**
Checking for missing arguments and non-existent files at the top of the script prevents silent failures or confusing errors halfway through execution. `set -euo pipefail` adds a second layer of safety by making the script fail loudly instead of continuing with bad state.

**3. A script that cleans up after itself is production-ready.**
Moving processed logs to an `archive/` directory means you never accidentally analyze the same file twice, you maintain an audit trail, and your working directory stays clean. This is the difference between a one-time hack and a script you can actually schedule with cron.

---

## File Structure

```
day-20/
├── log_analyzer.sh          # Main script
├── sample_log.log           # Sample log (before running) / moved to archive after
├── log_report_2026-06-22.txt  # Generated report
├── archive/
│   └── sample_log.log       # Archived log after analysis
└── day-20-solution.md       # This file
```

---
