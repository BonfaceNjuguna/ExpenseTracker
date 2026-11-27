# Workshop preparation notes

Prepared for Bonface's remote LambdaNative workshop, 29–31 October 2026.
These are presenter reference notes, with some sections suitable for sharing
with learners. They describe the local `improved-expense-income-tracker` branch;
the app code is now published there, while these docs and the local tools remain
on this workstation. Check Actions before treating any build as ready.

## Reading order

| Document | Use it for |
|---|---|
| [Facilitator talking points](facilitator-talking-points.md) | Ready-to-say opening, app demo narration, handoffs and participant support |
| [Icon design brief](icon-design-brief.md) | Inkscape/SVG activity, licensing, deliverables and review criteria |
| [Facilitator notes](facilitator-notes.md) | Session timings, preparation, roles, breakout activities, questions and fallback plans |
| [App walkthrough](app-walkthrough.md) | A guided demonstration, exact sample transactions, source tour, CRUD and improvement exercises |
| [Scheme cheat sheet](scheme-cheat-sheet.md) | Syntax, lists, procedures, quotation, recursion, common mistakes and small exercises |
| [LambdaNative cheat sheet](lambdanative-cheat-sheet.md) | Framework concepts, lifecycle, widgets, forms, data storage and build structure |
| [Commands and troubleshooting](commands-and-troubleshooting.md) | Linux preview, tests, Android build/install, logs, database inspection and recovery |
| [Git and GitHub cheat sheet](git-github-cheat-sheet.md) | Beginner explanations, issues, diffs, branches, pull requests and Actions artifacts |
| [Runnable Scheme practice](examples/scheme-practice.scm) | Small, self-checking examples that run without the GUI or database |

## If preparation time is short

1. Open the [talking points](facilitator-talking-points.md), then the [demo sequence](app-walkthrough.md#guided-demo-with-expected-results).
2. Run the [preflight commands](commands-and-troubleshooting.md#1-preflight-from-the-repository-root).
3. Rehearse adding, editing and deleting a fictional transaction.
4. Have a built Linux preview and APK ready before participants join.
5. Open the [first-session plan](facilitator-notes.md#day-1-thursday-29-october-3pm6pm-eat).
6. Keep the Scheme and troubleshooting sheets beside the shared screen.

## Quick local commands

Run from `LambdaNativeQuickStart`, not its parent and not the framework checkout:

```sh
pwd
git branch --show-current
./tests/run.sh
gsi docs/examples/scheme-practice.scm
./tools/build-linux.sh
./.local-build/linux/ExpenseTracker/ExpenseTracker
```

`gsi` is Gambit's interpreter. The GUI app needs the LambdaNative build process;
do not try to launch it by running `gsi ExpenseTracker/main.scm`.

## Workshop dates

| Session | East Africa Time | Duration |
|---|---|---|
| Thursday, 29 October 2026 | 3–6pm | 3 hours |
| Friday, 30 October 2026 | 2–6pm | 4 hours |
| Saturday, 31 October 2026 | 9am–1pm | 4 hours |

The schedule totals 11 hours including any breaks taken within these windows.
Confirm how Benson wants to account for breaks and contact time.

## Sources and scope

Implementation details were checked against this repository's `main.scm`, tests,
build helpers, workflow and the local framework checkout on 29 October 2026.
The workflow pins LambdaNative to
`b6e82ee343d8ea3c95e277d7e122baae9a5dc096`; upstream documentation may describe newer APIs.

Primary references:

- [LambdaNative](https://www.lambdanative.org/) and its [source/wiki](https://github.com/part-cw/lambdanative)
- [Gambit](https://gambitscheme.org/) and [manual](https://gambitscheme.org/latest/manual/)
- [Scheme reports](https://scheme-reports.org/)
- [F-Droid overview](https://f-droid.org/en/about/) and [inclusion policy](https://f-droid.org/docs/Inclusion_Policy/)
- [GitHub: downloading workflow artifacts](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/download-workflow-artifacts)

Benson's workshop and lesson links are listed in the facilitator notes. Those
pages could not be fetched during preparation; the notes do not claim to
reproduce their current lesson contents. Check them in a browser before teaching.

No registration records or participant contact information are included here.
