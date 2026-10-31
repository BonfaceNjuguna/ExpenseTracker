# Expense Tracker

A LambdaNative expense tracker. GitHub Actions builds Linux and Android debug versions using the framework revision pinned in `.github/workflows/build.yml`.

## Rebuild and check

Push the changes to `main` (or open a pull request against it). Download the new `apk` artifact from that workflow run and install the APK inside it. The artifact also includes `apk-info.txt`, which lists the package name, minimum SDK, target SDK, and native architectures. The workflow requires an `arm64-v8a` library for Pixel 7.

`ANDROIDAPI=28` sets LambdaNative's minimum/native build API. The pinned framework separately declares target SDK 31 in `loaders/android/AndroidManifest.xml.in`. Installing a newer SDK alone does not update that manifest. Raising the target SDK requires reviewing and testing the corresponding Android behavior changes.

The font list must generate every font used during initialization: `ascii_14.fnt`, `ascii_18.fnt`, `ascii_24.fnt`, and `ascii_40.fnt`. The form uses the pinned framework's flat widget sequence (`label`, `list`, `button`, etc.) and its `size` attribute.

## Capture startup failures on a Pixel

1. On your phone, open **Settings > About phone**, tap **Build number** seven times, then enable **USB debugging** in **Settings > System > Developer options**.
2. Install [Android SDK Platform Tools](https://developer.android.com/tools/releases/platform-tools) on your computer. Connect your phone by USB and accept the debugging prompt.
3. In a terminal, run:

   ```sh
   adb devices
   adb logcat -b all -c
   adb logcat -b all -v threadtime > expense-crash.txt
   ```

4. While that last command runs, open Expense Tracker on the phone. After it closes, press **Ctrl+C** in the terminal. `expense-crash.txt` contains the captured logs. Look for `FATAL EXCEPTION`, `Fatal signal`, `UnsatisfiedLinkError`, or `dlopen failed`. A Scheme exception can exit the process without a Java crash, so also collect the framework logs below.

The updated app enables LambdaNative logs before database/UI initialization. With the default build profile, retrieve them with:

```sh
adb pull /sdcard/Android/data/com.yourdomainhere.expensetracker/files/log expense-logs
```

If the package name in `apk-info.txt` differs, replace `com.yourdomainhere.expensetracker`. Logs should contain initialization markers and Scheme exception backtraces. If the app exits before Scheme initialization, this directory may not exist; the Android logs are then essential.

For native compatibility diagnostics, also collect:

```sh
adb shell getprop ro.build.version.release
adb shell getprop ro.product.cpu.abilist
adb shell getconf PAGE_SIZE
```

## Local Scheme checks

With Gambit installed, run from the repository root:

```sh
gsi -e '(with-exception-catcher (lambda (e) (display-exception e) (exit 1)) (lambda () (load "tests/startup.scm")))'
```

These checks mock Android/OpenGL and SQLite calls. They cover initialization, empty totals, saving, apostrophe escaping, invalid amounts, query failures, and shutdown. GitHub also runs them before building. A successful build still requires a launch test on the device.
