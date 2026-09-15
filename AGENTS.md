# Agent notes

## Cursor Cloud specific instructions

Cloud Agents start from `.cursor/environment.json` (Ubuntu image + `.cursor/install.sh`).

- Activate dbt: `source .venv/bin/activate`
- Profile name is `analytics` (`profiles.example.yml` is copied to `~/.dbt/profiles.yml` if missing). That is enough for **`dbt parse`** and **`dbt ls`** (blast radius). Do **not** `dbt run` / `dbt test` against Snowflake unless secrets are configured in the Cloud Agent dashboard.
- Do not use dbt MCP (`disableAllMcpServers` is true).
- Blast radius on a changed model `X`:
  - Downstream: `dbt ls --select X+`
  - Upstream: `dbt ls --select +X`
  - Both: `dbt ls --select +X+`
  - Metrics: `dbt ls --resource-type metric --select +X+`
  - Then read `exposures` in `models/marts/_models.yml`
- Presenter script: `demo/FIELD.md`. Lifecycle map: `demo/ADLC.md`.
