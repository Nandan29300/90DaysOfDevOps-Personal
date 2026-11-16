# Day 49 - DevSecOps: Add Security to Your CI/CD Pipeline

## Project
**Repository:** `github-actions-capstone`  
**Application:** Node.js + Express  
**Container base image:** `REPLACE_WITH_THE_FROM_LINE_IN_DOCKERFILE`

## 1. What is DevSecOps?

DevSecOps means building security checks into the software development and delivery process instead of waiting until after deployment. Security checks run automatically alongside builds and tests, helping us find vulnerable dependencies, insecure container images, and accidentally exposed secrets earlier.

## 2. Key principles

1. **Catch problems early:** Find security issues during pull requests and builds.
2. **Automate checks:** Run repeatable security scans in CI/CD.
3. **Block serious issues:** Fail a pipeline when configured severity thresholds are exceeded.
4. **Protect secrets:** Store credentials in GitHub Secrets and prevent accidental commits.
5. **Use least privilege:** Give each workflow only the permissions it needs.

---

## 3. Task 1 - Scan the Docker image with Trivy

Trivy scans the built container image for known vulnerabilities (CVEs). The pipeline should run the scan **after the image is built but before it is pushed or deployed**.

Recommended sequence:

1. Build the image locally without pushing it.
2. Scan the local image with Trivy.
3. Push the image only if the scan succeeds.
4. Continue to deployment only if the Docker workflow succeeds.

Use the `CRITICAL,HIGH` severity threshold for this task. Do not use `ignore-unfixed: true` if the intention is to fail on all matching findings, including vulnerabilities without a fix.

### Results from my scan

- **Image scanned:** `REPLACE_WITH_YOUR_IMAGE_NAME_AND_TAG`
- **Docker base image:** `REPLACE_WITH_THE_FROM_LINE_IN_DOCKERFILE`
- **Scan status:** `REPLACE_WITH_PASSED_OR_FAILED`
- **Critical vulnerabilities:** `REPLACE_WITH_ACTUAL_COUNT`
- **High vulnerabilities:** `REPLACE_WITH_ACTUAL_COUNT`
- **CVE IDs / notable findings:** `ADD_THE_ACTUAL_FINDINGS_FROM_THE_TRIVY_LOGS`

> Add a screenshot of the Trivy scan output from the GitHub Actions run here.

![Trivy scan output](images/trivy-scan.png)

**Note:** A successful scan means no findings matched the configured failure threshold in that scan. It does not prove that the image is completely vulnerability-free.

---

## 4. Task 2 - Enable GitHub Secret Scanning and Push Protection

Secret scanning helps detect credentials such as API keys, access tokens, and passwords that may have been committed to a repository.

Push protection checks for supported secrets before a push is accepted and can block the push to help prevent the secret from entering the repository.

### Difference

| Feature | Secret scanning | Push protection |
|---|---|---|
| When it works | Scans repository content for exposed secrets | Checks a push before accepting it |
| Main purpose | Detect and alert about leaked credentials | Prevent supported secrets from being pushed |
| Result | Generates an alert when a secret is detected | Blocks the push unless an allowed bypass process is used |

### If GitHub detects a leaked AWS key

GitHub may create a secret-scanning alert and, for supported credential types, notify the provider. Treat the key as compromised: revoke or rotate it immediately, investigate its use, and remove the exposed secret from repository history where appropriate. Deleting the key from the latest file alone does not make an already leaked credential safe.

### Repository configuration

Enable these options if available:

- Secret scanning
- Push protection

**Navigation:** Repository → Settings → Code security and analysis.

> Add a screenshot showing the enabled security settings here.

![Secret scanning settings](images/secret-scanning.png)

---

## 5. Task 3 - Review dependency changes in pull requests

The Dependency Review Action checks dependency changes introduced by a pull request against known vulnerability information. It helps identify risky dependency updates before they are merged.

This check runs on `pull_request` events. It requires dependency information to be available to GitHub; commit the Node.js lockfile (`package-lock.json`) so dependency changes can be reviewed.

### Configuration

Add this step to the pull-request workflow:

```yaml
- name: Review dependency changes
  uses: actions/dependency-review-action@v4
  with:
    fail-on-severity: critical
```

### Verification

- **Did the dependency review run on a pull request?** `REPLACE_WITH_YES_OR_NO`
- **Did it appear as a pull-request check?** `REPLACE_WITH_YES_OR_NO`
- **Result / findings:** `ADD_YOUR_ACTUAL_RESULT`

> Add a screenshot of the dependency review check on your pull request here.

![Dependency review check](images/dependency-review.png)

---

## 6. Task 4 - Apply least-privilege workflow permissions

Workflow permissions control what the GitHub Actions `GITHUB_TOKEN` can do. Granting only the permissions required by a workflow reduces the damage that a compromised action or job could cause.

For workflows that only need to read repository contents, use:

```yaml
permissions:
  contents: read
```

Add this at the workflow level in at least two workflows, or define appropriately scoped permissions at the job level. If a workflow genuinely needs to write a pull-request comment, it may also need `pull-requests: write`; do not grant that permission unless it is required.

### Why limit permissions?

If a compromised action has unnecessary write access, it could potentially modify repository files, create or alter pull requests, or make other changes allowed by its token. Least-privilege permissions reduce the available attack surface.

### Workflows updated

- `REPLACE_WITH_WORKFLOW_FILE_1`
- `REPLACE_WITH_WORKFLOW_FILE_2`

---

### 7. Task 5 - Updated secure CI/CD pipeline 

Look at what your pipeline does now:

```
PR opened
  → build & test
  → dependency vulnerability check     ← NEW (Day 49)
  → PR checks pass or fail

Merge to main
  → build & test
  → Docker build
  → Trivy image scan (fail on CRITICAL) ← NEW (Day 49)
  → Docker push (only if scan passes)
  → deploy

Always active
  → GitHub secret scanning              ← NEW (Day 49)
  → push protection for secrets         ← NEW (Day 49)
```

Draw this diagram in your notes. You just built a **DevSecOps pipeline** — security is now part of your automation, not an afterthought.

  ![image](images/devsecops.png)

---

Secret scanning detects sensitive data (like API keys or passwords) accidentally committed to code, preventing leaks.

Dependency review analyzes project libraries to catch vulnerabilities, outdated packages, or risky changes before they’re merged.


DevSecOps means including security in every step of making and running software. Developers, security teams, and operations work together to find and fix security problems early. This helps create safer software faster.

---

## 8. What I learned

- DevSecOps integrates security into development and delivery instead of treating it as a final step.
- Trivy can scan container images for known vulnerabilities and fail a workflow based on severity.
- Secret scanning detects exposed credentials, while push protection can prevent supported secrets from being pushed.
- Dependency Review checks dependency changes introduced by pull requests.
- Least-privilege permissions reduce the impact of compromised workflows or actions.
- Security checks should run before an image is promoted or deployed.

## 9. Evidence checklist

- [ ] Trivy scan log screenshot added
- [ ] Secret scanning settings screenshot added
- [ ] Dependency review pull-request check screenshot added
- [ ] Updated pipeline diagram included
- [ ] At least two workflows have restricted permissions
- [ ] Actual scan findings and results filled in above
