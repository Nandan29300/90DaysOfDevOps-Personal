# Day 18 – Shell Scripting: Functions & Intermediate Concepts

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Task 1 – Basic Functions (`functions.sh`)](#task-1--basic-functions)
3. [Task 2 – Functions with Return Values (`disk_check.sh`)](#task-2--functions-with-return-values)
4. [Task 3 – Strict Mode (`strict_demo.sh`)](#task-3--strict-mode)
5. [Task 4 – Local Variables (`local_demo.sh`)](#task-4--local-variables)
6. [Task 5 – System Info Reporter (`system_info.sh`)](#task-5--system-info-reporter)
7. [Concept Deep Dives](#concept-deep-dives)
8. [Comparison Tables](#comparison-tables)
9. [Key Takeaways](#key-takeaways)
10. [Summary](#summary)

---

## Overview

Shell scripting moves from "it works" to "it works *well*" when you start using:
- **Functions** – reusable, named blocks of logic
- **Strict mode** – catch errors before they cascade
- **Local variables** – prevent variable leaks across functions

These are the foundations of production-quality bash scripts used in DevOps, automation, and CI/CD pipelines.

---

## Task 1 – Basic Functions

### 📄 Script: `functions.sh`

```bash
#!/bin/bash
# functions.sh – Basic function definitions and calls

# Function 1: greet
# Takes a name as $1 and prints a greeting
greet() {
    local name="$1"
    echo "Hello, ${name}!"
}

# Function 2: add
# Takes two numbers as $1 and $2 and prints their sum
add() {
    local num1="$1"
    local num2="$2"
    local result=$(( num1 + num2 ))
    echo "Sum of ${num1} + ${num2} = ${result}"
}

# ── Main ──────────────────────────────────────────────
greet "Nandan"
greet "DevOps Engineer"

add 10 25
add 100 200
```

### 🖥️ Expected Output

```
Hello, Nandan!
Hello, DevOps Engineer!
Sum of 10 + 25 = 35
Sum of 100 + 200 = 300
```

### 💡 Explanation

| Concept | Detail |
|---|---|
| `greet()` | Defines a function named `greet` |
| `$1` | First positional argument passed to the function |
| `local name="$1"` | Assigns arg to a local variable (safe practice) |
| `$(( ))` | Arithmetic expansion in bash |
| `greet "Nandan"` | Calls the function and passes `"Nandan"` as `$1` |

> **Syntax Rule:** Function definitions use `function_name() { ... }`. The function must be defined *before* it is called.

---

## Task 2 – Functions with Return Values

### 📄 Script: `disk_check.sh`

```bash
#!/bin/bash
# disk_check.sh – Functions that check system resources

# Function: check_disk
# Displays disk usage of the root partition /
check_disk() {
    echo "===== Disk Usage (/) ====="
    df -h /
    echo ""
}

# Function: check_memory
# Displays current free memory
check_memory() {
    echo "===== Memory Usage ====="
    free -h
    echo ""
}

# ── Main ──────────────────────────────────────────────
echo "==============================="
echo "  System Resource Check Report "
echo "==============================="
echo ""

check_disk
check_memory

echo "Report complete."
```

### 🖥️ Expected Output

```
===============================
  System Resource Check Report
===============================

===== Disk Usage (/) =====
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   18G   30G  38% /

===== Memory Usage =====
               total        used        free      shared  buff/cache   available
Mem:            15Gi       3.2Gi       8.1Gi       512Mi       3.8Gi        11Gi
Swap:          2.0Gi          0B       2.0Gi

Report complete.
```

### 💡 Explanation

| Command | What it Does |
|---|---|
| `df -h /` | Shows disk space for `/` in human-readable format (KB, MB, GB) |
| `free -h` | Shows RAM and swap usage in human-readable format |
| Functions with no `return` | The function's output goes to `stdout` - captured or printed directly |
| Calling a function | Just write `check_disk` - no parentheses needed at call time |

> **Note on Return Values in Bash:** Bash functions don't return data like Python/JS. They either:
> 1. Print output (`echo`) which callers can capture with `$(function_name)`
> 2. Return an exit code (0–255) via `return N` - `0` = success, non-zero = error

---

## Task 3 – Strict Mode

### 📄 Script: `strict_demo.sh`

```bash
#!/bin/bash
# strict_demo.sh – Demonstrates set -euo pipefail behavior

set -euo pipefail

echo "Script started with strict mode ON"

# ─── Demonstrating set -u ─────────────────────────────
# Uncomment ONE block at a time to test each behavior

# TEST 1: set -u catches undefined variables
# echo "Value: $UNDEFINED_VAR"
# ↑ Without set -u: prints empty string silently
# ↑ With    set -u: bash: UNDEFINED_VAR: unbound variable → script exits

# ─── Demonstrating set -e ─────────────────────────────
# TEST 2: set -e stops script on command failure
# ls /this/path/does/not/exist
# ↑ Without set -e: error printed, script continues
# ↑ With    set -e: script exits immediately at the failed command

# ─── Demonstrating set -o pipefail ────────────────────
# TEST 3: pipefail catches failure in the MIDDLE of a pipe
# grep "nonexistent" /dev/null | sort
# ↑ Without pipefail: grep fails (exit 1), sort succeeds (exit 0) → overall = 0 (HIDDEN!)
# ↑ With    pipefail: overall exit code = 1 (the failing command) → caught by set -e

echo "✅ All checks passed - strict mode working correctly"
```

### 🖥️ Expected Output (when no tests triggered)

```
Script started with strict mode ON
✅ All checks passed - strict mode working correctly
```

### 🖥️ Output when `$UNDEFINED_VAR` is uncommented

```
Script started with strict mode ON
strict_demo.sh: line 14: UNDEFINED_VAR: unbound variable
```

### 🧠 What Each Flag Does

| Flag | Full Name | Behavior Without It | Behavior With It |
|---|---|---|---|
| `set -e` | Exit on error | Script continues even when commands fail | Script exits immediately on any non-zero exit code |
| `set -u` | Treat unset variables as errors | Undefined variables silently expand to empty string `""` | Script exits with `unbound variable` error |
| `set -o pipefail` | Pipe failure propagation | Pipe returns exit code of *last* command only | Pipe returns exit code of *first failed* command |

### 🔐 Why Use Strict Mode in DevOps?

```bash
# BAD: Without strict mode, this silently corrupts
rm -rf /$TYPO_VAR/important    # If TYPO_VAR is empty → rm -rf /important !!!

# GOOD: With set -u, the script stops before disaster
set -u
rm -rf /${DEPLOY_DIR}/old      # If DEPLOY_DIR is unset → exits immediately
```

---

## Task 4 – Local Variables

### 📄 Script: `local_demo.sh`

```bash
#!/bin/bash
# local_demo.sh – Demonstrates local vs global variable scoping

# ─── Function WITH local variables ────────────────────
function_with_local() {
    local message="I am LOCAL"
    local count=42
    echo "Inside function_with_local: message = '${message}', count = ${count}"
}

# ─── Function WITHOUT local variables ─────────────────
function_without_local() {
    message="I am GLOBAL (leaked!)"
    count=99
    echo "Inside function_without_local: message = '${message}', count = ${count}"
}

# ─── Main ─────────────────────────────────────────────

echo "=== Test 1: Local Variables ==="
message="original"
count=0
echo "Before call: message = '${message}', count = ${count}"

function_with_local

echo "After call:  message = '${message}', count = ${count}"
# Expected: message is still 'original', count is still 0
# Local variables did NOT leak!

echo ""
echo "=== Test 2: Global Variable Leak ==="
message="original"
count=0
echo "Before call: message = '${message}', count = ${count}"

function_without_local

echo "After call:  message = '${message}', count = ${count}"
# Expected: message = 'I am GLOBAL (leaked!)', count = 99
# Variables LEAKED out of the function!
```

### 🖥️ Expected Output

```
=== Test 1: Local Variables ===
Before call: message = 'original', count = 0
Inside function_with_local: message = 'I am LOCAL', count = 42
After call:  message = 'original', count = 0

=== Test 2: Global Variable Leak ===
Before call: message = 'original', count = 0
Inside function_without_local: message = 'I am GLOBAL (leaked!)', count = 99
After call:  message = 'I am GLOBAL (leaked!)', count = 99
```

### 🔍 Local vs Global Comparison Table

| Feature | `local` Variables | Regular (Global) Variables |
|---|---|---|
| Scope | Only inside the function | Entire script |
| After function returns | Destroyed | Persists (and modifies caller's state!) |
| Risk | Safe ✅ | Can cause subtle bugs ⚠️ |
| Best practice | Always use in functions | Use only for truly global config |
| Syntax | `local VAR="value"` | `VAR="value"` |

---

## Task 5 – System Info Reporter

### 📄 Script: `system_info.sh`

```bash
#!/bin/bash
# system_info.sh – A clean system information reporter
# Uses functions for every section, with strict mode enabled

set -euo pipefail

# ─── Helper: Section Header ───────────────────────────
print_header() {
    local title="$1"
    echo ""
    echo "╔══════════════════════════════════════╗"
    printf  "║  %-36s║\n" "$title"
    echo "╚══════════════════════════════════════╝"
}

# ─── Function 1: Hostname & OS Info ──────────────────
print_system_info() {
    print_header "🖥️  SYSTEM INFORMATION"
    echo "Hostname   : $(hostname)"
    echo "OS         : $(uname -o 2>/dev/null || uname -s)"
    echo "Kernel     : $(uname -r)"
    echo "Architecture: $(uname -m)"
    if [ -f /etc/os-release ]; then
        echo "Distro     : $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
    fi
}

# ─── Function 2: Uptime ───────────────────────────────
print_uptime() {
    print_header "⏱️  UPTIME"
    uptime -p 2>/dev/null || uptime
    echo "Boot time  : $(who -b 2>/dev/null | awk '{print $3, $4}' || echo "N/A")"
}

# ─── Function 3: Disk Usage (Top 5) ──────────────────
print_disk_usage() {
    print_header "💾  DISK USAGE (Top 5 by Size)"
    echo "Filesystem        Size  Used  Avail  Use%  Mounted"
    echo "──────────────────────────────────────────────────"
    df -h --output=source,size,used,avail,pcent,target 2>/dev/null \
        | tail -n +2 \
        | sort -k2 -rh \
        | head -5 \
        || df -h | tail -n +2 | head -5
}

# ─── Function 4: Memory Usage ────────────────────────
print_memory_usage() {
    print_header "🧠  MEMORY USAGE"
    free -h
}

# ─── Function 5: Top 5 CPU Processes ─────────────────
print_top_processes() {
    print_header "🔥  TOP 5 CPU-CONSUMING PROCESSES"
    printf "%-8s %-20s %-6s %-6s\n" "PID" "COMMAND" "%CPU" "%MEM"
    echo "──────────────────────────────────────"
    ps aux --sort=-%cpu 2>/dev/null \
        | awk 'NR>1 {printf "%-8s %-20s %-6s %-6s\n", $2, $11, $3, $4}' \
        | head -5 \
        || echo "ps command not available"
}

# ─── Main Function ────────────────────────────────────
main() {
    echo "╔══════════════════════════════════════╗"
    echo "║       SYSTEM INFO REPORTER           ║"
    echo "║   Generated: $(date '+%Y-%m-%d %H:%M:%S')    ║"
    echo "╚══════════════════════════════════════╝"

    print_system_info
    print_uptime
    print_disk_usage
    print_memory_usage
    print_top_processes

    echo ""
    echo "══════════════════════════════════════"
    echo "  ✅ Report complete."
    echo "══════════════════════════════════════"
}

# Entry point
main
```

### 🖥️ Expected Output

```
╔══════════════════════════════════════╗
║       SYSTEM INFO REPORTER           ║
║   Generated: 2025-07-01 14:30:22    ║
╚══════════════════════════════════════╝

╔══════════════════════════════════════╗
║  🖥️  SYSTEM INFORMATION              ║
╚══════════════════════════════════════╝
Hostname   : devops-server-01
OS         : GNU/Linux
Kernel     : 5.15.0-76-generic
Architecture: x86_64
Distro     : Ubuntu 22.04.2 LTS

╔══════════════════════════════════════╗
║  ⏱️  UPTIME                          ║
╚══════════════════════════════════════╝
up 3 days, 4 hours, 12 minutes
Boot time  : 2025-06-28 10:15

╔══════════════════════════════════════╗
║  💾  DISK USAGE (Top 5 by Size)     ║
╚══════════════════════════════════════╝
Filesystem        Size  Used  Avail  Use%  Mounted
──────────────────────────────────────────────────
/dev/sda1          50G   18G   30G    38%  /
/dev/sdb1         200G   85G  105G    45%  /data
tmpfs             7.7G  512M  7.2G     7%  /dev/shm

╔══════════════════════════════════════╗
║  🧠  MEMORY USAGE                   ║
╚══════════════════════════════════════╝
               total        used        free      shared  buff/cache   available
Mem:            15Gi       3.2Gi       8.1Gi       512Mi       3.8Gi        11Gi
Swap:          2.0Gi          0B       2.0Gi

╔══════════════════════════════════════╗
║  🔥  TOP 5 CPU-CONSUMING PROCESSES  ║
╚══════════════════════════════════════╝
PID      COMMAND              %CPU   %MEM
──────────────────────────────────────
1234     nginx                 8.5    1.2
5678     node                  6.2    3.4
9012     python3               4.1    2.8
3456     postgres              2.3    5.6
7890     bash                  0.5    0.1

══════════════════════════════════════
  ✅ Report complete.
══════════════════════════════════════
```

---

## Concept Deep Dives

### 🔤 Function Syntax - Full Reference

```bash
# Style 1: Most common (POSIX-compatible)
greet() {
    echo "Hello, $1"
}

# Style 2: With function keyword (bash-specific)
function greet {
    echo "Hello, $1"
}

# Call a function
greet "World"

# Capture function output into a variable
result=$(greet "World")
echo "$result"

# Check function exit code
greet "World"
if [ $? -eq 0 ]; then
    echo "Function succeeded"
fi
```

### 📦 Passing Arguments to Functions

```bash
multi_arg_func() {
    echo "Arg 1: $1"
    echo "Arg 2: $2"
    echo "Arg 3: $3"
    echo "All args: $@"
    echo "Arg count: $#"
}

multi_arg_func "apple" "banana" "cherry"
```

Output:
```
Arg 1: apple
Arg 2: banana
Arg 3: cherry
All args: apple banana cherry
Arg count: 3
```

### 🔁 Return Values - Two Patterns

```bash
# Pattern 1: Return exit code (0-255 only)
is_even() {
    local num=$1
    if (( num % 2 == 0 )); then
        return 0   # success = true = even
    else
        return 1   # failure = false = odd
    fi
}

is_even 4 && echo "4 is even" || echo "4 is odd"
is_even 7 && echo "7 is even" || echo "7 is odd"

# Pattern 2: Echo output (return any data type)
get_username() {
    echo "Nandan"   # print the value
}

USER=$(get_username)  # capture it
echo "Username: $USER"
```

### ⚙️ `set -euo pipefail` - Deep Dive

```bash
#!/bin/bash
set -euo pipefail
# This single line adds three safety layers:

# -e : Exit on error
failing_command() {
    ls /nonexistent 2>/dev/null  # If this fails...
    echo "This won't print"      # ...this never runs
}

# -u : Catch undefined variables
safe_usage() {
    local required_var="${MY_VAR:-}"   # Safe: default to empty
    local strict_var="${MY_VAR}"       # Unsafe with -u: fails if MY_VAR unset
}

# -o pipefail : Detect pipe failures
# grep "pattern" /dev/null | wc -l
# Without pipefail: returns 0 (wc -l succeeded)
# With pipefail:    returns 1 (grep failed → caught!)
```

**How `set -o pipefail` Saves You:**

```bash
# Real-world example: Deployment script
set -o pipefail

# Without pipefail - SILENT FAILURE:
cat /etc/config.txt | grep "DB_HOST" | awk '{print $2}'
# If /etc/config.txt doesn't exist, grep and awk still run
# Result: empty output - you never know the config wasn't read

# With pipefail - CAUGHT IMMEDIATELY:
# Script exits at the cat failure with a non-zero code
```

### 🏷️ Local Variables - Scoping Rules

```bash
GLOBAL_VAR="I am global"

outer_function() {
    local outer_local="outer scope"

    inner_function() {
        local inner_local="inner scope"
        echo "$GLOBAL_VAR"   # ✅ visible (global)
        echo "$outer_local"  # ✅ visible (bash nested scope)
        echo "$inner_local"  # ✅ visible (local)
    }

    inner_function
    echo "$inner_local"  # ❌ empty - inner_local is destroyed
}

outer_function
echo "$outer_local"  # ❌ empty - outer_local is destroyed
echo "$GLOBAL_VAR"   # ✅ still visible
```

---

## Comparison Tables

### Strict Mode Flags Summary

| Flag | Short Form | Trigger Condition | Risk Without It |
|---|---|---|---|
| `set -e` | `errexit` | Any command returns non-zero | Silent failures propagate |
| `set -u` | `nounset` | Access to unset variable | `rm -rf /$TYPO` disaster |
| `set -o pipefail` | - | Any command in pipeline fails | Hidden pipe errors |

### Function Argument Variables

| Variable | Meaning | Example |
|---|---|---|
| `$0` | Script name | `./myscript.sh` |
| `$1` – `$9` | Positional arguments 1–9 | `$1` = first arg |
| `${10}` | Argument 10+ (needs braces) | `${10}` = tenth arg |
| `$#` | Number of arguments | `3` |
| `$@` | All arguments (separate words) | `"arg1" "arg2" "arg3"` |
| `$*` | All arguments (single string) | `"arg1 arg2 arg3"` |
| `$?` | Exit code of last command | `0` = success, `1` = error |

### Local vs Global Variables

| Scenario | Use `local` | Use Global |
|---|---|---|
| Counter inside a loop in a function | ✅ Yes | ❌ No |
| Config file path used across all functions | ❌ No | ✅ Yes |
| Temp variable for string processing | ✅ Yes | ❌ No |
| Logging verbosity flag | ❌ No | ✅ Yes |
| Loop variable `i` | ✅ Yes | ❌ No |

### Bash Functions vs Other Languages

| Feature | Bash | Python | JavaScript |
|---|---|---|---|
| Return a value | `echo` + `$()` | `return value` | `return value` |
| Return status | `return 0-255` | Exceptions | Exceptions / Promise |
| Argument access | `$1, $2, $@` | `def f(a, b)` | `function f(a, b)` |
| Local variables | `local VAR=` | Default local | `let`/`const` |
| Recursive calls | ✅ Supported | ✅ | ✅ |

---

## Key Takeaways

### 🔑 Key Point 1: Functions Make Scripts Maintainable

Without functions, shell scripts become "write-once" files - hard to read, debug, or reuse. Functions give you:
- **DRY (Don't Repeat Yourself)**: write logic once, call it many times
- **Readability**: a `main()` that reads like English
- **Testability**: test each function independently

```bash
# Bad: copy-paste approach
echo "=== DISK ==="
df -h
echo "=== DISK ==="
df -h /var

# Good: function approach
print_disk() { echo "=== DISK ==="; df -h "$1"; }
print_disk /
print_disk /var
```

### 🔑 Key Point 2: `set -euo pipefail` is Non-Negotiable for Production

The default bash behavior is dangerously permissive - it ignores errors, treats undefined variables as empty strings, and hides pipe failures. One bad line in a deployment script can delete data, corrupt state, or silently misconfigure a server.

**Always start your scripts with:**
```bash
#!/bin/bash
set -euo pipefail
```

This one line has saved countless production incidents.

### 🔑 Key Point 3: Always Use `local` Inside Functions

Without `local`, every variable you set inside a function is global. In complex scripts with many functions, this leads to:
- Variables silently overwriting each other
- Functions having side effects the caller doesn't expect
- Debugging nightmares ("where did this variable change?")

**Rule of thumb:** If a variable is only needed inside a function, declare it `local`. Always.

---

## Summary

| Task | Script | Core Concept | Status |
|---|---|---|---|
| Task 1 | `functions.sh` | Writing and calling functions, `$1` args | ✅ |
| Task 2 | `disk_check.sh` | Functions as report generators, `df -h`, `free -h` | ✅ |
| Task 3 | `strict_demo.sh` | `set -euo pipefail` - safer scripting | ✅ |
| Task 4 | `local_demo.sh` | Variable scoping with `local` | ✅ |
| Task 5 | `system_info.sh` | Full script combining all concepts | ✅ |

### What We Built Today

We went from writing flat procedural scripts to structured, function-based scripts that:

1. **Are modular** - each function does one job
2. **Are safe** - strict mode catches bugs early
3. **Are clean** - local variables prevent hidden state
4. **Are readable** - a `main()` function that documents itself

These are the same patterns used in real DevOps scripts at companies like Google, Netflix, and AWS for deployment automation, health checks, and infrastructure management.

---
