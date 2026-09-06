# Day 41 -- Triggers & Matrix Builds

## Challenge Tasks

### Task 1: Trigger on Pull Request

1.  Create `.github/workflows/pr-check.yml`
2.  Trigger it only when a pull request is **opened or updated** against
    `main`
3.  Add a step that prints: `PR check running for branch: <branch name>`
4.  Create a new branch, push a commit, and open a PR
5.  Watch the workflow run automatically

**Verify:** Does it show up on the PR page?

-   Yes, the workflow runs automatically when a pull request is opened
    against `main` and when new commits are pushed to the PR branch.

![PR page](images/pr_page.png)

![PR workflow run](images/workflow_run.png)

![PR workflow completed](images/workflow_complete.png)

![Branch](images/branch.png)

[PR Check Workflow](workflows/pr-check.yml)

------------------------------------------------------------------------

### Task 2: Scheduled Trigger

1.  Add a `schedule:` trigger to any workflow using cron syntax
2.  Set it to run every day at midnight UTC
3.  What is the cron expression for every Monday at 9 AM?

[Scheduled Trigger](workflows/hello.yml)

-   The cron expression for every day at midnight UTC is `0 0 * * *`
-   The cron expression for every Monday at 9 AM UTC is `0 9 * * 1`

------------------------------------------------------------------------

### Task 3: Manual Trigger

1.  Create `.github/workflows/manual.yml` with a `workflow_dispatch:`
    trigger
2.  Add an **input** that asks for an `environment` name
    (staging/production)
3.  Print the input value in a step
4.  Go to the **Actions** tab → find the workflow → click **Run
    workflow**

**Verify:** Can you trigger it manually and see your input printed?

-   Yes, the workflow can be triggered manually from the Actions tab.
-   The selected environment value is printed in the workflow logs.

![Manual trigger](images/manual_trigger.png)

![Selected environment](images/printselectenv.png)

[Manual Trigger](workflows/manual.yml)

------------------------------------------------------------------------

### Task 4: Matrix Builds

Create `.github/workflows/matrix.yml` that:

1.  Uses a matrix strategy to run the same job across:
    -   Python versions: `3.10`, `3.11`, `3.12`
2.  Each job installs Python and prints the version
3.  Watch all 3 run in parallel

Then extend the matrix to also include 2 operating systems --- how many
total jobs run now?

-   The initial Python matrix runs **3 jobs**:

    -   Python 3.10
    -   Python 3.11
    -   Python 3.12

-   After extending the matrix to include 2 operating systems, the total
    number of combinations is:

    **3 Python versions × 2 operating systems = 6 jobs**

![Matrix workflow](images/task4.1.png)

![Python 3.10](images/task410.png)

![Python 3.11](images/task411.png)

![Python 3.12](images/task412.png)

![Extended matrix](images/matrixos.png)

[Matrix Builds](workflows/matrix.yml)

[Extended Matrix](workflows/matrixos.yml)

------------------------------------------------------------------------

### Task 5: Exclude & Fail-Fast

1.  In your matrix, **exclude** one specific combination, such as Python
    3.10 on Windows
2.  Set `fail-fast: false` --- trigger a failure in one job and observe
    what happens to the rest
3.  Write in your notes: What does `fail-fast: true` (the default) do vs
    `false`?

![Exclude and Fail-Fast](images/task5.png)

#### Observation (`fail-fast: false`)

-   The matrix initially contains **6 combinations**: 3 Python versions
    × 2 operating systems.
-   The combination **Windows + Python 3.10** was excluded.
-   Therefore, **5 matrix jobs** run.
-   An intentional failure was triggered for Python 3.11 using `exit 1`.
-   The Python 3.11 jobs failed, but the other matrix jobs continued
    running and were allowed to complete.
-   This demonstrates that `fail-fast: false` allows the remaining
    matrix jobs to continue even when one or more jobs fail.

#### `fail-fast: true` vs `false`

`fail-fast: true` **(default)**: - If a matrix job fails, GitHub Actions
cancels the other in-progress matrix jobs. - It is useful when
continuing the remaining matrix combinations is unnecessary after a
failure.

`fail-fast: false`: - If a matrix job fails, the other matrix jobs
continue running. - This is useful when you want to see the result of
every matrix combination even if one combination fails.

[Exclude & Fail-Fast](workflows/task5.yml)
