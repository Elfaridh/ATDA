#!/usr/bin/env bash
set -euo pipefail

if rg -n "^(<<<<<<<|=======|>>>>>>>)" . --glob '!*package-lock.json' --glob '!*pnpm-lock.yaml' --glob '!*yarn.lock'; then
  echo "Conflict markers detected. Resolve merge conflicts first."
  exit 1
fi

echo "No merge conflict markers found."
