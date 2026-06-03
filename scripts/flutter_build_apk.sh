#!/usr/bin/env bash
set -euo pipefail

if [ ! -f .env ]; then
  echo "Missing .env in project root." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

required=(
  POSTGRES_HOST
  POSTGRES_PORT
  POSTGRES_DB
  POSTGRES_USER
  POSTGRES_PASSWORD
  SENDER_EMAIL
  BREVO_API_KEY
  OPENAI_API_KEY
)

missing=0
for key in "${required[@]}"; do
  if [ -z "${!key:-}" ]; then
    echo "Missing required .env value: $key" >&2
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

flutter build apk --release \
  --dart-define=POSTGRES_HOST="$POSTGRES_HOST" \
  --dart-define=POSTGRES_PORT="$POSTGRES_PORT" \
  --dart-define=POSTGRES_DB="$POSTGRES_DB" \
  --dart-define=POSTGRES_USER="$POSTGRES_USER" \
  --dart-define=POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  --dart-define=SENDER_EMAIL="$SENDER_EMAIL" \
  --dart-define=BREVO_API_KEY="$BREVO_API_KEY" \
  --dart-define=OPENAI_API_KEY="$OPENAI_API_KEY"
