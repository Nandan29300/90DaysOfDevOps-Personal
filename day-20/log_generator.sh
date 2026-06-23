#!/bin/bash
# Usage: ./log_generator.sh <log_file_path> <num_lines>
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <log_file_path> <num_lines>"
    exit 1
fi

log_file_path="$1"
num_lines="$2"

if [ -e "$log_file_path" ]; then
    echo "Error: File already exists at $log_file_path."
    exit 1
fi

log_levels=("INFO" "DEBUG" "ERROR" "WARNING" "CRITICAL" "Failed")

error_messages=(
    "Connection timed out"
    "File not found"
    "Permission denied"
    "Disk I/O error"
    "Out of memory"
)

critical_messages=(
    "Disk space below threshold"
    "Database connection lost"
    "Memory usage exceeded 95%"
    "Network interface eth1 down"
)

failed_messages=(
    "Failed to authenticate user admin"
    "Failed to start service nginx"
    "Failed to mount /dev/sdc"
)

generate_log_line() {
    local log_level="${log_levels[$((RANDOM % ${#log_levels[@]}))]}"

    if [ "$log_level" == "ERROR" ]; then
        local msg="${error_messages[$((RANDOM % ${#error_messages[@]}))]}"
        echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR $msg"

    elif [ "$log_level" == "CRITICAL" ]; then
        local msg="${critical_messages[$((RANDOM % ${#critical_messages[@]}))]}"
        echo "$(date '+%Y-%m-%d %H:%M:%S') CRITICAL $msg"

    elif [ "$log_level" == "Failed" ]; then
        local msg="${failed_messages[$((RANDOM % ${#failed_messages[@]}))]}"
        echo "$(date '+%Y-%m-%d %H:%M:%S') $msg"

    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') $log_level System event $RANDOM"
    fi
}

touch "$log_file_path"
for ((i=0; i<num_lines; i++)); do
    generate_log_line >> "$log_file_path"
done

echo "Log file created at: $log_file_path with $num_lines lines."
