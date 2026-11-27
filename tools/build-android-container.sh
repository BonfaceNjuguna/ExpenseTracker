#!/usr/bin/env bash
set -euo pipefail
# Runs inside the local Fedora builder. /work and /root caches are persistent.
cd /work
mkdir -p /root/.cache/lambdanative/packages
cp -an /package-source/. /root/.cache/lambdanative/packages/
if [ ! -d lambdanative ]; then
  mkdir lambdanative
  tar -C /framework-source --exclude=.git -cf - . | tar -C lambdanative -xf -
fi
mkdir -p lambdanative/apps/ExpenseTracker
cp -a /source/ExpenseTracker/. lambdanative/apps/ExpenseTracker/
sdk=/work/android-sdk
export ANDROID_HOME="$sdk"
export ANDROID_SDK_ROOT="$sdk"
mkdir -p "$sdk"
# Reuse downloaded packages and SDK/NDK components on subsequent builds.
for component in 'platforms;android-28' 'build-tools;29.0.3' tools 'ndk;21.4.7075529' platform-tools; do
  if [ "$component" = 'ndk;21.4.7075529' ] && [ ! -f "$sdk/ndk/21.4.7075529/source.properties" ]; then
    ndk_zip=/root/.cache/sdkmanager/android-ndk-r21e-linux-x86_64.zip
    mkdir -p /root/.cache/sdkmanager
    if ! unzip -tq "$ndk_zip" >/dev/null 2>&1; then
      curl --fail --location --retry 5 --retry-all-errors --continue-at - \
        --output "$ndk_zip" https://dl.google.com/android/repository/android-ndk-r21e-linux-x86_64.zip
      unzip -tq "$ndk_zip" >/dev/null
    fi
  fi
  echo yes | sdkmanager --sdk_root="$sdk" "$component"
done
echo yes | sdkmanager --sdk_root="$sdk" --licenses
# The framework only needs this support JAR, not the obsolete Maven archive.
support_jar="$sdk/extras/android/support/v4/android-support-v4.jar"
if [ ! -s "$support_jar" ]; then
  mkdir -p "$(dirname "$support_jar")"
  curl --fail --location --retry 3 -o /work/support-v4-23.4.0.aar \
    https://dl.google.com/dl/android/maven2/com/android/support/support-v4/23.4.0/support-v4-23.4.0.aar
  unzip -p /work/support-v4-23.4.0.aar classes.jar > "$support_jar"
fi
cd lambdanative
cp SETUP.template SETUP
cat >> SETUP <<SETUP
ANDROIDAPI=28
ANDROIDSDK="$sdk"
ANDROIDNDK="$sdk/ndk/21.4.7075529"
SETUP
cp PROFILE.template PROFILE
sed -i 's|SYS_ORGSLD="yourdomainhere"|SYS_ORGSLD="workshop.yourdomainhere"|' PROFILE
sed -i 's|SYS_ANDROIDPW="yoursecrethere"|SYS_ANDROIDPW="android"|g' PROFILE
# Give local phone tests their own package, preserving the installed baseline.
sed -i 's|android:label="@string/app_name"|android:label="ExpenseTracker Workshop"|g' loaders/android/AndroidManifest.xml.in
# Keep the signing key across local builds so updates retain app data.
if [ -f /work/android.keystore ]; then cp /work/android.keystore android.keystore; fi
sed -i 's|SYS_CC="gcc $SYS|SYS_CC="gcc-14 $SYS|g' targets/linux/host_linux
sed -i 's|gcc -Werror|gcc-14 -Werror|g' targets/linux/check-libraries
perl -i -0777 -pe 's/\(c-lambda\s*\(int\)\s*int\s*"clipboard_clear"\)/(c-lambda () int "clipboard_clear")/gs' modules/clipboard/clipboard.scm
sed -i 's/--disable-shared --enable-static/--disable-shared --disable-static/' libraries/libjpeg/make.sh
# Use the installed GNU config helper instead of an obsolete HTTP download.
python3 - <<'PY'
from pathlib import Path
recipe = Path('libraries/libjpeg/make.sh')
lines = recipe.read_text().splitlines()
recipe.write_text('\n'.join('cp /usr/share/automake*/config.sub .' if 'wget -O config.sub' in line else line for line in lines) + '\n')
PY
sed -i -E 's/\bpython3*\b/python3/g' targets/android/check-tools
./configure ExpenseTracker linux
make
mkdir -p /root/.cache/lambdanative/android/support
./configure ExpenseTracker android debug
make
if [ -f android.keystore ]; then cp android.keystore /work/android.keystore; fi
if [ -f /root/.lambdanative/android.keystore ]; then cp /root/.lambdanative/android.keystore /work/android.keystore; fi
mkdir -p /work/apk
cp /root/.cache/lambdanative/packages/ExpenseTracker-*-android*.apk /work/apk/
echo "Local APK ready in .local-build/android/apk"
