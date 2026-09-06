# Day 41 – Triggers & Matrix Builds – Explanations

## Overview

GitHub Actions workflows do not have to run only when code is pushed.

GitHub Actions provides different triggers that allow a workflow to run when specific events happen, at scheduled times, or manually.

This Day 41 challenge covers:

1. Pull Request triggers
2. Scheduled triggers
3. Manual triggers
4. Matrix builds
5. Matrix `exclude` and `fail-fast`

---

# Task 1: Trigger on Pull Request

## What is a Pull Request trigger?

A Pull Request (PR) trigger runs a GitHub Actions workflow when activity happens on a pull request.

For this task, the workflow should run when:

- A PR is opened
- New commits are pushed to the PR branch (`synchronize`)
- The PR targets the `main` branch

## Workflow syntax

```yaml
on:
  pull_request:
    branches:
      - main
    types:
      - opened
      - synchronize
```

### Important fields

### `pull_request`

Tells GitHub Actions that the workflow should respond to Pull Request events.

### `branches`

```yaml
branches:
  - main
```

Limits the trigger to PRs whose target/base branch is `main`.

### `types`

```yaml
types:
  - opened
  - synchronize
```

`opened` runs when a new PR is created.

`synchronize` runs when new commits are pushed to the branch associated with the PR.

## Getting the PR branch name

The workflow uses:

```yaml
${{ github.head_ref }}
```

This gives the name of the source branch of the pull request.

For example, if the PR is:

```text
feature/day-41 → main
```

then:

```text
github.head_ref
```

returns:

```text
feature/day-41
```

## Why PR checks are useful

PR workflows are commonly used for:

- Running tests
- Linting
- Building applications
- Checking code quality
- Running security checks

This helps catch problems before changes are merged into the main branch.

---

# Task 2: Scheduled Trigger

## What is a scheduled trigger?

A scheduled trigger runs a workflow automatically according to a cron schedule.

Example:

```yaml
on:
  schedule:
    - cron: '0 0 * * *'
```

This runs the workflow every day at:

```text
00:00 UTC
```

## Understanding cron

GitHub Actions uses the standard five-field cron format:

```text
minute hour day-of-month month day-of-week
```

The five fields are:

```text
┌──── minute (0 - 59)
│ ┌── hour (0 - 23)
│ │ ┌ day of month (1 - 31)
│ │ │ ┌ month (1 - 12)
│ │ │ │ ┌ day of week (0 - 6)
│ │ │ │ │
* * * * *
```

## Midnight every day

```text
0 0 * * *
```

Meaning:

- Minute = `0`
- Hour = `0`
- Every day of month = `*`
- Every month = `*`
- Every day of week = `*`

Therefore:

```text
Every day at 00:00 UTC
```

## Monday at 9 AM

The cron expression is:

```text
0 9 * * 1
```

Meaning:

```text
0    → minute 0
9    → hour 9
*    → every day of month
*    → every month
1    → Monday
```

Therefore:

```text
Every Monday at 09:00 UTC
```

## Important point

GitHub Actions scheduled workflows use **UTC**, so always consider the UTC-to-local-time difference when creating schedules.

## Common uses

Scheduled workflows can be useful for:

- Daily reports
- Dependency checks
- Automated maintenance
- Periodic tests
- Cleanup jobs
- Data synchronization

---

# Task 3: Manual Trigger

## What is a manual trigger?

A manual trigger allows a user to start a workflow from the GitHub Actions interface.

The trigger is:

```yaml
on:
  workflow_dispatch:
```

## Adding inputs

Inputs can be added to collect information when the workflow is manually started.

Example:

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: "Enter the environment name"
        required: true
        type: string
```

When clicking:

```text
Actions → Workflow → Run workflow
```

GitHub shows an input field.

For example:

```text
environment: staging
```

or:

```text
environment: production
```

## Reading the input

The value can be accessed using:

```yaml
${{ inputs.environment }}
```

Example:

```yaml
- name: Print environment
  run: echo "Selected environment: ${{ inputs.environment }}"
```

## Why manual triggers are useful

Manual workflows are useful when an action should happen only when someone explicitly requests it.

Examples:

- Deploying to production
- Running a database migration
- Creating a release
- Running maintenance
- Executing an emergency operation

---

# Task 4: Matrix Builds

## What is a matrix strategy?

A matrix allows the same job to run multiple times with different combinations of configuration values.

Example:

```yaml
strategy:
  matrix:
    python-version:
      - "3.10"
      - "3.11"
      - "3.12"
```

This creates three jobs.

Conceptually:

```text
Python 3.10 → Job 1
Python 3.11 → Job 2
Python 3.12 → Job 3
```

The jobs can run independently and, when runners are available, in parallel.

## Using the matrix value

The current matrix value is accessed with:

```yaml
${{ matrix.python-version }}
```

For example:

```yaml
uses: actions/setup-python@v5
with:
  python-version: ${{ matrix.python-version }}
```

## Why use matrix builds?

Instead of creating separate jobs manually:

```text
test-python-310
test-python-311
test-python-312
```

we can define one job and let GitHub Actions generate the combinations.

This makes workflows:

- Shorter
- Easier to maintain
- Easier to extend
- Better for compatibility testing

---

# Extending the Matrix to Operating Systems

We can add an operating-system dimension:

```yaml
strategy:
  matrix:
    os:
      - ubuntu-latest
      - windows-latest

    python-version:
      - "3.10"
      - "3.11"
      - "3.12"
```

Then:

```yaml
runs-on: ${{ matrix.os }}
```

GitHub creates every possible combination.

There are:

```text
2 operating systems
×
3 Python versions
=
6 jobs
```

The combinations are:

| Operating System | Python |
|---|---|
| Ubuntu | 3.10 |
| Ubuntu | 3.11 |
| Ubuntu | 3.12 |
| Windows | 3.10 |
| Windows | 3.11 |
| Windows | 3.12 |

This is one of the biggest advantages of matrix builds: adding another configuration dimension automatically creates the required combinations.

---

# Task 5: Exclude & Fail-Fast

## Matrix `exclude`

Sometimes a particular combination is not required or should not be tested.

For example:

```yaml
exclude:
  - os: windows-latest
    python-version: "3.10"
```

This removes:

```text
Windows + Python 3.10
```

from the generated matrix.

## Number of jobs after exclusion

Before exclusion:

```text
2 OS × 3 Python versions = 6 jobs
```

After excluding one combination:

```text
6 - 1 = 5 jobs
```

So five jobs will run.

---

# `fail-fast`

The `fail-fast` setting controls what happens to other matrix jobs when one matrix job fails.

## `fail-fast: true`

This is the default.

```yaml
strategy:
  fail-fast: true
```

If one matrix job fails, GitHub Actions cancels other in-progress matrix jobs.

This can save time and resources when a failure means the remaining combinations are no longer useful.

Example:

```text
Ubuntu 3.10   → Running
Ubuntu 3.11   → ❌ Failed
Ubuntu 3.12   → Cancelled
Windows 3.11  → Cancelled
Windows 3.12  → Cancelled
```

The exact cancellation behavior can depend on the timing of jobs, but the important point is that GitHub attempts to cancel the remaining in-progress matrix jobs.

## `fail-fast: false`

```yaml
strategy:
  fail-fast: false
```

If one matrix job fails, the other matrix jobs are allowed to continue.

Example:

```text
Ubuntu 3.10   → ✅ Passed
Ubuntu 3.11   → ❌ Failed
Ubuntu 3.12   → ✅ Passed
Windows 3.11  → ❌ Failed
Windows 3.12  → ✅ Passed
```

This is useful when you want a complete picture of how every matrix combination behaves.

---

# Intentional Failure for Testing

For this challenge, an intentional failure can be created with:

```yaml
- name: Trigger intentional failure
  if: matrix.python-version == '3.11'
  run: |
    echo "Intentional failure for testing fail-fast"
    exit 1
```

The command:

```text
exit 1
```

returns a non-zero exit status, which GitHub Actions treats as a failed step.

Because the condition checks for Python 3.11, the Python 3.11 matrix jobs fail.

With:

```yaml
fail-fast: false
```

the other matrix combinations continue running.

---

# Complete Day 41 Concepts

## 1. Pull Request Trigger

```yaml
on:
  pull_request:
    branches:
      - main
    types:
      - opened
      - synchronize
```

Runs workflows when specified PR events happen.

---

## 2. Schedule Trigger

```yaml
on:
  schedule:
    - cron: '0 0 * * *'
```

Runs automatically according to a cron schedule.

---

## 3. Manual Trigger

```yaml
on:
  workflow_dispatch:
```

Allows a workflow to be started manually.

Inputs can be provided using:

```yaml
workflow_dispatch:
  inputs:
```

---

## 4. Matrix Strategy

```yaml
strategy:
  matrix:
    python-version:
      - "3.10"
      - "3.11"
      - "3.12"
```

Runs the same job with multiple configurations.

---

## 5. Matrix Dimensions

```yaml
matrix:
  os:
    - ubuntu-latest
    - windows-latest

  python-version:
    - "3.10"
    - "3.11"
    - "3.12"
```

Creates:

```text
2 × 3 = 6 combinations
```

---

## 6. Matrix Exclude

```yaml
exclude:
  - os: windows-latest
    python-version: "3.10"
```

Removes a specific combination.

---

## 7. Fail-Fast

```yaml
fail-fast: false
```

Allows other matrix jobs to continue even when one fails.

Default:

```yaml
fail-fast: true
```

Attempts to cancel remaining in-progress matrix jobs when a matrix job fails.

---

# Quick Revision

| Concept | Syntax | Purpose |
|---|---|---|
| Pull Request | `pull_request` | Run workflow for PR events |
| Schedule | `schedule` | Run workflow automatically on a schedule |
| Manual | `workflow_dispatch` | Run workflow manually |
| Matrix | `strategy.matrix` | Run jobs across multiple configurations |
| Exclude | `matrix.exclude` | Remove specific combinations |
| Fail-Fast | `fail-fast` | Control behavior after a matrix failure |

## Important Values to Remember

### Every day at midnight UTC

```text
0 0 * * *
```

### Every Monday at 9 AM UTC

```text
0 9 * * 1
```

### Three Python versions

```text
3.10, 3.11, 3.12
```

### Two operating systems

```text
ubuntu-latest
windows-latest
```

### Total combinations

```text
3 Python versions × 2 operating systems = 6
```

### After excluding one combination

```text
6 - 1 = 5 jobs
```

### Default fail-fast

```text
true
```

### Continue all matrix jobs after failure

```yaml
fail-fast: false
```

---

# Key Takeaway

Day 41 demonstrates that GitHub Actions workflows can be triggered in several different ways:

```text
Pull Request
     ↓
Scheduled Time
     ↓
Manual Request
     ↓
Matrix Configurations
     ↓
Exclude / Fail-Fast Control
```

Understanding these features makes workflows much more flexible. Instead of running only on every push, a CI/CD pipeline can respond to pull requests, execute periodic jobs, be manually triggered when needed, and test the same application across multiple environments automatically.
