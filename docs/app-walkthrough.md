# Presenter walkthrough: personal finance app

Use this as a speaking guide rather than reading every paragraph aloud. Start
with the user's task, demonstrate a short flow, then connect the behavior to
small sections of Scheme. The [command guide](commands-and-troubleshooting.md)
contains setup and troubleshooting details.

## 1. Opening explanation

Suggested words:

> “This is a small personal finance app built with Scheme and LambdaNative.
> It records income and expenses on this device, calculates a balance, and lets
> us review and correct entries. We will use it as a working example: first
> understand the user experience, then choose useful improvements, including icons.”

Explain these limits honestly:

- The Linux version is a native desktop app; Android is a separate build from
  the same app source.
- There is no account, login, cloud synchronization or automatic bank import.
- The balance is recorded income minus recorded expenses, not a connection to
  a bank balance. It can be negative.
- Use fictional data for demonstrations; it is unnecessary to share real finances.
- F-Droid publishing is a separate process. Installing our workshop APK is not
  the same as downloading a listed F-Droid app.

## 2. Start with the improved app

The workshop now uses the improved app as its starting point. Demonstrate its
existing behavior, invite participants to review it, and use their feedback to
choose further improvements. The design activity is to find, adapt or create
suitable icons in Inkscape, retaining SVG source files. There is no need to
recreate the earlier green-screen app or teach a sequence of unpublished commits.

The app code is published on the
[improved-expense-income-tracker branch](https://github.com/BonfaceNjuguna/LambdaNativeQuickStart/tree/improved-expense-income-tracker).
The branch's [Actions runs](https://github.com/BonfaceNjuguna/LambdaNativeQuickStart/actions?query=branch%3Aimproved-expense-income-tracker)
show whether a usable APK/Linux artifact has been produced. A pushed branch is
not proof of a successful build: check the latest run and artifact before sharing.
These preparation docs and local build tools are deliberately kept local.

### Commands on Bonface's prepared Linux machine

Open a terminal, not the Scheme REPL:

```sh
cd /home/boni/Documents/Development/expense-tracker/LambdaNativeQuickStart
git branch --show-current
./tests/run.sh
./tools/build-linux.sh
./.local-build/linux/ExpenseTracker/ExpenseTracker
```

The branch should be `improved-expense-income-tracker`. The local helper reuses
our configured sibling framework at `../lambdanative`; it is not a dependency
installer for a fresh laptop. The last command opens the native Linux app and
holds the terminal until it exits. Run these before the meeting; share the app
window while demonstrating. Do not run `gsi ExpenseTracker/main.scm`.

If a current build is already available, launch it directly:

```sh
cd /home/boni/Documents/Development/expense-tracker/LambdaNativeQuickStart
./.local-build/linux/ExpenseTracker/ExpenseTracker
```

If rebuilding fails, inspect the log and use the last known working executable
or screenshots while resolving it:

```sh
tail -n 80 .local-build/linux/build.log
```

The `tools` folder is intentionally not on GitHub. Participants who cloned the
published branch cannot run that helper unless it is supplied separately. Use a
successful Linux artifact, the prepared workstation, or Benson's framework build
lesson for participant setup. The [command guide](commands-and-troubleshooting.md)
has the longer build/install instructions.

### Your role during this demonstration

You lead the app introduction and use cases, collect observations, help people
participate and hand concept questions to Benson. The emails support this working
arrangement; Benson has not explicitly assigned every teaching slot. Confirm the
handoffs before starting. Use the
[facilitator talking points](facilitator-talking-points.md) beside the demo.

## 3. Before sharing the screen

1. Start the Linux preview and verify it stays open.
2. Run `./tests/run.sh` before the meeting, not while everyone waits.
3. Know whether your preview contains earlier demo records.
4. Rehearse the sample flow below. If the database is not empty, use changes
   relative to the starting balance rather than claiming the displayed total is zero.
5. Open the improved app; keep its source branch and any downloaded artifact clearly identified.
6. If sharing the phone, make sure it is connected, unlocked and authorized.
7. Increase editor font size and share only relevant windows.

For a fresh Linux rehearsal dataset without deleting the existing preview data:
close the running app, then copy only the built executable into a separate demo
directory. These commands rely on this Linux build's app-directory data layout:

```sh
demo_dir=$(mktemp -d "$PWD/.local-build/workshop-demo.XXXXXX")
cp .local-build/linux/ExpenseTracker/ExpenseTracker "$demo_dir/ExpenseTracker"
"$demo_dir/ExpenseTracker"
```

Keep that terminal: `demo_dir` is its shell variable. This deliberately starts a
separate local demo database. If your environment behaves differently, use the
existing preview and report changes from its starting balance instead.

## Guided demo with expected results

Allow 15–25 minutes including questions. The exact balances below assume a new,
empty demo database. All values are KES.

### A. Orient the group

Point to PERSONAL FINANCE, the balance, Income/Expenses summaries, shortcuts,
latest transactions and Activity. Ask: “What would you expect to happen after I
record a bus fare? What would change if I corrected its amount later?”

### B. Create income

1. Click **+ Income**.
2. Confirm Type is Income.
3. Enter `1000.00`.
4. Choose **Salary** from the category picker.
5. Enter description `Workshop demo income`.
6. Save transaction.

Expected: income `KES 1,000.00`, expenses `KES 0.00`, balance `KES 1,000.00`.
Explain that opening the form did not save anything; Save is the write action.

### C. Create an expense and preserve a draft

1. Click **- Expense**.
2. Enter `125.50` and description `Workshop demo bus fare`.
3. Open Category and select **Transport**.
4. Confirm the entered amount/description survived visiting the picker.
5. Save.

Expected: expenses `KES 125.50`, balance `KES 874.50`.
The newest transaction appears above the income.

### D. Use a custom category

1. Add Expense `25.25`.
2. Choose **Other** and type `Workshop supplies` into Name your category.
3. Description: `Workshop demo stationery`.
4. Save.

Expected: expenses `KES 150.75`, balance `KES 849.25`; ledger category
Workshop supplies. A blank custom name is allowed and stores Other. The app
limits custom names to 40 characters and descriptions to 200.

Point out that Income and Expense have different predefined categories. Changing
type resets category/custom-name state rather than silently keeping a misleading
label from the other type.

### E. Read and filter history

1. Open Activity; show All, Income and Expenses filters.
2. Open a saved transaction and point out that the values are prefilled.
3. Cancel without saving; show that history is unchanged.

Overview queries only the 10 newest inserted records. “Newest” is currently
ordered by database row ID, not by a user-editable transaction date. Activity
queries all rows for its selected filter. The all-time balance includes all
records, including ones outside Overview's 10.

### F. Edit the bus fare

1. In Activity/All, click `Workshop demo bus fare`.
2. Change the amount from `125.50` to `100.50`.
3. Click Save changes.

Expected: three saved rows still exist; expenses `KES 125.75`, balance
`KES 874.25`. The original creation timestamp is retained. Editing does not move
the record to the top as if it had just been inserted.

Optional discussion: change an Income transaction to Expense, explain how both
summary totals change, then restore it. An active filter may hide it after the
type change; use All to find it again.

### G. Delete with confirmation

1. Open the stationery record.
2. Click Delete transaction.
3. First choose Keep transaction to demonstrate cancellation.
4. Reopen Delete transaction and choose Delete permanently.

Expected: two records remain; expenses `KES 100.50`, balance `KES 899.50`.
Only the chosen saved record is deleted. Deletion is permanent in this version;
there is no undo or recycle bin. Use only the labelled demo records.

### H. Validation without corrupting the data

Try amount `0` and attempt Save. Expect a readable error and no new row. On a
desktop keyboard, also try `1.001`, `abc` or `1e2`. A numeric phone keypad might
prevent entering some of these strings; the integration tests cover those cases.

Valid examples include `12`, `12.5`, `12.50` and `0.01`. The app rejects negative
amounts and expects the Income/Expense type to determine their effect on balance.
It also rejects comma-separated input such as `1,000`, even though displayed
amounts use grouping commas.

### I. Persistence

Close the app normally, reopen the same executable from the same demo directory,
and show that the saved records remain. Reopening the default preview after
using a separate demo directory will open a different database.

Ask: “What would a user need before trusting this with important records?”
Possible topics: backup, export, clearer deletion recovery, accessibility and
privacy. Record those as proposals; do not claim these features already exist.

## 4. A short code-reading tour

Find function names rather than memorizing line numbers:

```sh
rg -n '^\(define' ExpenseTracker/main.scm
rg -n 'expense-rows|expense-record!|expense-update!|expense-delete!' ExpenseTracker/main.scm
```

| Stop | Function/data | Teaching point |
|---|---|---|
| Categories | `expense-income-categories`, `expense-spending-categories` | Quoted lists and clear domain vocabulary |
| Validation | `expense-parse-cents`, `expense-write!` | Strings from input; exact cents; reject invalid data before writing |
| Display | `expense-decimal`, `expense-money` | Stored representation differs from user-facing format |
| Migration | `expense-initialize-db!` | Add fields without throwing old data away |
| Reads | `expense-total`, `expense-rows`, `expense-find-row` | SQL result rows, filtering, limits, stable IDs |
| CRUD | `expense-record!`, `expense-update!`, `expense-delete!` | INSERT, UPDATE and DELETE have different meanings |
| Dashboard | `expense-show-view!`, `expense-row-draw` | Render values and refresh them after a write |
| Row click | `expense-draw-ledger` | Callback maps selection to a saved row ID |
| Form | `expense-entry-form`, `expense-open-entry!` | Declarative UI, initial state and custom categories |
| Save | `expense-save-form!` | Choose create/update; show error or refresh dashboard |
| Delete | `expense-delete-form!` and form page `delete` | Confirmation precedes the database action |
| Entry point | Final `main` expression | Initialization, events, shutdown, suspend/resume |

### Data flow to draw or explain

```text
User types amount text
  → uiget reads form state
  → expense-save-form! reads category/custom name in order
  → create or update checks and parses the values
  → expense-write! writes SQLite
  → expense-show-view! re-queries totals and rows
  → cards and history display the saved result
```

“The button changes the database, then the dashboard reads the database. We do
not just change a number on screen and hope it matches storage.”

### Row shape and monetary representation

```scheme
'("17" "Expense" "12550" "Workshop demo bus fare" "Transport" "2026-10-29 15:10:00")
```

This represents KES 125.50, not KES 12,550. IDs and cents are selected as text
to avoid the pinned binding's 32-bit integer result conversion. The legacy
numeric `amount` column remains for compatibility, but current totals use cents.

## 5. Further improvements and icon work

Start with the [icon design brief](icon-design-brief.md), then choose one small
code task if time allows. Predict its effect before editing. Rebuild after
changes; the running native executable does not hot-reload the Scheme file.

| Task | Who can help | Check afterward |
|---|---|---|
| Improve a label or empty-state message | Any participant | Readability and layout on Linux/phone |
| Add a relevant predefined category | Beginner pair | Correct type list, picker, save and reopening |
| Suggest icon variants in SVG | Design group | Readability, licensing and small-size legibility; integration is a separate task |
| Improve a test case | Intermediate pair | It catches a real behavior, not merely code formatting |
| Propose a search/date-filter feature | More experienced group | Agree UI and storage behavior before implementing |

For example, add `"Rent"` to Expense categories only. Ask whether it should be
separate from Bills; the product decision matters as much as adding a string.
Do not casually change the money parser, database schema or Android SDK target
as a first exercise.

## 6. Common questions and honest answers

- **Why only 10 on Overview?** It is a concise summary; Activity is the full ledger.
- **Does changing a description recalculate the amount?** No. Totals are sums of
  stored cents; edits to amount/type affect them, description-only changes do not.
- **Can we change the date?** Not in the current form. `created_at` is creation
  time, not a separate user-entered date of the transaction.
- **What does General mean?** It labels migrated entries that did not have a category.
- **Where does Other go after reopening?** A custom saved name is reopened as
  Other plus the custom-name field, so it remains editable.
- **Why can a filtered list become empty after saving?** The changed row may no
  longer match that filter. Open All.
- **Can we use the original app against the new demo data?** Keep separate app
  copies/data directories. The old app does not maintain the new cents field on
  writes, so mixing old/new writers is not a supported workshop workflow.

## 7. Feedback to turn into issues

Capture a concrete task, what the person expected, what happened, and why it
matters. Separate bugs from feature ideas. For example:

> “When correcting a transaction, I want to see its original date in the form
> so I can be sure I selected the right entry.”

Or:

> “After changing an Income entry to Expense while filtering Income, I could
> not find it. A short confirmation explaining that it moved would help.”

Do not promise every request during the workshop. Agree which small improvement
to attempt, who will work on it, and how the group will verify it.
