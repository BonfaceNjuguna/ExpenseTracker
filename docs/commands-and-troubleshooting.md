# Commands and troubleshooting

Commands assume Bash on Bonface's Linux workstation unless a section says
otherwise. Run commands from the app repository root. Do not paste the commands
inside Scheme's REPL. Replace example paths/IDs before using them.

## 1. Preflight from the repository root

On this workstation:

```sh
cd /home/boni/Documents/Development/expense-tracker/LambdaNativeQuickStart
pwd
git branch --show-current
git status --short
command -v gsi
command -v gsc
command -v gcc
command -v python3
command -v make
command -v unzip
```

Expected branch: `improved-expense-income-tracker`. Existing uncommitted changes
are intentional. Do not reset, clean, switch branches or commit just to run the
workshop. Learners should use their own clones when practicing Git writes.

Inspect the sibling framework and available output:

```sh
git -C ../lambdanative rev-parse HEAD
ls ExpenseTracker
ls .local-build/linux/ExpenseTracker
```

The pinned framework revision is
`b6e82ee343d8ea3c95e277d7e122baae9a5dc096`. A source checkout may also have local
compatibility patches; revision alone does not describe those modifications.

### Dependencies and fresh machines

The local scripts reuse the prepared sibling framework, caches and configuration.
They are not complete dependency installers for every fresh laptop.

- Scheme practice: Gambit (`gsi`).
- Integration tests: Gambit compiler (`gsc`), C compiler and SQLite headers/library.
- Linux app: configured LambdaNative checkout, native development libraries,
  font/image build tools and a graphical display.
- Local Android: Docker daemon access, free disk space and downloads for the
  Fedora image, SDK, NDK and framework libraries.
- Phone testing: ADB, a data-capable USB cable and an authorized Android device.

For Ubuntu, a starting point for Scheme/test dependencies, if installation is
actually needed, is:

```sh
sudo apt update
sudo apt install gambc build-essential pkg-config libsqlite3-dev
```

These do not constitute all LambdaNative Linux GUI build dependencies. Use the
prepared workstation/hosted artifact rather than spending the first session
installing a full native toolchain on every participant's computer.

## 2. Scheme practice and app integration tests

```sh
gsi docs/examples/scheme-practice.scm
./tests/run.sh
```

The first script is standalone language practice. The second compiles the pinned
framework's SQLite binding into a temporary module, uses a real temporary SQLite
database and replaces GUI rendering with test objects. It does not touch the
preview's saved transactions. It checks migration, exact cents, custom categories,
CRUD, cancellation, recent-ten limiting, filters and persistence.

If the framework is elsewhere:

```sh
LAMBDANATIVE_DIR=/absolute/path/to/lambdanative ./tests/run.sh
```

A passing test run does not demonstrate that a widget is visible, a phone keypad
works or Android permissions are correct. Those need manual checks.

## 3. Build and run the Linux preview

```sh
./tools/build-linux.sh
./.local-build/linux/ExpenseTracker/ExpenseTracker
```

Alternative framework location:

```sh
LAMBDANATIVE_DIR=/absolute/path/to/lambdanative ./tools/build-linux.sh
```

The helper copies app source into the framework, patches X11 wheel events,
configures a Linux debug build, builds it, and extracts the package into
`.local-build/linux`. It preserves the preview database when extracting updates.

Build output and application logs are different:

```sh
tail -n 80 .local-build/linux/build.log
ls -lt .local-build/linux/ExpenseTracker/log
```

Choose the newest application log from that listing and read it, for example
`tail -n 80 .local-build/linux/ExpenseTracker/log/ACTUAL_LOG_FILENAME` after
replacing the placeholder. Look for initialization markers and exception text.

The executable may keep running and hold the terminal. Exit the app normally
before rebuilding/replacing it. Reopening the file in your editor does not
refresh an already running executable.

### Inspect the preview database without modifying it

If the SQLite CLI is installed:

```sh
sqlite3 -readonly .local-build/linux/ExpenseTracker/expense.sqlite '.schema transactions'
sqlite3 -readonly -header -column .local-build/linux/ExpenseTracker/expense.sqlite \
  'SELECT rowid,type,amount_cents,category,description,created_at FROM transactions ORDER BY rowid DESC LIMIT 10;'
```

Do not use these commands before the app has created the database. Avoid showing
real descriptions or contact data on the shared screen. Do not modify the
database by hand during a UI test; use the application's create/edit/delete flow.

To make a simple backup, first close the Linux app, then:

```sh
backup_dir=$(mktemp -d "$PWD/.local-build/database-backup.XXXXXX")
cp .local-build/linux/ExpenseTracker/expense.sqlite "$backup_dir/expense.sqlite"
printf 'Backup directory: %s\n' "$backup_dir"
```

Closing the app first avoids copying a live database without its journal state.
For fresh demo data, use a separate executable directory as described in the
[walkthrough](app-walkthrough.md#3-before-sharing-the-screen), rather than deleting
the existing database.

## 4. Build Android locally

```sh
docker version
./tools/build-android-local.sh
```

This starts a detached container named `expense-workshop-android-build`. The
launcher finishing successfully only means the build was started. Monitor:

```sh
tail -f .local-build/android/build.log
```

Ctrl+C stops following the log, not the Docker build. In a second terminal:

```sh
docker ps --filter name=expense-workshop-android-build
if [ -f .local-build/android/build.exit ]; then
  cat .local-build/android/build.exit
else
  echo 'No completion status yet; inspect the build log and container.'
fi
```

Completion status `0` means success; another value means failure. A missing exit
file can also follow an interrupted container, so check both the log and Docker.
The container uses `--rm`; it normally disappears after completion.

Expected APK after a successful build:

```text
.local-build/android/apk/ExpenseTracker-1.0-android-api28.apk
```

If VERSION changes, inspect the actual filename:

```sh
ls -lh .local-build/android/apk
```

An old APK may still be in the directory after a later failed build. Check the
exit file and modification time before installing. Do not start two builds with
the same container name or write to its log while it runs.

The first build can be lengthy and consume substantial disk space. Downloads,
SDK/NDK, source builds, signing key and caches are reused under `.local-build`.
Prepare this beforehand; it is unsuitable as a guaranteed quick live build.

## 5. Connect the phone with ADB

On this workstation, ADB was installed locally. From this repository root:

```sh
export PATH="$PWD/../.local-tools/platform-tools:$PATH"
adb version
adb devices -l
```

If `adb` is installed system-wide, no PATH addition is needed. The path above
depends on the repository root; running the same `$PWD` expression from your
home directory points somewhere else.

On the phone: enable Developer options and USB debugging, connect a data-capable
cable, unlock the display and review the USB authorization prompt.

| Device listing | Meaning / next step |
|---|---|
| No device | Check cable, USB port, unlock state and host USB detection |
| `unauthorized` | Review the debugging authorization on the phone |
| `offline` | Reconnect; check the ADB server and phone state |
| `no permissions` | Check host udev/USB access configuration |
| `device` | ADB transport is authorized; this is not yet an app health check |

`android-sdk-platform-tools-common` alone supplies host integration/rules, not
necessarily an `adb` executable. `command -v adb` and `adb version` verify the
actual executable.

If multiple devices are attached, use `adb -s SERIAL ...` with the serial from
`adb devices -l`. Do not accidentally install to a different device.

## 6. Install and launch the Workshop APK

These commands assume exactly one authorized device. Keep it unlocked to review
any installation verification/permission prompts:

```sh
adb install -r .local-build/android/apk/ExpenseTracker-1.0-android-api28.apk
adb shell am start -W -n com.yourdomainhere.workshop.expensetracker/.ExpenseTracker
adb shell pidof com.yourdomainhere.workshop.expensetracker
```

`-r` requests replacement while retaining data when the package/signature are
compatible. The build helper retains its local signing key for this reason.
Package name and signing identity both matter; changing a key can prevent an
update. Do not uninstall as a casual fix, because that can remove app data.

The Workshop package differs from the baseline
`com.yourdomainhere.expensetracker`; installing one does not update the other.
Confirm which icon/package you are demonstrating.

If installation fails with verification failure, unlock the phone and review
the actual prompt before retrying. Do not disable verification globally or
assume the error proves an app-code defect.

## 7. Capture crashes and Scheme exceptions

To observe a fresh launch without erasing existing device logs:

```sh
adb logcat -b all -v threadtime > .local-build/android/phone-logcat.txt
```

While this runs, launch the app in another terminal or tap it on the phone.
After reproducing the problem, Ctrl+C stops capture. Search locally:

```sh
rg -n 'FATAL EXCEPTION|Fatal signal|UnsatisfiedLinkError|dlopen failed|ExpenseTracker' \
  .local-build/android/phone-logcat.txt
```

A Scheme exception may close the app without a Java FATAL EXCEPTION. Pull the
app's own logs as well:

```sh
adb pull /sdcard/Android/data/com.yourdomainhere.workshop.expensetracker/files/log \
  .local-build/android/phone-app-logs
```

Look for “ExpenseTracker: initializing” and “ExpenseTracker: initialized”. The
directory may be missing if startup failed before logging was enabled, or if
the platform disallows that access. Do not interpret a missing log as success.

Device characteristics:

```sh
adb shell getprop ro.build.version.release
adb shell getprop ro.product.cpu.abilist
adb shell getconf PAGE_SIZE
unzip -Z1 .local-build/android/apk/ExpenseTracker-1.0-android-api28.apk
```

The Pixel 7 requires a compatible 64-bit ARM library. A ZIP listing with
`lib/arm64-v8a/` entries shows packaging, not full proof of runtime compatibility.
Collect the actual linker/native error before choosing a fix.

Optional screenshot of the app while visible:

```sh
adb exec-out screencap -p > .local-build/android/phone-app.png
```

Review it locally before sharing; screenshots and device logs can include
unrelated personal information. These generated files stay under ignored output.

## 8. GitHub Actions and downloading an existing artifact

Current workflow: `.github/workflows/build.yml`, name `fedora-build`.
It runs on pushes to `main` and `improved-expense-income-tracker`, and pull
requests targeting `main`. It also declares `workflow_dispatch` for manual runs.
Use the improved branch for the review build; do not merge into main just to build.

Read-only CLI checks, if GitHub CLI is already authenticated:

```sh
gh auth status
gh run list --workflow build.yml --branch improved-expense-income-tracker --limit 5
```

Set an actual run ID from that list:

```sh
run_id=REPLACE_WITH_RUN_ID
gh run view "$run_id"
gh run view "$run_id" --log-failed
gh run download "$run_id" -n apk -D .local-build/github-artifact
```

The `apk` artifact contains an APK and `apk-info.txt` with SDK/ABI metadata. A
separate `linux` artifact contains the Linux app ZIP. Only a successful run that
uploaded these files provides usable downloads.
Use the run's commit/branch to distinguish old baseline output from the improved
branch. The GitHub workflow retains the default app identity; the local Docker
helper separately uses the Workshop package. Inspect `apk-info.txt` for the APK
you actually download rather than assuming its package name. GitHub cannot build unpushed changes. Do not push simply because
the local docs show how Actions works.

Browser path: repository → Actions → selected run → Artifacts → apk. See
[GitHub's artifact guide](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/download-workflow-artifacts).

## 9. Symptom-to-action reference

| Symptom | Useful next check |
|---|---|
| `gsi main.scm` says unbound variable | GUI/module/build setup is missing; use the app build helper |
| New UI does not appear | Correct branch/source? Rebuild? Running an old executable/package? |
| Font symbol missing | Compare source names with FONTS and regenerate resources |
| Linux categories do not scroll | Rebuild using the wheel-patched helper; use picker Up/Down or drag |
| Clicking Other fields behaves strangely | Verify conditional layout recalculates `nodemap` |
| Integer versus flonum error in form header | Preserve `headerh 88.0` for this pinned uiform |
| Linux works but Android exits | Capture Android plus app logs; inspect ABI and platform initialization |
| Old-Android privacy warning | Inspect target SDK separately from build API; warning alone is not a crash diagnosis |
| No records after opening the app | Wrong package/data directory or active Activity filter? |
| Edited entry disappears from filtered Activity | Its new type may no longer match; inspect All |
| Build log stalls at a download | Check the exact URL/network/error; avoid restarting all caches blindly |
| Container name already exists | Check whether a build is still active before starting another |
| Docker permission error | Check daemon access with the host administrator; do not change socket permissions blindly |
| Tests cannot find SQLite headers | Install development headers or verify existing Linux cache fallback |
| `Permission denied` running helper | Check executable bit and file location; do not run the entire app as root |

## 10. Pre-demo checkpoint

- [ ] Known branch and source revision; no unwanted Git operations.
- [ ] Language examples and app integration checks pass.
- [ ] Linux build exists and opens.
- [ ] Android exit status is 0 before using its APK.
- [ ] Phone is authorized and unlocked if needed.
- [ ] Correct app package, fictional dataset and expected balance.
- [ ] Alternative plan: screenshots/prebuilt app if USB, network or build fails.
