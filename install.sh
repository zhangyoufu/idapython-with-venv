#!/usr/bin/env bash
set -euo pipefail

# find IDA
mapfile -t IDA_APPS < <((find /Applications -maxdepth 1 -type d -name 'IDA *.app'; mdfind 'kMDItemCFBundleIdentifier == "com.hexrays.ida"') | sort -u)
if [[ ${#IDA_APPS[@]} -eq 0 ]]; then
    echo 'IDA not found'
    exit 1
fi
echo 'found IDA:'
for i in "${!IDA_APPS[@]}"; do
    echo "[$i] ${IDA_APPS[$i]}"
done
while true; do
    read -rp 'choose by index [0]: '
    idx="${REPLY:-0}"
    if [[ "${idx}" =~ ^[0-9]+$ ]] && (( idx >= 0 && idx < ${#IDA_APPS[@]} )); then
        IDA_APP=${IDA_APPS[${idx}]}
        break
    fi
    echo 'invalid input'
done
echo "IDA: ${IDA_APP}"

IDAPYSWITCH=${IDA_APP}/Contents/MacOS/idapyswitch

# find libpython
mapfile -t LIBPYTHON_CANDIDATES < <("${IDAPYSWITCH}" --auto-apply --verbose --dry-run | sed -n '/paths:/s/.*paths: //p')
echo 'found libpython:'
for i in "${!LIBPYTHON_CANDIDATES[@]}"; do
    echo "[$i] ${LIBPYTHON_CANDIDATES[$i]}"
done
while true; do
    read -rp 'choose libpython by index or enter absolute .dylib path [0]: '
    idx="${REPLY:-0}"
    if [[ "${idx}" =~ ^[0-9]+$ ]]; then
        if (( idx >= 0 && idx < ${#LIBPYTHON_CANDIDATES[@]} )); then
            LIBPYTHON=${LIBPYTHON_CANDIDATES[${idx}]}
            break
        fi
    elif [[ "${REPLY}" =~ ^/.*\.dylib$ ]] && [ -e "${REPLY}" ]; then
        LIBPYTHON="${REPLY}"
        break
    fi
    echo 'invalid input'
done
echo "libpython: ${LIBPYTHON}"

# build and deploy
cd -- "$(dirname -- "$0")"
make clean
make LIBPYTHON="${LIBPYTHON}"
LIBPYTHON_WITH_VENV=$(realpath libpython_with_venv.dylib)
set -x
"${IDAPYSWITCH}" --force-path "${LIBPYTHON_WITH_VENV}"
