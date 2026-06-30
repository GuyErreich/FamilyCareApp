#!/usr/bin/env bash
# Sync Google OAuth from supabase/.env to Supabase Auth.
# Hosted (default): supabase config push — applies [auth.external.google] from config.toml.
# Local: LOCAL=1 restarts the Docker stack.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ENV_FILE="supabase/.env"
LOCAL="${LOCAL:-0}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE — copy supabase/.env.example and fill in Google credentials."
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

if [[ -z "${SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID:-}" ]]; then
  echo "Set SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID in $ENV_FILE"
  exit 1
fi

if [[ -z "${SUPABASE_AUTH_EXTERNAL_GOOGLE_SECRET:-}" ]]; then
  echo "Set SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_SECRET in $ENV_FILE"
  exit 1
fi

push_hosted_auth_config() {
  local ref="$1"
  local output exit_code
  set +e
  output="$(supabase config push --yes 2>&1)"
  exit_code=$?
  set -e
  echo "$output"

  if [[ $exit_code -eq 0 ]]; then
    return 0
  fi

  # CLI >=2.100 fails after auth when Storage API omits databasePoolMode (supabase/cli#5726).
  if echo "$output" | grep -qE "Remote Auth config is up to date|Updating Auth service"; then
    if echo "$output" | grep -q "failed to read Storage config"; then
      echo ""
      echo "Note: Auth config was applied. Storage step failed due to a known Supabase CLI bug — safe to ignore."
      return 0
    fi
  fi

  echo "config push failed (exit $exit_code)"
  return "$exit_code"
}

project_ref() {
  if [[ -f supabase/.temp/project-ref ]]; then
    cat supabase/.temp/project-ref
  fi
}

auth_settings_url() {
  if [[ -f web/.env.local ]]; then
    grep -E '^VITE_SUPABASE_URL=' web/.env.local | cut -d= -f2- | tr -d '\r'
    return
  fi
  local ref
  ref="$(project_ref)"
  if [[ -n "$ref" ]]; then
    echo "https://${ref}.supabase.co"
  fi
}

auth_anon_key() {
  if [[ -f web/.env.local ]]; then
    grep -E '^VITE_SUPABASE_ANON_KEY=' web/.env.local | cut -d= -f2- | tr -d '\r'
    return
  fi
  local ref
  ref="$(project_ref)"
  if [[ -n "$ref" ]]; then
    supabase projects api-keys --project-ref "$ref" -o json \
      | python3 -c "
import json, sys
keys = json.load(sys.stdin)
for k in keys:
    if k.get('type') == 'publishable':
        print(k['api_key'])
        break
else:
    for k in keys:
        if k.get('name') == 'anon':
            print(k['api_key'])
            break
"
  fi
}

verify_google() {
  local url key response enabled
  url="$(auth_settings_url)"
  key="$(auth_anon_key)"
  if [[ -z "$url" || -z "$key" ]]; then
    echo "Skipping verify (set web/.env.local or link a hosted project)."
    return 0
  fi
  response="$(curl -fsS -H "apikey: ${key}" "${url}/auth/v1/settings")"
  enabled="$(python3 -c "import json,sys; print(json.load(sys.stdin).get('external',{}).get('google', False))" <<<"$response")"
  if [[ "$enabled" == "True" ]]; then
    echo "Google provider: enabled"
  else
    echo "Google provider: still disabled — check $ENV_FILE and config.toml, then re-run this task."
    exit 1
  fi
}

print_gcp_reminders() {
  local ref
  ref="$(project_ref)"
  echo ""
  echo "Google Cloud Console — Authorized redirect URIs (Web OAuth client):"
  if [[ -n "$ref" && "$LOCAL" != "1" ]]; then
    echo "  https://${ref}.supabase.co/auth/v1/callback"
  fi
  echo "  http://127.0.0.1:54321/auth/v1/callback  (local Supabase)"
  echo ""
  echo "JavaScript origins for Vite: http://localhost:5173 , http://127.0.0.1:5173"
}

if [[ "$LOCAL" == "1" ]]; then
  echo "Restarting local Supabase to apply Google OAuth from $ENV_FILE ..."
  supabase stop && supabase start
  verify_google
  print_gcp_reminders
  exit 0
fi

ref="$(project_ref)"
if [[ -z "$ref" ]]; then
  echo "Not linked to a hosted project. Run: supabase link --project-ref <ref>"
  echo "For local only: LOCAL=1 task supabase:auth:google"
  exit 1
fi

echo "Pushing auth config (including Google) to hosted project: $ref"
push_hosted_auth_config "$ref"

verify_google
print_gcp_reminders
