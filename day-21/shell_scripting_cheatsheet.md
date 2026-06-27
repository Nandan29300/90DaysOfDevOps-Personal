# 🐚 Shell Scripting Cheat Sheet
> A personal quick-reference guide built from 20+ days of hands-on shell scripting.

---

## ⚡ Quick Reference Table

| Topic | Key Syntax | Example |
|-------|-----------|---------|
| Variable | `VAR="value"` | `NAME="DevOps"` |
| Argument | `$1`, `$2` | `./script.sh arg1` |
| If | `if [ condition ]; then` | `if [ -f file ]; then` |
| For loop | `for i in list; do` | `for i in 1 2 3; do` |
| Function | `name() { ... }` | `greet() { echo "Hi"; }` |
| Grep | `grep pattern file` | `grep -i "error" log.txt` |
| Awk | `awk '{print $1}' file` | `awk -F: '{print $1}' /etc/passwd` |
| Sed | `sed 's/old/new/g' file` | `sed -i 's/foo/bar/g' config.txt` |
| Exit code | `$?` | `echo $?` → `0` means success |
| Trap | `trap 'fn' EXIT` | `trap 'cleanup' EXIT` |

---

## 📌 Task 1: Basics

### Shebang - `#!/bin/bash`
Tells the OS which interpreter to use. Must be the **first line** of the script.
```bash
#!/bin/bash
# Without this, the script may run with sh or the wrong shell
```

### Running a Script
```bash
chmod +x script.sh     # Make it executable
./script.sh            # Run directly
bash script.sh         # Run with bash explicitly (no chmod needed)
```

### Comments
```bash
# This is a single-line comment

echo "Hello"  # This is an inline comment
```

### Variables
```bash
NAME="Nandan"          # Declare (no spaces around =)
echo $NAME             # Use variable
echo "$NAME"           # Quoted - safe, preserves spaces
echo '$NAME'           # Single quotes - treats literally, prints $NAME

# Best practice: always double-quote variables
FILE="my file.txt"
cat "$FILE"            # Correct - handles spaces in name
cat $FILE              # Wrong - breaks on spaces
```

### Reading User Input
```bash
echo "Enter your name:"
read NAME
echo "Hello, $NAME!"

read -p "Enter age: " AGE          # Inline prompt
read -s -p "Password: " PASS       # Silent input (for passwords)
```

### Command-Line Arguments
```bash
#!/bin/bash
echo "Script name : $0"
echo "First arg   : $1"
echo "Second arg  : $2"
echo "Total args  : $#"
echo "All args    : $@"
echo "Exit status : $?"

# Usage: ./script.sh hello world
```

| Special Var | Meaning |
|-------------|---------|
| `$0` | Script name |
| `$1`, `$2` | Positional arguments |
| `$#` | Number of arguments |
| `$@` | All arguments (as separate strings) |
| `$*` | All arguments (as a single string) |
| `$?` | Exit status of last command |
| `$$` | Current script's PID |

---

## 📌 Task 2: Operators and Conditionals

### String Comparisons
```bash
[ "$A" = "$B" ]    # Equal
[ "$A" != "$B" ]   # Not equal
[ -z "$A" ]        # True if string is EMPTY
[ -n "$A" ]        # True if string is NOT empty
```

### Integer Comparisons
```bash
[ $A -eq $B ]   # Equal
[ $A -ne $B ]   # Not equal
[ $A -lt $B ]   # Less than
[ $A -gt $B ]   # Greater than
[ $A -le $B ]   # Less than or equal
[ $A -ge $B ]   # Greater than or equal
```

### File Test Operators
```bash
[ -f "$FILE" ]   # Is a regular file
[ -d "$DIR"  ]   # Is a directory
[ -e "$PATH" ]   # Exists (file or dir)
[ -r "$FILE" ]   # Readable
[ -w "$FILE" ]   # Writable
[ -x "$FILE" ]   # Executable
[ -s "$FILE" ]   # File exists and is non-empty
```

### if / elif / else
```bash
#!/bin/bash
SCORE=75

if [ $SCORE -ge 90 ]; then
    echo "Grade: A"
elif [ $SCORE -ge 75 ]; then
    echo "Grade: B"
elif [ $SCORE -ge 60 ]; then
    echo "Grade: C"
else
    echo "Grade: F"
fi
```

### Logical Operators
```bash
# AND - both must be true
if [ -f "file.txt" ] && [ -r "file.txt" ]; then
    echo "File exists and is readable"
fi

# OR - at least one must be true
if [ "$USER" = "root" ] || [ "$USER" = "admin" ]; then
    echo "Privileged user"
fi

# NOT - negate condition
if [ ! -d "/tmp/backup" ]; then
    mkdir /tmp/backup
fi
```

### Case Statement
```bash
#!/bin/bash
read -p "Enter day (Mon/Tue/...): " DAY

case "$DAY" in
    Mon|Monday)
        echo "Start of the work week!" ;;
    Fri|Friday)
        echo "Weekend is near!" ;;
    Sat|Sun)
        echo "It's the weekend!" ;;
    *)
        echo "Just another weekday." ;;
esac
```

---

## 📌 Task 3: Loops

### for Loop - List-Based
```bash
for FRUIT in apple banana mango; do
    echo "Fruit: $FRUIT"
done
```

### for Loop - C-Style
```bash
for (( i=1; i<=5; i++ )); do
    echo "Count: $i"
done
```

### while Loop
```bash
COUNT=1
while [ $COUNT -le 5 ]; do
    echo "Line $COUNT"
    (( COUNT++ ))
done
```

### until Loop
Runs until condition becomes **true** (opposite of while).
```bash
N=1
until [ $N -gt 5 ]; do
    echo "N = $N"
    (( N++ ))
done
```

### Loop Control - break & continue
```bash
for i in 1 2 3 4 5; do
    [ $i -eq 3 ] && continue   # Skip 3
    [ $i -eq 5 ] && break      # Stop at 5
    echo "$i"
done
# Output: 1 2 4
```

### Looping Over Files
```bash
for file in *.log; do
    echo "Processing: $file"
    wc -l "$file"
done
```

### Looping Over Command Output
```bash
# Read lines from a file or command output
while read line; do
    echo "Line: $line"
done < /etc/passwd

# Or from a command
df -h | while read line; do
    echo "$line"
done
```

---

## 📌 Task 4: Functions

### Defining and Calling a Function
```bash
#!/bin/bash

greet() {
    echo "Hello, DevOps World!"
}

greet    # Call the function
```

### Passing Arguments to Functions
Arguments are accessed as `$1`, `$2` etc. **inside** the function - independent of script-level args.
```bash
say_hello() {
    echo "Hello, $1! You are $2 years old."
}

say_hello "Nandan" 22
# Output: Hello, Nandan! You are 22 years old.
```

### Return Values
- `return` → returns an **exit code** (0–255), accessible via `$?`
- `echo` → returns actual **output**, captured via command substitution

```bash
# Using return (exit code only)
is_even() {
    (( $1 % 2 == 0 )) && return 0 || return 1
}
is_even 4 && echo "Even" || echo "Odd"

# Using echo (return actual value)
add() {
    echo $(( $1 + $2 ))
}
RESULT=$(add 10 20)
echo "Sum = $RESULT"   # Sum = 30
```

### Local Variables
`local` limits the variable scope to the function only - avoids polluting the global namespace.
```bash
counter() {
    local COUNT=0       # Only visible inside this function
    COUNT=$(( COUNT + 1 ))
    echo "Count: $COUNT"
}

counter
echo "$COUNT"   # Prints nothing - COUNT is local
```

---

## 📌 Task 5: Text Processing Commands

### grep - Search Patterns
```bash
grep "error" app.log              # Basic search
grep -i "error" app.log           # Case-insensitive
grep -r "TODO" ./src/             # Recursive search in directory
grep -c "error" app.log           # Count matching lines
grep -n "error" app.log           # Show line numbers
grep -v "debug" app.log           # Invert match (exclude "debug")
grep -E "err(or)?|fail" app.log   # Extended regex
grep -l "error" *.log             # List files containing match
```

### awk - Column Processing
```bash
awk '{print $1}' file.txt                  # Print 1st column
awk '{print $1, $3}' file.txt              # Print 1st and 3rd columns
awk -F: '{print $1}' /etc/passwd           # Custom field separator (:)
awk '$3 > 1000' /etc/passwd                # Filter rows where column 3 > 1000
awk 'BEGIN {print "Start"} {print} END {print "End"}' file.txt
awk '{sum += $1} END {print "Total:", sum}' numbers.txt   # Sum a column
```

### sed - Stream Editor
```bash
sed 's/old/new/' file.txt          # Replace first occurrence per line
sed 's/old/new/g' file.txt         # Replace all occurrences (global)
sed -i 's/foo/bar/g' config.txt    # Edit file in-place
sed '3d' file.txt                  # Delete line 3
sed '/error/d' file.txt            # Delete lines containing "error"
sed -n '5,10p' file.txt            # Print lines 5 to 10 only
sed 's/^/>> /' file.txt            # Add prefix to every line
```

### cut - Extract Columns
```bash
cut -d: -f1 /etc/passwd            # Field 1, delimiter :
cut -d, -f2,4 data.csv             # Fields 2 and 4, delimiter ,
cut -c1-10 file.txt                # Characters 1 to 10
```

### sort - Sorting
```bash
sort file.txt                      # Alphabetical sort
sort -n numbers.txt                # Numerical sort
sort -r file.txt                   # Reverse order
sort -u file.txt                   # Sort and remove duplicates
sort -t: -k3 -n /etc/passwd        # Sort by 3rd field (: delimiter), numerically
```

### uniq - Deduplicate
> ⚠️ Works on **adjacent** duplicates - always sort first!
```bash
sort file.txt | uniq               # Remove duplicates
sort file.txt | uniq -c            # Count occurrences
sort file.txt | uniq -d            # Show only duplicate lines
sort file.txt | uniq -u            # Show only unique lines
```

### tr - Translate / Delete Characters
```bash
echo "hello" | tr 'a-z' 'A-Z'     # Lowercase to uppercase
echo "hello world" | tr ' ' '_'   # Replace spaces with underscores
echo "he##ll##o" | tr -d '#'      # Delete # characters
echo "aabbcc" | tr -s 'a-z'       # Squeeze repeated chars
```

### wc - Word / Line / Char Count
```bash
wc -l file.txt      # Line count
wc -w file.txt      # Word count
wc -c file.txt      # Byte count
wc -m file.txt      # Character count
wc file.txt         # All three: lines, words, bytes
```

### head / tail
```bash
head -n 20 file.txt        # First 20 lines
tail -n 20 file.txt        # Last 20 lines
tail -f /var/log/syslog    # Follow mode - stream new lines in real time
tail -n 50 -f app.log      # Last 50 lines, then follow
```

---

## 📌 Task 6: Useful Patterns and One-Liners

### 1. Find and delete files older than N days
```bash
find /tmp -type f -mtime +7 -delete
# Deletes files in /tmp not modified in the last 7 days
```

### 2. Count total lines across all .log files
```bash
wc -l *.log | tail -1
# Shows per-file counts + grand total at the end
```

### 3. Replace a string across multiple files
```bash
grep -rl "old_string" ./configs/ | xargs sed -i 's/old_string/new_string/g'
# Finds all files containing "old_string" and replaces it in-place
```

### 4. Check if a service is running
```bash
systemctl is-active --quiet nginx && echo "nginx is UP" || echo "nginx is DOWN"
```

### 5. Monitor disk usage and alert if above threshold
```bash
USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
[ "$USAGE" -gt 80 ] && echo "⚠️  Disk usage is at ${USAGE}%!" || echo "✅ Disk OK (${USAGE}%)"
```

### 6. Tail a log and filter errors in real time
```bash
tail -f /var/log/syslog | grep --line-buffered -i "error\|fail\|critical"
```

### 7. Parse CSV - print specific column
```bash
awk -F, '{print $2}' data.csv | tail -n +2
# Prints column 2, skipping the header row
```

### 8. Kill all processes matching a name
```bash
pgrep -f "process_name" | xargs kill -9
```

### 9. Show top 10 most-used commands from history
```bash
history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10
```

### 10. One-liner to archive and compress a directory
```bash
tar -czf "backup_$(date +%Y%m%d).tar.gz" /path/to/dir
```

---

## 📌 Task 7: Error Handling and Debugging

### Exit Codes
Every command returns an exit code. `0` = success, non-zero = failure.
```bash
ls /nonexistent
echo "Exit code: $?"    # Prints: Exit code: 2

# Explicitly set exit codes in scripts
exit 0     # Success
exit 1     # General error
exit 2     # Misuse of command
```

### set -e - Exit on Error
Script exits immediately if any command fails (non-zero exit).
```bash
#!/bin/bash
set -e

cp file.txt /backup/      # If this fails, script stops here
echo "Backup done"        # This won't run if cp failed
```

### set -u - Treat Unset Variables as Error
Catches bugs from typos in variable names.
```bash
#!/bin/bash
set -u

echo "$UNDEFINED_VAR"    # Script exits with error instead of printing blank
```

### set -o pipefail - Catch Errors in Pipes
By default, only the last command's exit code matters in a pipe. `pipefail` catches failures anywhere in the pipeline.
```bash
#!/bin/bash
set -o pipefail

cat missing_file.txt | grep "pattern"
# Without pipefail: exit 0 (grep succeeded on empty input)
# With pipefail: exit 1 (cat failed)
```

### set -x - Debug Mode (Trace Execution)
Prints each command before executing it - great for debugging.
```bash
#!/bin/bash
set -x

NAME="Nandan"
echo "Hello, $NAME"
# Output:
# + NAME=Nandan
# + echo 'Hello, Nandan'
# Hello, Nandan
```

### Combining Flags (Best Practice Header)
```bash
#!/bin/bash
set -euo pipefail
# -e: exit on error
# -u: error on unset vars
# -o pipefail: catch pipe errors
```

### trap - Cleanup on Exit
`trap` runs a command or function when the script exits or receives a signal.
```bash
#!/bin/bash
set -e

cleanup() {
    echo "Cleaning up temp files..."
    rm -f /tmp/my_temp_$$
}

trap 'cleanup' EXIT        # Runs on any exit (normal or error)
trap 'echo "Interrupted!"' INT    # Runs on Ctrl+C

touch /tmp/my_temp_$$
echo "Doing work..."
# cleanup() is called automatically when script ends
```

| Signal | When it triggers |
|--------|-----------------|
| `EXIT` | Any exit (normal or error) |
| `INT` | Ctrl+C (interrupt) |
| `TERM` | `kill` command |
| `ERR` | Any command fails (with `set -e`) |

---

## 🗂️ Common Patterns Summary

```bash
# Safe script header (always start with this)
#!/bin/bash
set -euo pipefail

# Check if argument was passed
[ $# -lt 1 ] && { echo "Usage: $0 <arg>"; exit 1; }

# Check if file exists before using it
[ ! -f "$1" ] && { echo "File not found: $1"; exit 1; }

# Default value if variable is unset
NAME="${1:-default_value}"

# Run command silently, check result
if command -v docker &>/dev/null; then
    echo "Docker is installed"
fi

# Redirect stdout and stderr to a log file
./script.sh >> output.log 2>&1
```

---
