#!/usr/bin/env bash
# Idempotent Cloud Agent install. Runs from repo root on each Build.
set -euo pipefail

python3 -m venv .venv
# shellcheck disable=SC1091
source .venv/bin/activate
python -m pip install --upgrade pip
# dbt-core 1.12 pulls in dbt-core-experimental-parser, whose sdist downloads a
# prebuilt wheel from GitHub Releases at install time (dbt-core#15670). That host
# is not in our egress allowlist, so pin 2.0.0a4 which ships real wheels on PyPI.
# This caps dbt-core at 1.12.0 (later 1.12.x require the GitHub-download parser).
pip install "dbt-core-experimental-parser==2.0.0a4" "dbt-core>=1.12,<1.13" "dbt-snowflake>=1.12,<1.13"

mkdir -p "${HOME}/.dbt"
if [[ ! -f "${HOME}/.dbt/profiles.yml" ]]; then
  cp profiles.example.yml "${HOME}/.dbt/profiles.yml"
fi

# Verify compile graph works without a live warehouse (blast-radius / dbt ls).
dbt parse || true

echo "Cloud agent dbt ready: $(dbt --version | head -n 5)"
