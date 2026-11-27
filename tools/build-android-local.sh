#!/usr/bin/env bash
set -euo pipefail
repo=$(cd "$(dirname "$0")/.." && pwd)
framework=$(cd "${LAMBDANATIVE_DIR:-$repo/../lambdanative}" && pwd)
output="$repo/.local-build/android"
mkdir -p "$output/cache" "$output/state" "$output/sdk-downloads"
docker build -t expense-tracker-android-local:workshop -f "$repo/tools/Dockerfile.android" "$repo/tools"
rm -f "$output/build.exit"
docker run --rm -d --name expense-workshop-android-build \
  -v "$repo:/source:ro" \
  -v "$framework:/framework-source:ro" \
  -v "${XDG_CACHE_HOME:-$HOME/.cache}/lambdanative/packages:/package-source:ro" \
  -v "$output:/work" \
  -v "$output/cache:/root/.cache/lambdanative" \
  -v "$output/state:/root/.lambdanative" \
  -v "$output/sdk-downloads:/root/.cache/sdkmanager" \
  expense-tracker-android-local:workshop bash -c '
    bash /source/tools/build-android-container.sh > /work/build.log 2>&1
    result=$?
    printf "%s\n" "$result" > /work/build.exit
    exit "$result"
  '
echo "Build started. Log: $output/build.log"
echo "Completion status (0 means success): $output/build.exit"
