# Day 17 – Shell Scripting: Loops, Arguments & Error Handling

---

## Table of Contents

1. [Overview](#overview)
2. [Task 1 – For Loops](#task-1--for-loops)
3. [Task 2 – While Loop](#task-2--while-loop)
4. [Task 3 – Command-Line Arguments](#task-3--command-line-arguments)
5. [Task 4 – Install Packages via Script](#task-4--install-packages-via-script)
6. [Task 5 – Error Handling](#task-5--error-handling)
7. [Concept Comparisons](#concept-comparisons)
8. [Key Takeaways](#key-takeaways)
9. [Summary](#summary)
10. [Quick Reference Cheatsheet](#quick-reference-cheatsheet)

---

## Overview

Shell scripting moves beyond one-liners - today we write **real automation scripts** with:

| Concept | Purpose |
|---|---|
| `for` loop | Iterate over a known list or range |
| `while` loop | Repeat while a condition is true |
| `$1`, `$2`, `$#`, `$@` | Accept and handle CLI arguments |
| `dpkg -s` / `rpm -q` | Check if a package is installed |
| `set -e`, `\|\|` | Gracefully handle errors |

---

## Task 1 – For Loops

### What is a `for` loop?

A `for` loop iterates over a **list of items** (words, numbers, files, etc.) and runs a block of commands for each item.

**Syntax:**
```bash
for variable in item1 item2 item3; do
    # commands using $variable
done
```

---

### Script 1: `for_loop.sh` - Iterate over fruits

```bash
#!/bin/bash
# for_loop.sh
# Loops through a list of 5 fruits and prints each one

fruits=("Apple" "Banana" "Cherry" "Mango" "Grapes")

echo "🍎 My Fruit List:"
echo "-------------------"

for fruit in "${fruits[@]}"; do
    echo "  -> $fruit"
done

echo "-------------------"
echo "Total fruits: ${#fruits[@]}"
```

**Expected Output:**
```
🍎 My Fruit List:
-------------------
  -> Apple
  -> Banana
  -> Cherry
  -> Mango
  -> Grapes
-------------------
Total fruits: 5
```

**What's happening here:**
- `fruits=(...)` creates an **array**
- `"${fruits[@]}"` expands to all array elements (the quotes prevent word-splitting issues)
- `${#fruits[@]}` gives the **length** of the array

---

### Script 2: `count.sh` - Print numbers 1 to 10

```bash
#!/bin/bash
# count.sh
# Prints numbers 1 to 10 using a for loop

echo "Counting from 1 to 10:"

# Method 1: Using brace expansion (most common)
for i in {1..10}; do
    echo "  Number: $i"
done

echo ""
echo "Counting in steps of 2 (bonus):"

# Method 2: C-style for loop
for ((i=1; i<=10; i+=2)); do
    echo "  Odd: $i"
done
```

**Expected Output:**
```
Counting from 1 to 10:
  Number: 1
  Number: 2
  Number: 3
  Number: 4
  Number: 5
  Number: 6
  Number: 7
  Number: 8
  Number: 9
  Number: 10

Counting in steps of 2 (bonus):
  Odd: 1
  Odd: 3
  Odd: 5
  Odd: 7
  Odd: 9
```

**Two styles of `for` loop compared:**

| Style | Syntax | Best for |
|---|---|---|
| List/Range | `for i in {1..10}` | Simple ranges and lists |
| C-style | `for ((i=0; i<10; i++))` | Complex increment logic |
| File glob | `for f in *.sh` | Iterating over files |

---

## Task 2 – While Loop

### What is a `while` loop?

A `while` loop runs **as long as a condition is true**. It's ideal when you don't know how many iterations you need upfront.

**Syntax:**
```bash
while [ condition ]; do
    # commands
done
```

---

### Script: `countdown.sh` - Countdown timer

```bash
#!/bin/bash
# countdown.sh
# Accepts a number and counts down to 0

# Check if argument was provided
if [ -z "$1" ]; then
    echo "Usage: ./countdown.sh <number>"
    echo "Example: ./countdown.sh 5"
    exit 1
fi

# Validate it's a positive integer
if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Error: Please provide a positive integer."
    exit 1
fi

count=$1

echo "🚀 Starting countdown from $count..."
echo ""

while [ $count -ge 0 ]; do
    echo "  ⏱  $count"
    sleep 1
    ((count--))
done

echo ""
echo "✅ Done!"
```

**Expected Output (with input `5`):**
```
🚀 Starting countdown from 5...

  ⏱  5
  ⏱  4
  ⏱  3
  ⏱  2
  ⏱  1
  ⏱  0

✅ Done!
```

**Key concepts used:**

| Operator | Meaning |
|---|---|
| `-ge` | Greater than or equal to (numeric) |
| `-z` | True if string is empty |
| `=~` | Regex match operator |
| `((count--))` | Arithmetic decrement |
| `sleep 1` | Pause for 1 second |

**`for` vs `while` - when to use which:**

| Scenario | Use |
|---|---|
| Known number of iterations | `for` |
| Unknown iterations (wait for condition) | `while` |
| Reading lines from a file | `while read` |
| Countdown / polling | `while` |

---

## Task 3 – Command-Line Arguments

### What are CLI arguments?

When you run a script like `./greet.sh John`, the shell passes `John` as an **argument** your script can read.

| Variable | Meaning |
|---|---|
| `$0` | Script name itself |
| `$1` | First argument |
| `$2` | Second argument |
| `$#` | Total number of arguments |
| `$@` | All arguments (as separate words) |
| `$*` | All arguments (as one string) |
| `$?` | Exit status of last command |

---

### Script 1: `greet.sh` - Greet by name

```bash
#!/bin/bash
# greet.sh
# Accepts a name as $1 and prints a greeting

if [ $# -eq 0 ]; then
    echo "Usage: ./greet.sh <name>"
    echo "Example: ./greet.sh Alice"
    exit 1
fi

name=$1
echo "Hello, $name! 👋"
echo "Welcome to Day 17 of #90DaysOfDevOps!"
```

**Run examples:**
```bash
# With argument
$ ./greet.sh Alice
Hello, Alice! 👋
Welcome to Day 17 of #90DaysOfDevOps!

# Without argument
$ ./greet.sh
Usage: ./greet.sh <name>
Example: ./greet.sh Alice
```

**Multiple name support (bonus):**
```bash
# Greet multiple people
for name in "$@"; do
    echo "Hello, $name!"
done
```

---

### Script 2: `args_demo.sh` - Explore all argument variables

```bash
#!/bin/bash
# args_demo.sh
# Demonstrates $0, $#, $@, $1, $2 etc.

echo "========================================="
echo "       ARGUMENT DEMO SCRIPT"
echo "========================================="
echo ""
echo "Script name    : $0"
echo "Total args     : $#"
echo "All args (\$@)  : $@"
echo ""

if [ $# -eq 0 ]; then
    echo "⚠️  No arguments passed. Try:"
    echo "   ./args_demo.sh one two three"
    exit 0
fi

echo "Individual arguments:"
echo "-----------------------------------------"

counter=1
for arg in "$@"; do
    echo "  \$$counter = $arg"
    ((counter++))
done

echo ""
echo "Loop using \$@:"
for arg in "$@"; do
    echo "  -> Processing: $arg"
done
```

**Run with 3 arguments:**
```bash
$ ./args_demo.sh DevOps Linux Bash
=========================================
       ARGUMENT DEMO SCRIPT
=========================================

Script name    : ./args_demo.sh
Total args     : 3
All args ($@)  : DevOps Linux Bash

Individual arguments:
-----------------------------------------
  $1 = DevOps
  $2 = Linux
  $3 = Bash

Loop using $@:
  -> Processing: DevOps
  -> Processing: Linux
  -> Processing: Bash
```

**`$@` vs `$*` - The Important Difference:**

```bash
args=("hello world" "foo")

# $@ treats each quoted arg separately (CORRECT)
for a in "$@"; do echo "$a"; done
# Output:
# hello world
# foo

# $* merges everything into one string (RISKY)
for a in "$*"; do echo "$a"; done
# Output:
# hello world foo
```

> Always prefer `"$@"` over `"$*"` to preserve argument boundaries.

---

## Task 4 – Install Packages via Script

### Script: `install_packages.sh` - Smart package installer

```bash
#!/bin/bash
# install_packages.sh
# Checks and installs packages if missing
# Must be run as root

# ─── Root Check ──────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
    echo "❌ Error: This script must be run as root."
    echo "   Try: sudo bash install_packages.sh"
    exit 1
fi

# ─── Package List ────────────────────────────────────────
packages=("nginx" "curl" "wget")

echo "========================================"
echo "   📦 Package Installation Script"
echo "========================================"
echo ""

# ─── Detect Package Manager ──────────────────────────────
if command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt-get"
    CHECK_CMD="dpkg -s"
    echo "📌 Using APT package manager (Debian/Ubuntu)"
elif command -v yum &>/dev/null; then
    PKG_MANAGER="yum"
    CHECK_CMD="rpm -q"
    echo "📌 Using YUM package manager (RHEL/CentOS)"
elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
    CHECK_CMD="rpm -q"
    echo "📌 Using DNF package manager (Fedora)"
else
    echo "❌ Unsupported package manager. Exiting."
    exit 1
fi

echo ""

# ─── Loop and Install ────────────────────────────────────
for pkg in "${packages[@]}"; do
    echo -n "  Checking $pkg ... "

    if $CHECK_CMD "$pkg" &>/dev/null; then
        echo "✅ Already installed. Skipping."
    else
        echo "❌ Not found. Installing..."
        if $PKG_MANAGER install -y "$pkg" &>/dev/null; then
            echo "  ✅ $pkg installed successfully!"
        else
            echo "  ⚠️  Failed to install $pkg. Please check manually."
        fi
    fi
done

echo ""
echo "========================================"
echo "   ✅ Package check complete!"
echo "========================================"
```

**Expected Output (run as root on Ubuntu):**
```
========================================
   📦 Package Installation Script
========================================

📌 Using APT package manager (Debian/Ubuntu)

  Checking nginx ... ❌ Not found. Installing...
  ✅ nginx installed successfully!
  Checking curl ... ✅ Already installed. Skipping.
  Checking wget ... ✅ Already installed. Skipping.

========================================
   ✅ Package check complete!
========================================
```

**Root check explained:**

```bash
if [ "$EUID" -ne 0 ]; then
```

| Variable | Meaning |
|---|---|
| `$EUID` | Effective User ID (root = 0) |
| `-ne 0` | Not equal to 0 (not root) |

**Alternative root check using `whoami`:**
```bash
if [ "$(whoami)" != "root" ]; then
    echo "Run as root!"
    exit 1
fi
```

---

## Task 5 – Error Handling

### Why error handling matters

Without error handling, a script keeps running even after a failure - potentially making things **worse** (deleting files, overwriting configs, etc.).

**Two key tools:**

| Tool | What it does |
|---|---|
| `set -e` | Exit immediately if any command fails |
| `set -u` | Treat unset variables as errors |
| `set -o pipefail` | Catch errors in piped commands |
| `\|\|` | Run right side only if left side FAILS |
| `&&` | Run right side only if left side SUCCEEDS |
| `trap` | Run cleanup code on exit/error |

---

### Script 1: `safe_script.sh` - Safe directory and file creation

```bash
#!/bin/bash
# safe_script.sh
# Demonstrates set -e and || error handling

# Exit on any error
set -e
# Treat unset variables as errors
set -u
# Catch errors in pipelines
set -o pipefail

TARGET_DIR="/tmp/devops-test"
TARGET_FILE="hello.txt"

echo "========================================"
echo "  🛡️  Safe Script Demo"
echo "========================================"
echo ""

# Step 1: Create directory (won't fail if exists, thanks to ||)
echo "📁 Step 1: Creating directory $TARGET_DIR ..."
mkdir "$TARGET_DIR" || echo "⚠️  Directory already exists - continuing."

# Step 2: Navigate into it
echo "📂 Step 2: Navigating into $TARGET_DIR ..."
cd "$TARGET_DIR" || { echo "❌ Failed to enter directory. Exiting."; exit 1; }

echo "   Currently in: $(pwd)"

# Step 3: Create a file
echo "📄 Step 3: Creating $TARGET_FILE ..."
echo "Hello from Day 17 - DevOps Scripting!" > "$TARGET_FILE" || { echo "❌ Failed to create file."; exit 1; }

echo "   File created: $(ls -lh $TARGET_FILE)"

# Step 4: Read it back
echo ""
echo "📖 File contents:"
echo "---"
cat "$TARGET_FILE"
echo "---"

echo ""
echo "✅ All steps completed successfully!"
```

**First run output:**
```
========================================
  🛡️  Safe Script Demo
========================================

📁 Step 1: Creating directory /tmp/devops-test ...
📂 Step 2: Navigating into /tmp/devops-test ...
   Currently in: /tmp/devops-test
📄 Step 3: Creating hello.txt ...
   File created: -rw-r--r-- 1 root root 39 Jun 12 10:00 hello.txt

📖 File contents:
---
Hello from Day 17 - DevOps Scripting!
---

✅ All steps completed successfully!
```

**Second run output (directory already exists):**
```
📁 Step 1: Creating directory /tmp/devops-test ...
⚠️  Directory already exists - continuing.
📂 Step 2: Navigating into /tmp/devops-test ...
   Currently in: /tmp/devops-test
...
```

---

### Error Handling Patterns - Reference

```bash
# Pattern 1: || (OR) – run if LEFT fails
mkdir /tmp/test || echo "Already exists"

# Pattern 2: && (AND) – run if LEFT succeeds
mkdir /tmp/test && echo "Created successfully"

# Pattern 3: { } block – multi-command fallback
mkdir /tmp/test || { echo "Failed"; exit 1; }

# Pattern 4: trap – cleanup on exit
trap "rm -f /tmp/lockfile; echo 'Cleaned up'" EXIT

# Pattern 5: if + command
if ! mkdir /tmp/test; then
    echo "mkdir failed!"
    exit 1
fi
```

---

### `set -e` behavior example:

```bash
#!/bin/bash
set -e

echo "Step 1: OK"
ls /nonexistent_path   # This FAILS → script stops here
echo "Step 2: Never reached"
```

Output:
```
Step 1: OK
ls: cannot access '/nonexistent_path': No such file or directory
```
> Without `set -e`, "Step 2" would print, hiding the error.

---

## Concept Comparisons

### Loop Comparison

| Feature | `for` loop | `while` loop |
|---|---|---|
| Iteration type | Over a list/range | While condition is true |
| Iterations known? | Yes | Not necessarily |
| Best use case | Arrays, ranges, files | Countdown, polling, user input |
| Syntax complexity | Simple | Slightly more setup |
| Risk of infinite loop | Low | Higher (if condition never false) |

---

### Argument Variables

| Variable | Example value | Description |
|---|---|---|
| `$0` | `./myscript.sh` | Script name |
| `$1` | `Alice` | First argument |
| `$2` | `30` | Second argument |
| `$#` | `2` | Number of arguments |
| `$@` | `Alice 30` | All args (separate) |
| `$*` | `Alice 30` | All args (joined) |
| `$?` | `0` | Exit code of last command |
| `$$` | `12345` | Current script's PID |

---

### Error Handling Approaches

| Method | Exit on error? | Verbosity | Use case |
|---|---|---|---|
| `set -e` | Yes (automatic) | Silent | Safety net for whole script |
| `\|\|` | Optional | Custom message | Per-command fallback |
| `if ! cmd` | Optional | Full control | Complex conditional logic |
| `trap` | On exit/signal | Custom | Cleanup / logging |
| `exit 1` | Yes (manual) | Custom | Explicit failure point |

---

## Key Takeaways

1. **Loops are the backbone of automation** - `for` loops iterate over known lists (packages, files, servers), while `while` loops handle dynamic conditions like waiting for a service or counting down.

2. **Always validate arguments and user input** - Use `$#`, `-z`, and regex checks (`=~`) before proceeding. A script that crashes on bad input is a script that breaks in production.

3. **Error handling is not optional in real scripts** - Combining `set -e`, `||` fallbacks, and root checks (`$EUID`) transforms a fragile script into a reliable automation tool. Always ask: *what happens if this step fails?*

---

## Summary

| Task | Script | Core Concept |
|---|---|---|
| Task 1a | `for_loop.sh` | `for item in list` iteration |
| Task 1b | `count.sh` | `{1..10}` range expansion |
| Task 2 | `countdown.sh` | `while [ $n -ge 0 ]` with decrement |
| Task 3a | `greet.sh` | `$1` argument + usage guard |
| Task 3b | `args_demo.sh` | `$0`, `$#`, `$@` exploration |
| Task 4 | `install_packages.sh` | Loop + `dpkg -s` + root check |
| Task 5 | `safe_script.sh` | `set -e`, `||`, error messages |

**Shell scripting skills unlocked today:**
- Writing `for` and `while` loops with arrays and ranges
- Accepting, validating, and using command-line arguments
- Detecting OS/package manager and installing packages safely
- Defensive scripting with `set -e`, `||`, root checks, and exit codes

---

## Quick Reference Cheatsheet

```bash
# ── FOR LOOPS ────────────────────────────────────────────
for item in a b c; do echo $item; done          # list
for i in {1..10}; do echo $i; done              # range
for ((i=0; i<5; i++)); do echo $i; done         # C-style
for f in *.sh; do echo $f; done                 # files

# ── WHILE LOOPS ──────────────────────────────────────────
while [ $n -gt 0 ]; do ((n--)); done            # countdown
while read line; do echo $line; done < file     # read file

# ── ARGUMENTS ────────────────────────────────────────────
$0    # script name
$1    # first arg
$#    # count of args
$@    # all args (safe, quoted)
${1:-"default"}  # default value if $1 empty

# ── ERROR HANDLING ───────────────────────────────────────
set -euo pipefail                               # strict mode
cmd || echo "cmd failed"                        # fallback
cmd && echo "cmd worked"                        # on success
cmd || { echo "fail"; exit 1; }                 # exit on fail
trap "cleanup" EXIT                             # cleanup hook

# ── CHECKS ───────────────────────────────────────────────
[ "$EUID" -ne 0 ] && echo "Not root" && exit 1
[ -z "$1" ] && echo "No arg" && exit 1
[ -d "/path" ] && echo "Dir exists"
[ -f "/path" ] && echo "File exists"
dpkg -s pkg &>/dev/null && echo "Installed"
```

---

*Day 17 Complete ✅ | #90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham*
