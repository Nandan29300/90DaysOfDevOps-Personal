# Day 39 – CI/CD Concepts

## What is CI/CD?

CI/CD stands for **Continuous Integration** and **Continuous Delivery/Deployment**.

CI/CD is a software development practice used to automate the process of integrating code, testing it, building applications, and delivering or deploying them.

The main goal is to make software changes **smaller, faster, safer, and more repeatable** instead of relying on developers to manually perform every step.

CI/CD is a **practice**, not a specific tool.

Examples of tools that implement CI/CD include:

- GitHub Actions
- Jenkins
- GitLab CI/CD
- CircleCI
- Azure DevOps

---

# Task 1 – The Problem

## Scenario

Imagine a team of 5 developers working on the same application.

Each developer writes code on their own machine, pushes changes to a shared repository, and the team manually deploys the application to production.

As the number of developers and changes increases, many problems appear.

## 1. What can go wrong?

Several things can go wrong with completely manual development and deployment:

### Merge conflicts

Two developers may modify the same files or parts of the application, resulting in merge conflicts.

### Broken code

A developer may push code that works locally but breaks another part of the application.

### Bugs reach production

If tests are performed manually or inconsistently, bugs can easily make it into production.

### Human error

Manual deployment involves many commands and steps. A developer could:

- Run the wrong command
- Deploy the wrong version
- Forget a configuration step
- Deploy to the wrong server
- Forget to run tests
- Use the wrong environment variables

### Inconsistent environments

Developers may have different operating systems, dependencies, library versions, or configurations.

### Slow deployments

If every deployment requires someone to manually build, test, copy files, configure servers, and restart services, deployments become slow.

### Difficult rollback

If a deployment breaks production, manually identifying and restoring the previous working version can take time.

---

## 2. What does "It works on my machine" mean?

"It works on my machine" means that an application works correctly in one developer's local environment but fails in another environment such as testing, staging, or production.

This can happen because environments have differences such as:

- Operating system
- Programming language version
- Package/library versions
- Environment variables
- Configuration files
- Database versions
- System dependencies
- Docker/runtime configuration

### Example

Developer A may have:

```text
Node.js 22
Express 5
Ubuntu
```

while the staging server might have:

```text
Node.js 20
Different package versions
Different environment variables
```

The same application may therefore behave differently.

Automation and tools such as Docker and CI/CD help reduce these differences.

---

## 3. How many times a day can a team safely deploy manually?

There is no universal fixed number.

A team could theoretically perform several manual deployments per day, but the more frequently deployments are performed manually, the greater the risk of:

- Human mistakes
- Missed tests
- Configuration errors
- Inconsistent deployment steps
- Deployment fatigue

The important point is:

> The goal is not simply to deploy many times per day. The goal is to make every deployment repeatable, tested, and reliable.

---

# Task 2 – CI vs CD

## 1. Continuous Integration (CI)

**Continuous Integration** means frequently integrating developers' code changes into a shared repository and automatically validating those changes.

Whenever code is pushed or a pull request is created, the CI system can automatically run checks such as building the application, running tests, linting, and static analysis.

### Real-world example

A developer pushes a change to GitHub.

GitHub Actions automatically:

1. Checks out the code
2. Sets up the required runtime
3. Installs dependencies
4. Runs automated tests
5. Reports whether the change passes or fails

If the tests fail, the team knows about the problem before the code is deployed.

---

## 2. Continuous Delivery

**Continuous Delivery** means keeping the application in a state where it is always ready to be released.

CI validates the code, while Continuous Delivery extends the process by automatically building and preparing the application for release.

The production release usually requires a **manual approval or decision**.

### Real-world example

A company pushes a new version of its web application.

The pipeline automatically:

- Runs tests
- Builds the application
- Creates a Docker image
- Deploys it to staging
- Runs additional checks

The application is ready for production, but a developer or release manager approves the production deployment.

---

## 3. Continuous Deployment

**Continuous Deployment** goes one step further than Continuous Delivery.

With Continuous Deployment, every change that successfully passes the automated pipeline is automatically deployed to production without requiring manual approval.

### Real-world example

A developer pushes a small feature to the main branch.

The pipeline:

1. Runs automated tests
2. Builds the application
3. Creates a Docker image
4. Deploys it
5. Runs deployment checks
6. Automatically releases it to production

No human needs to manually click a production deployment button.

---

## CI vs Continuous Delivery vs Continuous Deployment

| Concept | Main idea | Production deployment |
|---|---|---|
| Continuous Integration | Integrate and automatically test code | Not the main purpose |
| Continuous Delivery | Automatically prepare software for release | Usually requires manual approval |
| Continuous Deployment | Automatically release every successful change | Fully automatic |

A simple mental model:

```text
CI = Build + Test

Continuous Delivery = Build + Test + Prepare for Release

Continuous Deployment = Build + Test + Automatically Release
```

---

# Task 3 – Pipeline Anatomy

## 1. Trigger

A **trigger** is the event that starts the pipeline.

Common triggers include:

- Git push
- Pull request
- Merge to a branch
- Scheduled execution
- Manual execution
- Release/tag creation

Example:

```text
Developer pushes code
        ↓
     Trigger
        ↓
Pipeline starts
```

---

## 2. Stage

A **stage** is a logical phase of the pipeline.

Common stages include:

- Test
- Build
- Package
- Deploy

Example:

```text
Stage 1 → Test
Stage 2 → Build
Stage 3 → Deploy
```

---

## 3. Job

A **job** is a unit of work inside a stage.

A stage can contain one or more jobs.

Example:

```text
Test Stage
├── Unit Tests
├── Integration Tests
└── Security Scan
```

Jobs may run sequentially or in parallel depending on the CI/CD system.

---

## 4. Step

A **step** is a single command or action inside a job.

Example:

```text
Job: Run Tests

Steps:
1. Checkout code
2. Install dependencies
3. Run tests
4. Generate test report
```

A step is smaller than a job.

---

## 5. Runner

A **runner** is the machine or execution environment that executes a job.

It could be:

- A virtual machine
- A physical machine
- A container
- A self-hosted server

Example:

```text
GitHub
   ↓
GitHub Actions Runner
   ↓
Executes the job
```

---

## 6. Artifact

An **artifact** is an output produced by a job that can be stored or passed to later stages.

Examples include:

- Compiled binaries
- Test reports
- Build packages
- Docker image references
- Application bundles
- Logs

Example:

```text
Build Job
    ↓
Docker Image
    ↓
Artifact
    ↓
Deploy Job
```

---

# Task 4 – Pipeline Diagram

## Scenario

> A developer pushes code to GitHub. The app is tested, built into a Docker image, and deployed to a staging server.

I created the pipeline diagram in **draw.io / app.diagrams.net** as a separate `cicd-pipeline.drawio` file.

The architecture is:

```text
Developer
    │
    │ git push
    ▼
GitHub Repository
    │
    │ Trigger
    ▼
Stage 1: Test
    │
    ├── Test failure ──► STOP
    │
    │ tests pass
    ▼
Stage 2: Build
    │
    ├── Build failure ─► STOP
    │
    │ Docker image
    ▼
Stage 3: Deploy
    │
    ├── Deploy failure ─► STOP / ALERT
    │
    ▼
Staging Server
    │
    ▼
Application Running
```

### Detailed pipeline

```text
Developer
    ↓
git push
    ↓
GitHub Repository
    ↓
Trigger
    ↓
┌──────────────────────────┐
│ Stage 1: TEST             │
│                           │
│ Checkout code             │
│ Install dependencies      │
│ Run unit/integration tests│
└────────────┬─────────────┘
             │
       ┌─────┴─────┐
       │           │
      FAIL        PASS
       │           │
       ▼           ▼
      STOP    Stage 2: BUILD
                   │
                   │ Build Docker image
                   │ Tag image
                   ▼
             ┌───────────────┐
             │ Docker Image  │
             └───────┬───────┘
                     │
                     ▼
             Stage 3: DEPLOY
                     │
                     │ Pull image
                     │ Start container
                     ▼
               Staging Server
                     │
                     ▼
              Application
```

### Why failures are important

A failed pipeline is not necessarily a problem with CI/CD.

For example:

```text
Code Push
   ↓
Test
   ↓
FAIL
   ↓
Pipeline stops
   ↓
Developer fixes the issue
   ↓
Push again
   ↓
Test
   ↓
PASS
```

The pipeline has done its job by preventing a broken change from moving further.

---

# Task 5 – Explore in the Wild

## Repository Selected

For this task, I explored the **golang-migrate/migrate** open-source repository.

Repository:

`golang-migrate/migrate`

Workflow:

`.github/workflows/ci.yaml`

The workflow is a good example because it uses multiple jobs for linting, testing, and checking coverage.

## Workflow YAML

A simplified view of the workflow structure is:

```yaml
name: CI

on:
  push:
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - checkout
      - setup Go
      - run golangci-lint

  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        go: ["1.25.x", "1.26.x"]
    steps:
      - checkout
      - setup Go
      - run tests

  check-coverage:
    needs: [test]
```

## 1. What triggers it?

The workflow is triggered by:

- `push`
- `pull_request`

So when code is pushed or a pull request is created/updated, GitHub Actions can start this CI workflow.

## 2. How many jobs does it have?

The workflow contains multiple jobs, including:

- `lint`
- `test`
- `check-coverage`

The `test` job also uses a Go version matrix, so the tests can run against multiple Go versions.

## 3. What does it do?

At a high level, the workflow:

```text
GitHub Event
     ↓
     CI
     ↓
 ┌─────────────┐
 │    Lint     │
 └─────────────┘
     ↓
 ┌─────────────┐
 │    Tests    │
 │ Go 1.25     │
 │ Go 1.26     │
 └─────────────┘
     ↓
 ┌─────────────────┐
 │ Check Coverage  │
 └─────────────────┘
```

The workflow therefore demonstrates an important CI concept: different jobs can perform different validations, and some jobs can depend on previous jobs.

Source: `golang-migrate/migrate/.github/workflows/ci.yaml`

---

# Why CI/CD Matters

Without CI/CD, a team may have a process like:

```text
Developer
    ↓
Write Code
    ↓
Manually Test
    ↓
Manually Build
    ↓
Manually Copy Files
    ↓
Manually Deploy
    ↓
Hope Everything Works
```

This process is highly dependent on people remembering every step.

With CI/CD:

```text
Developer
    ↓
Push Code
    ↓
Automatic Pipeline
    ↓
Build
    ↓
Test
    ↓
Package
    ↓
Deploy
    ↓
Application
```

The process becomes repeatable and easier to trust.

---

# Important Takeaways

## 1. CI/CD is a practice

CI/CD is not itself a tool.

Tools such as GitHub Actions, Jenkins, GitLab CI/CD, and CircleCI provide systems for implementing CI/CD practices.

## 2. CI catches problems early

The earlier a problem is discovered, the easier it is to fix.

```text
Code
 ↓
CI
 ↓
Test fails
 ↓
Developer fixes it
```

## 3. Automation reduces human error

If deployment requires many manual commands, there are many opportunities to make mistakes.

A pipeline can perform the same process consistently every time.

## 4. A failed pipeline is useful

A pipeline failure can prevent broken code from moving to the next stage.

```text
Developer
    ↓
Push Code
    ↓
CI
    ↓
Test Failed
    ↓
Pipeline Stops
    ↓
Developer Fixes Bug
    ↓
Push Again
    ↓
CI Passes
```

## 5. CI/CD enables smaller and safer changes

Instead of combining many changes and deploying them manually, teams can integrate and release smaller changes more frequently.

Smaller changes are generally easier to:

- Test
- Review
- Debug
- Deploy
- Roll back

---

# Final Mental Model

The simplest way I understand CI/CD after Day 39 is:

```text
Developer
    │
    │ Push Code
    ▼
GitHub
    │
    │ Trigger
    ▼
┌───────────────┐
│ CI            │
│ Build + Test  │
└───────┬───────┘
        │
        ▼
┌────────────────────┐
│ Delivery            │
│ Prepare for Release │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ Deployment          │
│ Release to Users    │
└────────────────────┘
```

### In one sentence

> **CI/CD is the practice of automatically validating, building, packaging, delivering, and sometimes deploying software changes so that software can be released faster, more consistently, and with less manual error.**

---

# References

- GitHub Actions documentation
- `golang-migrate/migrate` GitHub repository
- `.github/workflows/ci.yaml` from `golang-migrate/migrate`
