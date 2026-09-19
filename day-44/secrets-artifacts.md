# Day 44 – Secrets, Artifacts & Running Real Tests in CI

## Challenge Tasks

### Task 1: GitHub Secrets

1. Created a repository secret named `MY_SECRET_MESSAGE` under **Settings → Secrets and variables → Actions**.
2. Created a workflow that checks whether the secret is available without exposing its value.
3. Verified the output:

```text
The secret is set: true
```

4. Also tested printing `${{ secrets.MY_SECRET_MESSAGE }}` directly. GitHub Actions masks secret values in workflow logs, so the actual value is replaced with `***` when GitHub recognizes it as a secret.

**Why should secrets never be printed in CI logs?**

- CI logs can be accessed by people with permission to view the repository or workflow runs.
- Secrets may contain API keys, passwords, access tokens, or other sensitive credentials.
- Accidentally exposing a credential can allow unauthorized access to external services.
- Even though GitHub masks registered secrets in many situations, secrets should never be intentionally written to logs.

[Secrets Workflow](workflows/secrets.yml)

---

### Task 2: Use Secrets as Environment Variables

1. Passed the secret to a workflow step through an environment variable.
2. Used the environment variable inside a shell command without hardcoding the secret.
3. Added the following secrets for use in the upcoming Docker workflow:

- `DOCKER_USERNAME`
- `DOCKER_TOKEN`

Example approach:

```yaml
env:
  MY_SECRET_MESSAGE: ${{ secrets.MY_SECRET_MESSAGE }}
```

The workflow accesses the value through the environment variable instead of placing the secret directly in the source code.

[Docker Secrets Workflow](workflows/docker-secrets.yml)

---

### Task 3: Upload Artifacts

1. Created a file during the workflow execution.
2. Used `actions/upload-artifact@v4` to upload the generated file.
3. Opened the completed workflow run from the **Actions** tab.
4. Verified that the artifact was available for download.

**Verification:**  
Yes. The generated artifact was visible in the workflow run and could be downloaded successfully.

[Upload Artifact Workflow](workflows/upload-artifact.yml)

---

### Task 4: Download Artifacts Between Jobs

Created a workflow with two jobs:

- **Job 1:** Generates a file and uploads it as an artifact.
- **Job 2:** Downloads the artifact using `actions/download-artifact@v4` and reads its contents.

This demonstrates how artifacts can pass files between independent jobs running on different GitHub-hosted runners.

[Artifact Between Jobs Workflow](workflows/artifact-between-jobs.yml)

**When would artifacts be useful in a real CI/CD pipeline?**

Artifacts are useful when a pipeline needs to preserve or transfer files generated during a workflow, such as:

- Build packages
- Test reports
- Coverage reports
- Application logs
- Compiled binaries
- Deployment packages

For example, one job can build an application, upload the build output as an artifact, and a later deployment job can download that artifact and deploy the exact same build.

---

### Task 5: Run Real Tests in CI

Used a script from an earlier DevOps exercise and integrated it into GitHub Actions.

The workflow:

1. Checks out the repository using `actions/checkout`.
2. Sets up the required runtime.
3. Installs the required dependencies.
4. Executes the test/script.
5. Relies on the script's exit code to determine whether the job succeeds or fails.

A successful execution produced a green workflow run.

I also intentionally introduced an error into the script to verify failure handling. The workflow failed and showed a red status. After fixing the script, I ran it again and confirmed that the workflow returned to a successful green status.

[Test Workflow](workflows/test.yml)

---

### Task 6: Caching

Added `actions/cache@v4` to cache dependencies used by the workflow.

The cache is based on the dependency files and is restored on subsequent workflow runs when the cache key matches.

**What is being cached?**

The workflow caches downloaded package/dependency files so that GitHub Actions does not need to download the same dependencies again when a matching cache is available.

**Where is it stored?**

The cache is managed by GitHub Actions and restored onto the runner when the workflow executes. For a Python/pip workflow, the cached files can be restored to the pip cache directory such as:

```text
~/.cache/pip
```

The first run may need to populate the cache, while later runs can restore it and potentially reduce dependency installation time.

[Cache Workflow](workflows/cache.yml)

---

## What I Learned

### GitHub Actions Secrets

- Sensitive values should be stored in GitHub Actions Secrets instead of source code.
- Secrets can be injected into workflows at runtime.
- Environment variables provide a convenient way to pass secrets to individual steps.
- Secret values should never be intentionally printed in CI logs.
- GitHub Actions masks recognized secret values in logs, but masking should not be treated as permission to expose secrets.

### Artifacts

- Artifacts allow files generated during a workflow to be stored after a job finishes.
- Artifacts can be downloaded from completed workflow runs.
- Artifacts can also be used to transfer build outputs, reports, or other files between jobs.
- Uploading an artifact in one job and downloading it in another is useful for separating build, test, and deployment stages.

### CI Testing

- A CI workflow can execute real project scripts instead of only running simple demonstration commands.
- The process exit code determines whether a command succeeds or fails.
- A non-zero exit code causes the workflow step/job to fail unless failure is explicitly handled.
- Testing both a broken and fixed version helps verify that CI is actually detecting failures.

### Caching

- Dependency caching can reduce repeated downloads in CI.
- Cache keys determine when an existing cache can be restored.
- A cache miss populates a new cache, while a cache hit can reuse previously stored dependencies.
- Caching is useful for improving workflow execution time, but it should not be used to hide reproducibility problems.

---

## Day 44 Summary

Day 44 moved the GitHub Actions workflows from basic automation toward a more realistic CI pipeline.

I learned how to securely handle secrets, generate and transfer artifacts between jobs, execute real tests, intentionally verify CI failures, and cache dependencies to improve repeated workflow runs.

These concepts form an important foundation for building more complete CI/CD pipelines in the upcoming days.
