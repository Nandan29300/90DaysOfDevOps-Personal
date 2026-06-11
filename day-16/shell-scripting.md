# Day 16 – Shell Scripting Basics

---

## 🔰 What is Shell Scripting?

A **shell script** is a plain text file containing a series of commands that the shell (like Bash) executes line by line - just like you'd type them manually in the terminal, but automated.

Think of it like a **recipe**: instead of doing each cooking step one by one every time, you write all the steps down once and run the recipe whenever you need it.

**Why does it matter in DevOps?**  
Almost every DevOps task - deploying code, checking server health, managing users, backing up data - involves repetitive commands. Shell scripting lets you automate all of that, saving time and reducing human error.

---

## 🧠 The Shebang Line: `#!/bin/bash`

### What is it?

The very first line of every shell script:

```bash
#!/bin/bash
```

This is called the **shebang** (also: hashbang, sharp-bang).

- `#!` → special two-character sequence that tells the OS: "this file is a script"
- `/bin/bash` → the path to the interpreter that should run this script

### Why does it matter?

When you run `./hello.sh`, the OS looks at the first two bytes of the file. If it sees `#!`, it reads the rest of that line to find the interpreter, then hands your script to it.

Without `#!/bin/bash`, the OS either:
- Uses the **default shell** (which might be `sh`, `dash`, or something else - not full Bash)
- Or **fails to run** the script entirely if called via `./hello.sh`

| Scenario | What happens |
|---|---|
| With `#!/bin/bash` | Script runs with Bash - all Bash features work |
| Without shebang, run via `bash hello.sh` | Still works - you're explicitly calling bash |
| Without shebang, run via `./hello.sh` | Risky - OS uses default shell, Bash-specific features may break |

> 💡 **Rule of thumb:** Always include the shebang. It's 14 characters that save you hours of debugging.

---

## ✅ Task 1: Your First Script - `hello.sh`

### The Script

```bash
#!/bin/bash
echo "Hello, DevOps!"
```

### Steps

```bash
# Step 1: Create the file
touch hello.sh

# Step 2: Add the shebang and echo command (use a text editor or nano)
nano hello.sh

# Step 3: Make it executable
chmod +x hello.sh

# Step 4: Run it
./hello.sh
```

### Output

```
Hello, DevOps!
```

### What does `chmod +x` do?

Linux files have **three types of permissions**: read (`r`), write (`w`), execute (`x`).

By default, a newly created text file is **not executable**. If you try `./hello.sh` without `chmod +x`, you get:

```
bash: ./hello.sh: Permission denied
```

`chmod +x` adds the execute permission, telling Linux: "this file is allowed to be run as a program."

### What happens if you remove the shebang?

```bash
# hello.sh without shebang:
echo "Hello, DevOps!"
```

| How you run it | Result |
|---|---|
| `bash hello.sh` | ✅ Works - you're explicitly using bash |
| `./hello.sh` | ⚠️ May work, but uses the system's default shell (often `dash`, not `bash`) |
| `./hello.sh` with bash-only features inside | ❌ Breaks - dash doesn't support all bash syntax |

---

## ✅ Task 2: Variables - `variables.sh`

### The Script

```bash
#!/bin/bash

NAME="Nandan"
ROLE="DevOps Engineer"

echo "Hello, I am $NAME and I am a $ROLE"
```

### Output

```
Hello, I am Nandan and I am a DevOps Engineer
```

### How Variables Work in Bash

**Declaring a variable:**
```bash
NAME="Nandan"
```
⚠️ **No spaces** around the `=` sign. `NAME = "Nandan"` will throw an error - Bash treats `NAME` as a command.

**Using a variable:**
```bash
echo $NAME        # Basic usage
echo "${NAME}"    # Best practice - curly braces avoid ambiguity
```

The `$` sign tells bash: "replace this with the value stored in the variable."

---

### Single Quotes vs Double Quotes - The Key Difference

This is one of the most important distinctions in Bash:

| Quote type | Variable expansion? | Use when |
|---|---|---|
| Double quotes `"..."` | ✅ Yes - `$VAR` gets replaced | You want variables to expand |
| Single quotes `'...'` | ❌ No - everything is literal | You want exact literal text |

**Example:**

```bash
NAME="Nandan"

echo "Hello, $NAME"    # Output: Hello, Nandan
echo 'Hello, $NAME'    # Output: Hello, $NAME
```

Double quotes = "treat `$VAR` as variable"  
Single quotes = "treat everything as plain text, no exceptions"

---

## ✅ Task 3: User Input with `read` - `greet.sh`

### The Script

```bash
#!/bin/bash

read -p "Enter your name: " USER_NAME
read -p "Enter your favourite tool: " FAV_TOOL

echo "Hello $USER_NAME, your favourite tool is $FAV_TOOL"
```

### Sample Interaction

```
Enter your name: Nandan
Enter your favourite tool: Docker
Hello Nandan, your favourite tool is Docker
```

### How `read` Works

```bash
read -p "prompt text" VARIABLE_NAME
```

- `read` → pauses the script and waits for user to type something + press Enter
- `-p` flag → displays a **prompt** message (without a newline before the cursor)
- The value typed is stored in `VARIABLE_NAME`

This is how you make your scripts **interactive** - useful for scripts that need different input each time (like asking which service to restart, or which user to create).

---

## ✅ Task 4: If-Else Conditions

### What is an If-Else?

An `if-else` lets your script **make decisions** - run different code depending on whether a condition is true or false.

Basic syntax:
```bash
if [ condition ]; then
    # runs if condition is TRUE
elif [ another_condition ]; then
    # runs if first was FALSE but this is TRUE
else
    # runs if ALL conditions above were FALSE
fi
```

`fi` is just `if` spelled backwards - it closes the if block.

---

### Script 1: `check_number.sh` - Positive, Negative, or Zero

```bash
#!/bin/bash

read -p "Enter a number: " NUM

if [ $NUM -gt 0 ]; then
    echo "$NUM is Positive"
elif [ $NUM -lt 0 ]; then
    echo "$NUM is Negative"
else
    echo "The number is Zero"
fi
```

### Sample Outputs

```
Enter a number: 42
42 is Positive

Enter a number: -7
-7 is Negative

Enter a number: 0
The number is Zero
```

### Comparison Operators in Bash

| Operator | Meaning | Example |
|---|---|---|
| `-gt` | greater than | `[ $N -gt 0 ]` |
| `-lt` | less than | `[ $N -lt 0 ]` |
| `-eq` | equal to | `[ $N -eq 0 ]` |
| `-ge` | greater than or equal | `[ $N -ge 10 ]` |
| `-le` | less than or equal | `[ $N -le 10 ]` |
| `-ne` | not equal | `[ $N -ne 5 ]` |

> 💡 These are for **numbers**. For strings, use `=` and `!=` inside `[ ]`.

---

### Script 2: `file_check.sh` - Does the File Exist?

```bash
#!/bin/bash

read -p "Enter a filename to check: " FILENAME

if [ -f "$FILENAME" ]; then
    echo "✅ File '$FILENAME' exists."
else
    echo "❌ File '$FILENAME' does NOT exist."
fi
```

### Sample Outputs

```
Enter a filename to check: hello.sh
✅ File 'hello.sh' exists.

Enter a filename to check: ghost.txt
❌ File 'ghost.txt' does NOT exist.
```

### File Test Operators in Bash

| Flag | Checks if... |
|---|---|
| `-f` | it's a **regular file** (exists and is not a directory) |
| `-d` | it's a **directory** |
| `-e` | it **exists** (file or directory) |
| `-r` | it's **readable** |
| `-w` | it's **writable** |
| `-x` | it's **executable** |

> 💡 Always quote your filename variable: `"$FILENAME"` - handles filenames with spaces correctly.

---

## ✅ Task 5: Combine It All - `server_check.sh`

### The Script

```bash
#!/bin/bash

SERVICE="nginx"

echo "Service selected: $SERVICE"
read -p "Do you want to check the status? (y/n): " CHOICE

if [ "$CHOICE" = "y" ]; then
    STATUS=$(systemctl is-active $SERVICE)
    if [ "$STATUS" = "active" ]; then
        echo "✅ $SERVICE is ACTIVE and running."
    else
        echo "❌ $SERVICE is NOT active. Current status: $STATUS"
    fi
elif [ "$CHOICE" = "n" ]; then
    echo "Skipped."
else
    echo "Invalid input. Please enter 'y' or 'n'."
fi
```

### Sample Interaction - Service Running

```
Service selected: nginx
Do you want to check the status? (y/n): y
✅ nginx is ACTIVE and running.
```

### Sample Interaction - Skipped

```
Service selected: nginx
Do you want to check the status? (y/n): n
Skipped.
```

### Key Concepts Used Here

**Command substitution:**
```bash
STATUS=$(systemctl is-active $SERVICE)
```
The `$(...)` syntax runs a command and **captures its output** as a string. Here we store the result of `systemctl is-active nginx` (which outputs `active` or `inactive`) into the `STATUS` variable.

**String comparison:**
```bash
if [ "$STATUS" = "active" ]; then
```
For strings, use `=` (single equals). Always quote the variable to handle empty values safely.

---

## 📚 3 Key Takeaways

**1. The shebang is non-negotiable.**  
`#!/bin/bash` is the first thing every script needs. It tells the OS which interpreter to use and ensures consistent behaviour, especially when Bash-specific syntax is involved.

**2. Quotes control whether variables expand.**  
Double quotes `"..."` allow `$VAR` to be replaced with its value. Single quotes `'...'` treat everything literally. Mix them up and your scripts will behave in unexpected ways.

**3. `[ ]` is the test command - spacing matters.**  
Bash conditions live inside `[ ]`. Spaces around the brackets and inside them are **required** - `[ $N -gt 0 ]` works, `[$N -gt 0]` fails. This trips up almost every beginner at least once.

---

## 📁 File Summary

| File | Purpose |
|---|---|
| `hello.sh` | First script - shebang + echo |
| `variables.sh` | Variable declaration, single vs double quotes |
| `greet.sh` | Interactive user input with `read` |
| `check_number.sh` | If-elif-else with numeric comparisons |
| `file_check.sh` | File existence check with `-f` flag |
| `server_check.sh` | Combined script - variables + read + if-else + command substitution |

---
