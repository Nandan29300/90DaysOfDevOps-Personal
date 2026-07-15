# Day 26 – GitHub CLI: Manage GitHub from Your Terminal

---

## Why this matters

Up to Day 25, every command I learned (`git`) only talked to the **local repo** and the **remote git protocol** (push/pull/fetch). But a huge part of real GitHub work - opening PRs, triaging issues, checking CI status, spinning up repos - normally happens in the **browser**, not the terminal.

The GitHub CLI (`gh`) closes that gap. It talks to the **GitHub REST/GraphQL API** (not just the git protocol), so it can do things plain `git` never could: create issues, merge PRs, check workflow runs, view repo metadata, etc. For a DevOps engineer this matters because:

- Anything you can type, you can **script**. `gh pr create`, `gh issue list --json`, `gh run list` are all automatable - this is the seed of CI/CD glue scripts, ChatOps bots, and release automation.
- **No context switching.** Staying in the terminal while doing a deploy or an on-call fix means fewer tabs, less friction, faster response time.
- It's how a lot of real GitHub Actions workflows and internal tooling are built - `gh` is often invoked *inside* CI runners themselves.

---

## Task 1: Install and Authenticate

### Install
On Ubuntu/Debian, the officially recommended way is via GitHub's own apt repo (not `apt install gh` directly, since that pulls an unrelated/old package on some distros):

```bash
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
  && sudo mkdir -p -m 755 /etc/apt/keyrings \
  && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y
```

Verify:
```bash
gh --version
```

### Authenticate
```bash
gh auth login
```
This launches an interactive wizard asking:
1. Account type - GitHub.com or GitHub Enterprise Server
2. Protocol - HTTPS or SSH
3. Auth method - browser login or a personal access token
4. Whether to authenticate git operations (`git push`/`pull`) with your `gh` credentials too

### Verify login / check active account
```bash
gh auth status
```
Shows the logged-in account, the auth protocol in use, and token scopes.

To switch between multiple logged-in accounts:
```bash
gh auth switch
```

### Answer - What authentication methods does `gh` support?
`gh auth login` supports three main paths:

1. **Web browser (OAuth device flow)** - `gh` prints a one-time code, opens the browser, you paste the code and approve. This is the default and easiest for interactive use.
2. **Personal Access Token (PAT)** - paste an existing token (classic or fine-grained) generated from GitHub settings. Useful for headless servers, CI runners, or Docker containers where a browser isn't available.
3. **SSH key based** - `gh` can also generate/upload an SSH key as part of login, so `git` operations over SSH are authenticated, while `gh` API calls still use a token under the hood.

For non-interactive/CI use, `GH_TOKEN` or `GITHUB_TOKEN` environment variables can be set directly, and `gh` will pick them up without running `gh auth login` at all - this is the pattern used inside GitHub Actions runners.

---

## Task 2: Working with Repositories

### Create a new repo (public, with README)
```bash
gh repo create day26-test-repo --public --add-readme
```
Flags worth knowing: `--private`, `--description "..."`, `--clone` (clone it locally right after creating), `--source .` (turn an existing local folder into a GitHub repo).

### Clone with `gh` instead of `git clone`
```bash
gh repo clone <owner>/<repo>
```
Difference from `git clone`: you don't need the full URL - just `owner/repo` - and `gh` will use whatever auth method you set up, so private repos "just work" without separate credential setup.

### View details of a repo
```bash
gh repo view <owner>/<repo>
```
Add `--web` to open the same view in the browser instead of printing to terminal.

### List all your repositories
```bash
gh repo list
gh repo list <owner> --limit 50
```

### Open a repo in the browser from the terminal
```bash
gh repo view --web
```
(run from inside a cloned repo folder, or pass `owner/repo --web` from anywhere)

### Delete the test repo
```bash
gh repo delete <owner>/day26-test-repo --yes
```
`--yes` skips the confirmation prompt - worth being deliberate with this one since deletion is irreversible.

**Takeaway:** the entire "create → clone → inspect → open in browser → delete" lifecycle of a repo, which used to mean 5 browser clicks + a separate `git clone`, is now 5 one-line terminal commands.

---

## Task 3: Issues

### Create an issue with title, body, and label
```bash
gh issue create --title "Bug: login fails on stale token" \
  --body "Steps to reproduce: ..." \
  --label bug
```
Omit `--title`/`--body` to get an interactive prompt/editor instead.

### List all open issues
```bash
gh issue list
gh issue list --state open
```

### View a specific issue by number
```bash
gh issue view 12
```
Add `--web` to open it in the browser instead.

### Close an issue
```bash
gh issue close 12
```
(`gh issue reopen 12` to undo)

### Answer - How could you use `gh issue` in a script or automation?
A few concrete patterns:

- **Auto-filing bugs from monitoring/alerting scripts** - a cron job or log analyzer (like the ones from earlier days) that detects a failure pattern can pipe straight into `gh issue create --title "..." --body "..." --label auto-filed`, turning a Bash script into an incident-tracker.
- **Bulk triage** - `gh issue list --json number,title,labels --jq '...'` gives structured JSON that can be filtered/processed with `jq` to, say, find all issues untouched for 30 days and auto-comment or auto-close them.
- **Release checklists** - a script could open a templated issue every time a new version tag is pushed, pre-filled with a QA checklist.
- **ChatOps** - a Slack/Discord bot backend can shell out to `gh issue` commands so teammates manage issues from chat instead of the GitHub UI.

The common thread: `--json` + `--jq` turns `gh issue` from a CLI convenience into a proper scriptable data source.

---

## Task 4: Pull Requests

### Full terminal flow: branch → change → push → PR
```bash
git checkout -b feature/day26-notes
echo "test change" >> notes.md
git add notes.md
git commit -m "docs: day 26 notes"
git push -u origin feature/day26-notes
gh pr create --fill
```
`--fill` auto-populates the PR title/body from the branch's commit messages - saves typing for small PRs. For anything non-trivial I'd still write `--title`/`--body` by hand so the PR description actually explains the *why*.

### List open PRs
```bash
gh pr list
```

### View PR details - status, reviewers, checks
```bash
gh pr view <number>
gh pr checks <number>
```
`gh pr view` shows the description, reviewers, labels, and merge state; `gh pr checks` specifically shows CI/status-check results (pass/fail/pending) per check.

### Merge a PR from the terminal
```bash
gh pr merge <number> --squash --delete-branch
```

### Answer - What merge methods does `gh pr merge` support?
Three, matching what GitHub's web UI offers:
- `--merge` - a standard merge commit (keeps full commit history of the branch)
- `--squash` - squashes all the branch's commits into a single commit on the base branch
- `--rebase` - replays the branch's commits individually onto the base branch, no merge commit

`--delete-branch` can be combined with any of them to clean up the branch immediately after merging, and `--admin` bypasses branch protection rules if you have admin rights.

### Answer - How would you review someone else's PR using `gh`?
```bash
gh pr checkout <number>      # pulls the PR branch locally so you can run/test it
gh pr diff <number>          # view the diff in the terminal
gh pr view <number> --comments   # read existing discussion
gh pr review <number> --approve -b "LGTM, nice cleanup"
gh pr review <number> --request-changes -b "Please add a test for the edge case"
gh pr review <number> --comment -b "Just a general comment, no blocking issue"
```
`gh pr checkout` is the standout here - it's the terminal equivalent of clicking "checkout" in GitHub Desktop, letting you actually run the code before approving instead of reviewing blind from a diff.

---

## Task 5: GitHub Actions & Workflows (Preview)

### List workflow runs on a public repo
```bash
gh run list --repo cli/cli
```

### View the status of a specific run
```bash
gh run view <run-id> --repo cli/cli
```
Add `--log` to stream the full job log, or `--log-failed` to see only the logs of failed steps - handy for debugging a broken pipeline without opening the Actions tab in the browser.

### Answer - How could `gh run` and `gh workflow` be useful in a CI/CD pipeline?
- **Fast feedback loop**: after `git push`, running `gh run watch` blocks in the terminal and streams live status until the triggered workflow finishes - no need to alt-tab to the Actions tab to see if the build passed.
- **Manual/on-demand triggers**: `gh workflow run <workflow-name> -f key=value` can kick off a `workflow_dispatch` job (e.g., a manual deploy) directly from the terminal, optionally passing input parameters.
- **Debugging failed pipelines**: `gh run view --log-failed` pulls just the failing step's logs, which is much faster than clicking through the web UI's collapsed log groups.
- **Re-running flaky jobs**: `gh run rerun <run-id> --failed` re-runs only the failed jobs of a run instead of the whole pipeline - saves CI minutes.
- **Scripted release gating**: a deploy script can poll `gh run list --json status,conclusion` to programmatically wait until the "build" workflow succeeds before triggering a downstream "deploy" step - effectively hand-rolling a lightweight pipeline dependency chain.

---

## Task 6: Useful `gh` Tricks

| Command | What I tried | Notes |
|---|---|---|
| `gh api` | `gh api repos/{owner}/{repo}` | Raw access to any GitHub REST endpoint, auth handled automatically. Useful when a `gh` subcommand doesn't exist yet for what you need. |
| `gh gist create` | `gh gist create notes.md --public` | Turns any local file into a shareable Gist in one line. |
| `gh release create` | `gh release create v1.0.0 --notes "First release"` | Creates a tagged GitHub release; can attach build artifacts as extra args. |
| `gh alias set` | `gh alias set prs 'pr list --author @me'` | Lets you define your own shortcuts, e.g. `gh prs` instead of typing the full flag chain every time. |
| `gh search repos` | `gh search repos "devops" --language=python --stars=">100"` | Searches all of GitHub from the terminal with filters - no browser needed. |

**Takeaway:** `gh api` is the real power tool here - since it's a thin wrapper over the full GitHub API, anything the web UI can do, `gh api` can eventually reach even if there's no dedicated subcommand yet.

---

## Overall Takeaways from Day 26

1. **`git` vs `gh` is a protocol split.** `git` speaks the git wire protocol (clone/push/pull/fetch - pure version control). `gh` speaks the GitHub API (issues, PRs, Actions, releases - the "platform" features GitHub adds on top of git). Knowing which tool owns which concern makes the command choice automatic instead of guesswork.
2. **`--json` + `--jq` is the automation on-ramp.** Almost every `gh` list/view command supports structured JSON output, which means `gh` isn't just a UI replacement - it's a queryable data source for scripts, dashboards, and bots.
3. **The full software lifecycle now fits in one terminal session**: create repo → branch → commit → push → open PR → check CI → merge → tag a release - no browser required. That's a meaningful speed and focus win for daily DevOps work.
4. **This is a stepping stone to CI/CD.** `gh run` / `gh workflow` are previewed here but will matter a lot more once GitHub Actions itself is covered - being comfortable inspecting/triggering workflows from the CLI now will make debugging pipelines later much faster.
5. **`gh alias` is worth setting up early**, not as an afterthought - a handful of aliases for the commands I'll run daily (`gh pr list --author @me`, `gh issue list --assignee @me`) will save real time over the rest of the challenge.

---
