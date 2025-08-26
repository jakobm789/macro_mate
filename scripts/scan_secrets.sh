#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker is required to run secret scan" >&2
  exit 1
fi

docker run --rm -v "$PWD:/repo" -w /repo trufflesecurity/trufflehog:latest filesystem --results=verified,unknown .
