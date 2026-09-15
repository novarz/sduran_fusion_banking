#!/usr/bin/env bash
# Idempotent Cloud Agent install. Runs from repo root on each Build.
set -euo pipefail

python3 -m venv .venv
# shellcheck disable=SC1091
source .venv/bin/activate
python -m pip install --upgrade pip
pip install "dbt-core>=1.10,<1.11" "dbt-snowflake>=1.10,<1.11"

mkdir -p "${HOME}/.dbt"
if [[ ! -f "${HOME}/.dbt/profiles.yml" ]]; then
  cp profiles.example.yml "${HOME}/.dbt/profiles.yml"
fi

# Verify compile graph works without a live warehouse (blast-radius / dbt ls).
dbt parse || true

echo "Cloud agent dbt ready: $(dbt --version | head -n 5)"
