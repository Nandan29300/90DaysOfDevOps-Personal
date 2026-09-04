# Day 40 – First GitHub Actions Workflow

## Objective

Today I created my first GitHub Actions CI workflow and learned how GitHub runs automated jobs in the cloud whenever code is pushed to a repository.

---

## 1. Repository Setup

Repository:

`github-actions-practice`

The repository should be **public**.

### Local folder structure

Starting from the Day 40 directory, the structure should look like this:

```text
day-40/
├── README.md
└── github-actions-practice/
    ├── .github/
    │   └── workflows/
    │       └── hello.yml
    └── day-40-first-workflow.md
```

> If `day-40-first-workflow.md` is kept in the repository itself, use the structure above. This file is the documentation required for the challenge.

### Create the repository and clone it

On GitHub, create a new public repository named:

```text
github-actions-practice
```

Then locally:

```bash
cd ~/path/to/90DaysOfDevOps-Personal/day-40

git clone https://github.com/<YOUR_USERNAME>/github-actions-practice.git

cd github-actions-practice

mkdir -p .github/workflows

touch .github/workflows/hello.yml
```

Replace `<YOUR_USERNAME>` with the GitHub username.

---

# 2. Task 2 – Hello Workflow

Create:

```text
.github/workflows/hello.yml
```

Use this initial workflow:

```yaml
name: Hello GitHub Actions

on:
  push:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Check out code
        uses: actions/checkout@v4

      - name: Print greeting
        run: echo "Hello from GitHub Actions!"
```

## What this does

- `name` gives the workflow a readable name.
- `on: push` means every push to the repository triggers the workflow.
- `jobs` defines the work GitHub Actions has to perform.
- `greet` is the job ID.
- `runs-on: ubuntu-latest` tells GitHub to run the job on an Ubuntu runner.
- `steps` contains the individual actions/commands.
- `uses: actions/checkout@v4` checks the repository code out onto the runner.
- `run:` executes a shell command.
- The second step prints:

```text
Hello from GitHub Actions!
```

---

# 3. Push the First Workflow

Check the files:

```bash
git status
```

Then:

```bash
git add .
git commit -m "Add first GitHub Actions workflow"
git push
```

After pushing:

1. Open the GitHub repository.
2. Go to the **Actions** tab.
3. Open **Hello GitHub Actions**.
4. Open the latest workflow run.
5. Click the `greet` job.
6. Read both steps.
7. Confirm that the workflow is **green**.

### Expected flow

```text
Push
  ↓
GitHub receives commit
  ↓
GitHub Actions starts workflow
  ↓
greet job
  ↓
Ubuntu runner
  ↓
Checkout code
  ↓
Print greeting
  ↓
Success ✓
```

---

# 4. Task 3 – Understand the Anatomy

## `on:`

Defines **when the workflow should run**.

Example:

```yaml
on:
  push:
```

This means the workflow runs whenever a push happens.

---

## `jobs:`

Defines the jobs that GitHub Actions needs to execute.

Example:

```yaml
jobs:
  greet:
```

Here, there is one job called `greet`.

---

## `runs-on:`

Defines the operating-system environment where the job runs.

Example:

```yaml
runs-on: ubuntu-latest
```

The job runs on a GitHub-hosted Ubuntu runner.

---

## `steps:`

Defines the individual steps inside a job.

Example:

```yaml
steps:
  - name: Check out code
    uses: actions/checkout@v4

  - name: Print greeting
    run: echo "Hello from GitHub Actions!"
```

Steps execute in order.

---

## `uses:`

Uses an existing GitHub Action instead of writing the functionality ourselves.

Example:

```yaml
uses: actions/checkout@v4
```

This uses the official checkout action to make the repository's code available on the runner.

---

## `run:`

Runs a shell command on the runner.

Example:

```yaml
run: echo "Hello from GitHub Actions!"
```

It is useful for commands such as:

```bash
echo
pwd
ls
date
uname
```

---

## `name:` on a step

Gives a step a readable name.

Example:

```yaml
- name: Print greeting
  run: echo "Hello from GitHub Actions!"
```

The name appears in the Actions UI, making the logs easier to understand.

---

# 5. Task 4 – Add More Steps

Now update `.github/workflows/hello.yml`.

Use:

```yaml
name: Hello GitHub Actions

on:
  push:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Check out code
        uses: actions/checkout@v4

      - name: Print greeting
        run: echo "Hello from GitHub Actions!"

      - name: Print current date and time
        run: date

      - name: Print branch name
        run: echo "Branch: ${{ github.ref_name }}"

      - name: List repository files
        run: ls -la

      - name: Print runner operating system
        run: echo "Operating system: $RUNNER_OS"
```

## New concepts

### Current date and time

```yaml
run: date
```

The runner executes the Linux `date` command.

### Branch name

```yaml
run: echo "Branch: ${{ github.ref_name }}"
```

`${{ github.ref_name }}` is a GitHub Actions context value containing the branch or tag name that triggered the workflow.

For example:

```text
Branch: main
```

### List files

```yaml
run: ls -la
```

This displays files and directories in the repository.

### Runner operating system

```yaml
run: echo "Operating system: $RUNNER_OS"
```

`RUNNER_OS` is an environment variable provided by GitHub Actions.

For an Ubuntu runner, it should print:

```text
Operating system: Linux
```

---

## Push the changes

```bash
git add .github/workflows/hello.yml
git commit -m "Add workflow information steps"
git push
```

Go back to:

**GitHub → Actions → Hello GitHub Actions**

A new run should appear automatically.

Open the run and inspect **every step and its logs**.

---

# 6. Task 5 – Break the Pipeline on Purpose

Now intentionally make one step fail.

For example, temporarily add:

```yaml
      - name: Intentionally fail
        run: exit 1
```

A complete section might look like:

```yaml
      - name: List repository files
        run: ls -la

      - name: Intentionally fail
        run: exit 1

      - name: Print runner operating system
        run: echo "Operating system: $RUNNER_OS"
```

Commit and push:

```bash
git add .github/workflows/hello.yml
git commit -m "Test failed GitHub Actions workflow"
git push
```

---

## What should happen?

The workflow should become **red / failed**.

The `exit 1` command returns a non-zero exit status, which tells GitHub Actions that the step failed.

The steps after the failure normally do not execute.

The Actions UI will show the failed step and its logs.

### How to read the failure

Open:

**Actions → failed workflow run → greet → failed step**

Look for:

```text
Process completed with exit code 1.
```

The important things to inspect are:

1. Which job failed?
2. Which step failed?
3. What command was running?
4. What error/output was produced?
5. What exit code was returned?

---

# 7. Fix the Pipeline

Remove the intentional failure step:

```yaml
      - name: Intentionally fail
        run: exit 1
```

The final workflow should be:

```yaml
name: Hello GitHub Actions

on:
  push:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Check out code
        uses: actions/checkout@v4

      - name: Print greeting
        run: echo "Hello from GitHub Actions!"

      - name: Print current date and time
        run: date

      - name: Print branch name
        run: echo "Branch: ${{ github.ref_name }}"

      - name: List repository files
        run: ls -la

      - name: Print runner operating system
        run: echo "Operating system: $RUNNER_OS"
```

Push the fix:

```bash
git add .github/workflows/hello.yml
git commit -m "Fix GitHub Actions workflow"
git push
```

The latest workflow run should become **green**.

---

# 8. Final Workflow

This is the final version of `.github/workflows/hello.yml`:

```yaml
name: Hello GitHub Actions

on:
  push:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Check out code
        uses: actions/checkout@v4

      - name: Print greeting
        run: echo "Hello from GitHub Actions!"

      - name: Print current date and time
        run: date

      - name: Print branch name
        run: echo "Branch: ${{ github.ref_name }}"

      - name: List repository files
        run: ls -la

      - name: Print runner operating system
        run: echo "Operating system: $RUNNER_OS"
```

---

# 9. What I Learned

Today I learned that GitHub Actions can automatically execute commands when changes are pushed to a repository.

The basic structure is:

```text
Workflow
   │
   └── Job
        │
        ├── Step
        ├── Step
        ├── Step
        └── Step
```

I learned:

- Workflows are stored in `.github/workflows/`.
- Workflow files use YAML.
- `on:` controls when a workflow runs.
- `jobs:` defines the work to perform.
- `runs-on:` selects the runner environment.
- `steps:` defines commands/actions executed by a job.
- `uses:` allows existing GitHub Actions to be reused.
- `run:` executes shell commands.
- GitHub provides useful contexts and environment variables.
- Every push can automatically trigger a workflow.
- A non-zero exit code can make a workflow fail.
- The Actions UI provides logs for debugging failed steps.
- 
---

```markdown
![Day 40 - Green GitHub Actions Run](./day-40-green-run.png)
```

---
