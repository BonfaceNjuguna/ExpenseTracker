# Git and GitHub cheat sheet

This is for participants who have never used either tool. Introduce only what
they need for the workshop; participants can contribute useful feedback without
first learning every Git command.

## 1. Common vocabulary

| Term | Plain-language meaning |
|---|---|
| Git | Tracks versions of files locally |
| GitHub | Hosts repositories and collaboration tools online |
| Repository | Project files plus Git history |
| Clone | Make a local copy of a repository and its history |
| Working tree | Files currently on disk, including uncommitted edits |
| Commit | A recorded snapshot of selected changes |
| Branch | A name pointing to a line of commits |
| Remote | A named repository elsewhere, often `origin` |
| Push | Send local commits to a remote |
| Pull | Fetch and integrate remote changes; it can change your files |
| Issue | A discussion/report of a bug, feature or task |
| Pull request | Ask to review/integrate changes between branches |
| Actions workflow | Instructions for running automated jobs on GitHub |
| Artifact | A file/output saved by a workflow run, such as an APK |

A commit is not a push. Saving a file is not a commit. A local branch does not
exist on GitHub until its commits/branch are pushed. A built APK can differ from
the currently committed source if it was built from uncommitted files.

## 2. Read-only commands to start with

From the repository root:

```sh
git status --short
git branch --show-current
git log -5 --oneline
git diff --stat
git diff -- ExpenseTracker/main.scm
git diff --cached
git remote -v
```

`git diff` shows unstaged edits; `git diff --cached` shows staged changes. The app changes are published on the improved branch; preparation docs and local
tools remain uncommitted.
Do not use reset/clean to “fix” that status.

If a file is untracked, it appears as `??` in status but not in a normal diff
until Git tracks/stages it. Generated output is ignored under `.local-build`.

## 3. Learner workflow in a separate clone

These commands are instructions for learners' own copies, not permission to
commit or push Bonface's local workshop branch:

```sh
git clone --branch improved-expense-income-tracker https://github.com/BonfaceNjuguna/LambdaNativeQuickStart.git
cd LambdaNativeQuickStart
git switch -c workshop/category-improvement
```

This clone selects the published improved app. The preparation docs and local
`tools` helpers are not included. Confirm build prerequisites or use a successful
Actions artifact before asking everyone to compile. Do not assume every participant has write
access to the upstream repository.

After one small, reviewed edit in their own copy:

```sh
git diff -- ExpenseTracker/main.scm
git add ExpenseTracker/main.scm
git diff --cached
git commit -m "Add a useful expense category"
```

Stage named files rather than every generated file. Check that no database,
keystore, participant spreadsheet or personal screenshot is staged. App tests
require the framework checkout/dependencies; a fresh app clone alone does not
provide them.

For contributing online, learners without upstream write access normally work
through a fork and a pull request. Agree the actual fork/remote before teaching
`git push`; do not have learners blindly push to an upstream they do not control.

## 4. Make a useful issue before changing code

An issue should let another person reproduce the situation:

```text
Title: Explain where an entry went after changing its type

Context: Workshop app, Android, Activity filtered to Income
Steps:
1. Open an Income transaction.
2. Change Type to Expense and save.
3. Observe the Income list.

Expected: A short explanation that the saved entry no longer matches the filter.
Actual: The entry disappears without an explanation.
Impact: I thought it had been deleted.
Suggested improvement: Show confirmation and offer View all.
```

Search existing issues first and add relevant evidence rather than opening
duplicates. For a feature request, describe the user's need before prescribing
an implementation. Use fictional transaction descriptions in screenshots.

## 5. Pull request discussion

Ask the contributor to state:

1. What user problem does this solve?
2. What changes when the app runs?
3. How was the change checked?
4. What remains unfinished or requires phone testing?

A successful Actions run means the configured checks/build completed; it does
not prove every interaction works. A failed run is evidence to inspect, not a
reason to randomly edit dependencies.

## 6. The Actions demonstration

Show `.github/workflows/build.yml` and find:

- `on`: push to main/improved branch, PRs targeting main, and manual dispatch.
- The Fedora container and build dependencies.
- The pinned LambdaNative checkout.
- App copy, tests, Linux build and Android build.
- APK architecture/metadata check.
- Artifact upload, named `apk`.

The workflow supports manual dispatch and builds improved-branch pushes. Use a
known successful run for the demo rather than assuming a queued/running build
has downloadable output. If a learner opens a
PR, workflow execution may depend on repository settings and contributor trust.

Read-only CLI examples:

```sh
gh run list --workflow build.yml --limit 5
```

Then use the real run ID and artifact commands in the
[command guide](commands-and-troubleshooting.md#8-github-actions-and-downloading-an-existing-artifact).
Do not confuse the run's branch/commit with an unpushed local build.

## 7. What to do when something goes wrong

- Wrong branch? Read `git status` before changing anything.
- Conflict? Identify both intended changes and ask for review; do not delete
  conflict markers while ignoring one side's behavior.
- Forgot to stage a file? Review status and the staged diff before committing.
- No push permission? Use the agreed fork workflow rather than sharing credentials.
- Worried about losing work? Stop and inspect. Avoid `git reset --hard`,
  `git clean`, force-push or deleting directories as workshop troubleshooting.

Reference: [GitHub documentation](https://docs.github.com/), especially the
[artifact download guide](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/download-workflow-artifacts).
