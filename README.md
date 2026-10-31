# Expense Tracker

Expense Tracker is a small personal finance app for recording income and expenses,
keeping track of your balance, and reviewing where your money goes. It runs on
Android and Linux and stores transactions locally using SQLite.

The app was initially intended for [Learning Lions](https://www.learninglions.org/)
students, helping them track their earnings and expenses while learning and
developing their skills. Their everyday needs continue to guide its development.

The app is written in Scheme with [LambdaNative](https://www.lambdanative.org/).
It is also a practical learning project: participants in the Learning Lions
LambdaNative workshop have been trying the app, sharing feedback, and exploring
ways to improve it through programming, testing and design.

[Visit the app website](https://bonfacenjuguna.github.io/ExpenseTracker/) ·
[Report a problem or suggest an improvement](https://github.com/BonfaceNjuguna/ExpenseTracker/issues)

## What you can do

- Record income and expenses with amounts in Kenyan shillings (KES).
- See your balance and separate income and expense totals.
- Review the latest ten transactions on Overview, or open Activity for the full history.
- Filter Activity to show income or expenses.
- Choose from separate income and expense categories, or name your own using Other.
- Open a saved transaction to edit its type, amount, category or description.
- Delete a transaction after confirming the action.
- Close and reopen the app without losing saved transactions.

Amounts are stored as integer cents so calculations do not depend on floating-point
rounding. The balance reflects the transactions you have recorded; the app does
not connect to a bank account. Login, cloud synchronization and bank imports are
not currently included.

## Try the app

### Android

Visit the [app website](https://bonfacenjuguna.github.io/ExpenseTracker/) for the
Android APK. You can also download the `apk` artifact from a successful
[GitHub Actions run](https://github.com/BonfaceNjuguna/ExpenseTracker/actions/workflows/build.yml).
Extract the artifact ZIP to find the APK and `apk-info.txt`, which records its
package name, SDK settings and supported native architectures.

Install the APK on your Android device, or use Android SDK Platform Tools:

```sh
adb devices
adb install -r ExpenseTracker-1.0-android-api28.apk
```

Use the actual filename if the app version has changed. Updating an existing
installation requires a compatible package name and signing key.

### Linux

Download the `linux` artifact from a successful Actions run. Extract the artifact,
then extract the app ZIP inside it. For version 1.0:

```sh
unzip ExpenseTracker-1.0-linux.zip
./ExpenseTracker/ExpenseTracker
```

This opens a native Linux application, not an Android emulator. It needs a
compatible Linux desktop and runtime libraries. In this build, the SQLite file
and logs are stored beside the executable, so keep that directory writable and
retain it if you want to keep your records.

## Building from source

Clone the repository:

```sh
git clone https://github.com/BonfaceNjuguna/ExpenseTracker.git
cd ExpenseTracker
```

The complete build recipe is in
[`.github/workflows/build.yml`](.github/workflows/build.yml). It installs the
Fedora build dependencies, checks out a pinned LambdaNative revision, runs the
tests, builds Linux and Android packages, and builds the app website. Using the
workflow is the easiest way to reproduce the project's configured build without
setting up the Android toolchain on your own computer.

The workflow runs on pushes to `main` and `improved-expense-income-tracker`, on
pull requests targeting `main`, and through manual dispatch. Use a successful run
for the source revision you want to test; an older artifact may contain an older app.

For a manual build, first prepare a LambdaNative checkout and the native
dependencies for your platform. See the
[LambdaNative documentation](https://github.com/part-cw/lambdanative/wiki) and
apply this project's configuration and compatibility patches from the workflow.
The framework revision used here is:

```text
b6e82ee343d8ea3c95e277d7e122baae9a5dc096
```

Once that environment is configured, copy this repository's `ExpenseTracker/`
application directory into the framework's `apps/` directory. Run the following
**inside the LambdaNative checkout**:

```sh
./configure ExpenseTracker linux debug
make
```

For Android, configure the SDK and NDK paths in the framework's `SETUP` file and
its signing settings in `PROFILE`, then build:

```sh
./configure ExpenseTracker android debug
make
```

On Linux, LambdaNative writes packaged builds to
`~/.cache/lambdanative/packages/`. The workflow's dependency versions and patches
are important; these commands alone do not install or configure a fresh machine.

## Finding your way around the code

| File or directory | Purpose |
|---|---|
| [`ExpenseTracker/main.scm`](ExpenseTracker/main.scm) | Screens, navigation, validation and transaction storage |
| [`ExpenseTracker/MODULES`](ExpenseTracker/MODULES) | Framework modules used by the app |
| [`ExpenseTracker/FONTS`](ExpenseTracker/FONTS) | Font resources generated during the build |
| [`ExpenseTracker/artwork.png`](ExpenseTracker/artwork.png) | Application artwork |
| [`tests/`](tests/) | Automated checks for transaction behavior and startup |
| [`website/haunt.scm`](website/haunt.scm) | App website, built with Haunt |
| [`.github/workflows/build.yml`](.github/workflows/build.yml) | Build, test and website deployment workflow |

Existing databases are upgraded in place. Earlier records keep their amounts;
entries without a category are labelled General, and missing historical dates
are left blank. Editing a transaction retains its original creation date.

## Testing

From the repository root, run:

```sh
./tests/run.sh
```

The tests need Gambit (`gsi` and `gsc`), a C compiler, SQLite development headers
and libraries, and a LambdaNative checkout. By default the runner looks for the
framework in `../lambdanative`. To use another location:

```sh
LAMBDANATIVE_DIR=/absolute/path/to/lambdanative ./tests/run.sh
```

The suite uses the framework's SQLite binding with a real temporary database;
GUI widgets are replaced by test objects. It checks migration, decimal amounts,
validation, custom categories, creating/editing/deleting transactions, the
Overview limit, Activity filters and persistence. Manual testing on Linux and
Android is still needed for layout, touch input, scrolling and the keyboard.

## Reporting problems

Please include the platform, app/build version, steps to reproduce the problem,
and what you expected to happen. Screenshots and logs can help, using fictional
transaction data.

For Android startup problems, capture logs while reproducing the failure:

```sh
adb logcat -b all -v threadtime > expense-logcat.txt
```

Press Ctrl+C after reproducing it. A Scheme exception can close the app without
a Java crash, so also collect the application logs. For the default build profile:

```sh
adb pull /sdcard/Android/data/com.yourdomainhere.expensetracker/files/log expense-logs
```

Check `apk-info.txt` and substitute the actual package name if different. Remove
personal information from logs or screenshots before attaching them to an issue.

## Contributing

Bug reports, usability feedback, documentation, tests, code and design work are
all welcome. Start with an [issue](https://github.com/BonfaceNjuguna/ExpenseTracker/issues)
so we can agree on a useful, manageable change. For code contributions, work on a
branch and open a pull request explaining the change and how you checked it.

We are also interested in clearer icons and other visual improvements. Editable
SVG files, including work made with Inkscape, are useful design contributions.
Include the source and license for reused assets. Asset integration should follow
the framework's supported build pipeline and be checked in the running app.

## AI-assisted contributions

**OpenAI Codex has been used to generate and revise portions of this project's
code and supporting material.** Its involvement includes:

- Application startup fixes, custom
  category entry, formatting and adding comments, SQLite migration, and transaction editing/deletion
  in `ExpenseTracker/main.scm`, along with font configuration in `ExpenseTracker/FONTS`.
- The transaction/startup checks in `tests/startup.scm` and their runner in `tests/run.sh`.
- GitHub Actions configuration and troubleshooting, including Linux/Android build
  compatibility fixes, dependency setup, wheel scrolling and APK verification.
- Revising README text, drafting some commit messages and pull request descriptions.

Maintainers remain responsible for reviewing and testing changes before publication.

For future AI-assisted contributions, please name the tool and describe which
parts it helped produce in the pull request, including generated code, tests,
documentation or commit messages. Review the changes, understand their behavior,
and explain how they were checked. The contributor remains responsible for the
submitted work. An `Assisted-by: OpenAI Codex` commit trailer can supplement that
disclosure when applicable; existing history has not been rewritten to add trailers.

## Acknowledgements

This work is supported by the [NLnet Foundation](https://nlnet.nl/) as part of the
[LambdaNative F-Droid integration project](https://nlnet.nl/project/F-Droid-LambdaNative/),
which supports app distribution and educational materials for LambdaNative.

Thank you to Benson Muite for guidance and workshop teaching, the LambdaNative
contributors for the framework, and the Learning Lions community for testing,
feedback and contributions.

## License

Expense Tracker is available under the [MIT License](LICENSE). Third-party
framework components and assets retain their respective licenses.
