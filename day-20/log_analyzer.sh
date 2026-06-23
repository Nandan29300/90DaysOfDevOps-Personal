#!/bin/bash

# ============================================================
#  log_analyzer.sh — Daily Log Analyzer & Report Generator
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
