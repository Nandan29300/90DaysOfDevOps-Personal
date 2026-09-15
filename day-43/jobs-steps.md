# Day 43 – Jobs, Steps, Env Vars & Conditionals

Today I learned how to control the flow of GitHub Actions workflows using multiple jobs, job dependencies, environment variables, job outputs, and conditionals.

---

## Challenge Tasks

## Task 1: Multi-Job Workflow

### Objective

Create a workflow with three jobs:

- `build` - prints `Building the app`
- `test` - prints `Running tests`
- `deploy` - prints `Deploying`

The `test` job must run only after `build` succeeds, and the `deploy` job must run only after `test` succeeds.

### Workflow file

File: `.github/workflows/multi-job.yml`

```yaml
name: Multi Job Workflow

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Build application
        run: echo "Building the app"

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Run tests
        run: echo "Running tests"

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy application
        run: echo "Deploying"
```

### Explanation

The `needs:` keyword creates a dependency between jobs.

```yaml
test:
  needs: build
```

This means the `test` job starts only after the `build` job completes successfully.

```yaml
deploy:
  needs: test
```

This means the `deploy` job starts only after the `test` job completes successfully.

### Execution order

```text
build
  |
  v
test
  |
  v
deploy
```

### Verification

I checked the workflow in the GitHub Actions tab and verified that the jobs follow the dependency chain.

![Task 1 workflow graph](images/task1.png)

Workflow file:

[Multi Job Workflow](workflows/multi-job.yml)

### Key learning

`needs:` tells GitHub Actions which job must finish successfully before another job can start.

---

## Task 2: Environment Variables

### Objective

Use environment variables at three different levels:

1. Workflow level - `APP_NAME: myapp`
2. Job level - `ENVIRONMENT: staging`
3. Step level - `VERSION: 1.0.0`

Also print the commit SHA and the actor who triggered the workflow.

### Workflow file

File: `.github/workflows/env-vars.yml`

```yaml
name: Environment Variables

on:
  workflow_dispatch:

env:
  APP_NAME: myapp

jobs:
  show-environment:
    runs-on: ubuntu-latest

    env:
      ENVIRONMENT: staging

    steps:
      - name: Print environment variables
        env:
          VERSION: 1.0.0
        run: |
          echo "Application: $APP_NAME"
          echo "Environment: $ENVIRONMENT"
          echo "Version: $VERSION"
          echo "Commit SHA: $GITHUB_SHA"
          echo "Triggered by: $GITHUB_ACTOR"
```

### Explanation

#### Workflow-level variable

```yaml
env:
  APP_NAME: myapp
```

This variable is available to all jobs and steps in the workflow unless it is overridden.

#### Job-level variable

```yaml
env:
  ENVIRONMENT: staging
```

This variable is available to all steps inside that job.

#### Step-level variable

```yaml
env:
  VERSION: 1.0.0
```

This variable is available only inside that step.

#### GitHub context variables

```bash
echo "Commit SHA: $GITHUB_SHA"
echo "Triggered by: $GITHUB_ACTOR"
```

- `GITHUB_SHA` contains the commit SHA associated with the workflow run.
- `GITHUB_ACTOR` contains the username of the person or account that triggered the workflow.

### Verification

I verified that all three environment variables and the GitHub context variables were printed successfully.

![Task 2 environment variables](images/task2.png)

![Task 2 output](images/task2.1.png)

---

## Task 3: Job Outputs

### Objective

Create one job that generates a value and exposes it as an output. Create another job that reads the output using:

```yaml
needs.<job>.outputs.<name>
```

### Workflow file

File: `.github/workflows/jobs-outputs.yml`

```yaml
name: Job Outputs

on:
  workflow_dispatch:

jobs:
  generate-date:
    runs-on: ubuntu-latest

    outputs:
      date: ${{ steps.set-date.outputs.date }}

    steps:
      - name: Set today's date
        id: set-date
        run: echo "date=$(date)" >> "$GITHUB_OUTPUT"

  display-date:
    needs: generate-date
    runs-on: ubuntu-latest

    steps:
      - name: Display generated date
        run: echo "The date from the previous job is ${{ needs.generate-date.outputs.date }}"
```

### Explanation

The first job creates an output:

```yaml
outputs:
  date: ${{ steps.set-date.outputs.date }}
```

The step creates the value using:

```bash
echo "date=$(date)" >> "$GITHUB_OUTPUT"
```

The step has an ID:

```yaml
id: set-date
```

The second job reads the output using:

```yaml
${{ needs.generate-date.outputs.date }}
```

### Why pass outputs between jobs?

Each job runs independently, usually on a separate runner. Files and shell variables created in one job are not automatically available in another job.

Job outputs allow one job to pass important information to a later job.

### Example: Docker image pipeline

- **Job 1 - Build image**
  - Builds a Docker image.
  - Creates an image tag such as `myapp:1.0.0`.

- **Job 2 - Push image**
  - Reads the image tag from Job 1.
  - Pushes the correct image to a container registry.

- **Job 3 - Deploy application**
  - Reads the same image tag.
  - Deploys the exact image that was built and pushed.

### Key learning

Job outputs are useful for passing values such as image tags, version numbers, generated dates, artifact names, and deployment information between jobs.

### Verification

![Task 3 output creation](images/task3.png)

![Task 3 output consumption](images/task3.1.png)

Workflow file:

[Job Outputs Workflow](workflows/jobs-outputs.yml)

---

## Task 4: Conditionals

### Objective

Create a workflow that demonstrates:

1. A step that runs only on the `main` branch.
2. A step that runs only when the previous step fails.
3. A job that runs only for push events.
4. A step using `continue-on-error: true`.

### Workflow file

File: `.github/workflows/conditionals.yml`

```yaml
name: Conditionals

on:
  push:
  pull_request:
  workflow_dispatch:

jobs:
  conditional-steps:
    runs-on: ubuntu-latest

    steps:
      - name: Run on main branch only
        if: github.ref == 'refs/heads/main'
        run: echo "This step runs only on main"

      - name: Intentionally fail
        id: failing-step
        continue-on-error: true
        run: |
          echo "This step will fail"
          exit 1

      - name: Run after failure
        if: steps.failing-step.outcome == 'failure'
        run: echo "The previous step failed"

      - name: Continue after an error
        continue-on-error: true
        run: |
          echo "This step is allowed to fail"
          exit 1

      - name: Final step
        run: echo "The workflow continues"

  push-only-job:
    if: github.event_name == 'push'
    runs-on: ubuntu-latest

    steps:
      - name: Run only on push
        run: echo "This job runs only for push events"
```

### Explanation: Main branch condition

```yaml
if: github.ref == 'refs/heads/main'
```

This step runs only when the workflow is running for the `main` branch.

### Explanation: Previous step failed

```yaml
if: steps.failing-step.outcome == 'failure'
```

The step checks the outcome of the earlier step using its ID.

### Explanation: Push-only job

```yaml
if: github.event_name == 'push'
```

This job runs only when the event that triggered the workflow is a push. It does not run for pull request events.

### Explanation: continue-on-error

```yaml
continue-on-error: true
```

This allows a step or job to fail without causing the workflow to stop immediately.

The workflow can continue executing later steps or jobs. The failure is still visible in the workflow results.

### Important note

`continue-on-error: true` does not make the command succeed. It allows the workflow to continue even though the command failed.

### Verification

![Task 4 main branch condition](images/task4.1.png)

![Task 4 failed step condition](images/task4.2.png)

![Task 4 push-only job](images/task4.3.png)

![Task 4 continue-on-error](images/task4.4.png)

Workflow file:

[Conditionals Workflow](workflows/conditionals.yml)

---

## Task 5: Putting It Together

### Objective

Create a smart pipeline that:

1. Triggers on pushes to any branch.
2. Runs `lint` and `test` jobs in parallel.
3. Runs a `summary` job after both jobs finish.
4. Prints whether the run is for `main` or a feature branch.
5. Prints the commit message.

### Workflow file

File: `.github/workflows/smart-pipeline.yml`

```yaml
name: Smart Pipeline

on:
  push:

jobs:
  lint:
    runs-on: ubuntu-latest

    steps:
      - name: Run lint checks
        run: echo "Running lint checks"

  test:
    runs-on: ubuntu-latest

    steps:
      - name: Run tests
        run: echo "Running tests"

  summary:
    needs: [lint, test]
    runs-on: ubuntu-latest

    steps:
      - name: Identify branch type
        run: |
          if [ "$GITHUB_REF" = "refs/heads/main" ]; then
            echo "This is a main branch push"
          else
            echo "This is a feature branch push"
          fi

      - name: Print commit message
        run: echo "Commit message: ${{ github.event.head_commit.message }}"
```

### Explanation

#### Push trigger

```yaml
on:
  push:
```

The workflow runs when code is pushed to any branch.

#### Parallel jobs

The `lint` and `test` jobs do not depend on each other, so GitHub Actions can run them in parallel.

```text
       lint
      /     \
     /       \
    v         v
          summary
    ^         ^
     \       /
      \     /
       test
```

A simpler representation is:

```text
lint  --------\
               ---> summary
test  --------/
```

#### Summary dependency

```yaml
needs: [lint, test]
```

The `summary` job waits until both `lint` and `test` finish successfully.

#### Branch detection

```bash
if [ "$GITHUB_REF" = "refs/heads/main" ]; then
```

This checks whether the current branch is `main`. If not, the workflow treats it as a feature branch for this exercise.

#### Commit message

```yaml
${{ github.event.head_commit.message }}
```

This reads the commit message from the push event payload.

### Verification

![Task 5 workflow](images/task5.png)

![Lint job](images/lint-test.png)

![Test job](images/test.png)

![Summary job](images/summary.png)

Workflow file:

[Smart Pipeline Workflow](workflows/smart-pipeline.yml)

---

## Key Concepts Learned

### Jobs

A job is a group of steps that runs on a runner.

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
```

Different jobs are isolated from each other unless data is explicitly passed between them.

### Steps

A step is an individual task inside a job.

```yaml
steps:
  - name: Print message
    run: echo "Hello GitHub Actions"
```

Steps in the same job execute sequentially by default.

### needs

The `needs:` keyword defines job dependencies.

```yaml
test:
  needs: build
```

The `test` job waits for `build` to complete successfully.

Multiple dependencies can be defined:

```yaml
summary:
  needs: [lint, test]
```

### Environment variables

Environment variables can be defined at workflow, job, or step level.

```yaml
env:
  APP_NAME: myapp
```

More specific levels override broader levels when the same variable name is used.

### Job outputs

Job outputs allow values to be passed from one job to another.

```yaml
outputs:
  version: ${{ steps.version-step.outputs.version }}
```

The receiving job can read the value with:

```yaml
${{ needs.build.outputs.version }}
```

### Conditionals

Conditions control when jobs or steps run.

```yaml
if: github.ref == 'refs/heads/main'
```

A condition can use GitHub context values, step outcomes, and event information.

### continue-on-error

```yaml
continue-on-error: true
```

This allows the workflow to continue after a step or job fails.

---

## Final Summary

In Day 43, I learned how to control GitHub Actions workflow execution.

The main concepts were:

- Creating multi-job workflows.
- Connecting jobs using `needs:`.
- Running independent jobs in parallel.
- Using workflow-level, job-level, and step-level environment variables.
- Accessing GitHub context variables such as commit SHA and actor.
- Creating and consuming job outputs.
- Running steps conditionally.
- Detecting push events and branch names.
- Using `continue-on-error: true`.
- Creating a smart pipeline with parallel jobs and a final summary job.

These concepts are important for building real CI/CD pipelines where build, test, security scanning, artifact creation, and deployment jobs must run in a controlled order.
