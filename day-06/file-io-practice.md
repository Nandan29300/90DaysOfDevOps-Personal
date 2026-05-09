# Day 06 – File I/O Practice

**Date:** 09-05-2026

**Topic:** Read and Write Text Files

**Goal:** Practice basic file operations using fundamental Linux commands

---

## Overview

Today's focus is on mastering basic file operations that every DevOps engineer uses daily. You'll learn to create, write, read, and manipulate text files using essential Linux commands.

---

## What I Did Today

Today I practiced creating, writing, appending, and reading text files using basic Linux commands. These are the building blocks for working with logs, configs, and scripts in DevOps.

---

## Step-by-Step Commands I Ran

### Step 1: Create an Empty File

```bash
touch notes.txt
```

**What it did:** Creates a new empty file called `notes.txt`. If the file already exists, it just updates the timestamp - it did NOT delete the content.

**Verify it was created:**
```bash
ls -l notes.txt
```

**Output:**
```
-rw-r--r-- 1 user user 0 May 09 11:15 notes.txt
```

---

### Step 2: Write the First Line (Overwrite with `>`)

```bash
echo "Day 06: Learning Linux File I/O" > notes.txt
```

**What it did:** The `>` operator sends the output of `echo` into `notes.txt`.
- If the file is empty, it writes fresh content.
- If the file already has content, it **overwrites** it completely. we should be very careful!

**Verify:**
```bash
cat notes.txt
```

**Output:**
```
Day 06: Learning Linux File I/O
```

---

### Step 3: Append the Second Line (Append with `>>`)

```bash
echo "Command: cat - displays full file content" >> notes.txt
```

**What it did:** The `>>` operator **appends** to the file - it adds a new line at the end without touching what's already there.

**Verify:**
```bash
cat notes.txt
```

**Output:**
```
Day 06: Learning Linux File I/O
Command: cat - displays full file content
```

---

### Step 4: Append the Third Line

```bash
echo "Command: head - shows first N lines" >> notes.txt
```

**What it did:** Same as Step 3 - appends another line at the bottom.

**Verify:**
```bash
cat notes.txt
```

**Output:**
```
Day 06: Learning Linux File I/O
Command: cat - displays full file content
Command: head - shows first N lines
```

---

### Step 5: Use `tee` to Write and Display at the Same Time

```bash
echo "Command: tail - shows last N lines" | tee -a notes.txt
```

**What it did:**
- `echo` sends the text to `tee` via a pipe (`|`)
- `tee` did two things simultaneously:
  1. **Displays** the text in the terminal (stdout)
  2. **Writes** it to `notes.txt`
- The `-a` flag means append (without `-a`, tee would overwrite the file)

**Terminal Output:**
```
Command: tail - shows last N lines
```

*(It also gets written to the file at the same time)*

**Verify:**
```bash
cat notes.txt
```

**Output:**
```
Day 06: Learning Linux File I/O
Command: cat - displays full file content
Command: head - shows first N lines
Command: tail - shows last N lines
```

---

### Step 6: Add Multiple Lines Using Here Document (`<<EOF`)

```bash
cat <<EOF >> notes.txt
Command: tee - writes and displays simultaneously
Redirection: > overwrites file
Redirection: >> appends to file
These commands are essential for DevOps
EOF
```

**What it did:** A Here Document (heredoc) lets you write multiple lines at once without repeating `echo` for each line.
- Everything between `<<EOF` and the closing `EOF` gets treated as input
- `>>` appends all of it to `notes.txt`

**Verify:**
```bash
cat notes.txt
```

**Output:**
```
Day 06: Learning Linux File I/O
Command: cat - displays full file content
Command: head - shows first N lines
Command: tail - shows last N lines
Command: tee - writes and displays simultaneously
Redirection: > overwrites file
Redirection: >> appends to file
These commands are essential for DevOps
```

---

### Step 7: Read the Full File with Line Numbers

```bash
cat -n notes.txt
```

**What it did:** `cat -n` displays the file content with line numbers on the left - useful when you want to reference specific lines.

**Output:**
```
     1  Day 06: Learning Linux File I/O
     2  Command: cat - displays full file content
     3  Command: head - shows first N lines
     4  Command: tail - shows last N lines
     5  Command: tee - writes and displays simultaneously
     6  Redirection: > overwrites file
     7  Redirection: >> appends to file
     8  These commands are essential for DevOps
```

---

### Step 8: Read Only the First 3 Lines Using `head`

```bash
head -n 3 notes.txt
```

**What it did:** `head` shows the beginning of a file. `-n 3` means "show me the first 3 lines only."

**Output:**
```
Day 06: Learning Linux File I/O
Command: cat - displays full file content
Command: head - shows first N lines
```

---

### Step 9: Read Only the Last 3 Lines Using `tail`

```bash
tail -n 3 notes.txt
```

**What it did:** `tail` shows the end of a file. `-n 3` means "show me the last 3 lines only." In real DevOps work, `tail -f` is used to monitor live log files in real time and -f means follow live lines if they get added.

**Output:**
```
Redirection: > overwrites file
Redirection: >> appends to file
These commands are essential for DevOps
```

---

### Step 10. Search Text Using `grep`

```bash
cat notes.txt | grep head
```

**What it did:**  Filters and shows lines containing the word **head**.

---

## Key Differences to Remember

| Operator / Command | Behaviour |
|---|---|
| `>` | **Overwrites** the file - old content is gone |
| `>>` | **Appends** to the file - old content is safe |
| `cat` | Shows the **entire** file |
| `head -n N` | Shows only the **first** N lines |
| `tail -n N` | Shows only the **last** N lines |
| `tail -f ....` | Shows live lines whenver they get added, useful for logs |
| `tee -a` | Writes to file **and** shows on screen at the same time |
| `<<EOF ..... EOF` | Lets you input **multiple lines** in a single command, without writing **echo** in each line |

---

## Final File Contents (`notes.txt`)

```
Day 06: Learning Linux File I/O
Command: cat - displays full file content
Command: head - shows first N lines
Command: tail - shows last N lines
Command: tee - writes and displays simultaneously
Redirection: > overwrites file
Redirection: >> appends to file
These commands are essential for DevOps
```

---

## Why This Matters for DevOps

Every day in DevOps you deal with text files:

- **Logs** - reading error logs with `cat`, `tail -f`, `grep`
- **Config files** - writing values into `.yml`, `.conf`, `.env` files
- **Scripts** - creating and editing shell scripts
- **CI/CD** - writing build outputs and reading deployment files

Mastering `>`, `>>`, `cat`, `head`, `tail`, and `tee` means you can handle all of these quickly without opening a text editor - which is especially important when you're SSH'd into a remote server.

---
