#!/usr/bin/env bash
# Lance xcodebuild en gardant le journal complet en pièce jointe, et n'affiche
# dans la sortie du job que ce qui sert à corriger : erreurs, résultats de
# tests et verdict final.
#
# Usage : xcodebuild.sh <journal> <arguments xcodebuild...>
set -uo pipefail

log="$1"
shift

status=0
xcodebuild "$@" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  DEVELOPMENT_TEAM="" \
  > "$log" 2>&1 || status=$?

echo "----- résumé ($log) -----"
grep -E "error:|Test Case .*(passed|failed)|Test Suite .*(passed|failed)|Executed [0-9]+ test|\*\* (BUILD|TEST) (SUCCEEDED|FAILED) \*\*" "$log" \
  | tail -n 120 || true

if [ "$status" -ne 0 ]; then
  echo "----- premières erreurs en contexte -----"
  grep -n -B 2 -A 6 "error:" "$log" | head -n 200 || true
  echo "----- fin du journal -----"
  tail -n 60 "$log" || true
fi

exit "$status"
