# Agent notes

## Cursor Cloud specific instructions

Cloud Agents start from `.cursor/environment.json` (Ubuntu image + `.cursor/install.sh`).

- Activate dbt: `source .venv/bin/activate`
- Profile name is `analytics` (`profiles.example.yml` is copied to `~/.dbt/profiles.yml` if missing). It reads credentials from env vars with safe defaults, so that is enough for **`dbt parse`** and **`dbt ls`** (blast radius). Do **not** `dbt run` / `dbt test` against Snowflake unless secrets are configured.
- Live Snowflake runs need these Secrets (right-hand Secrets panel): `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PASSWORD`, `SNOWFLAKE_ROLE`, `SNOWFLAKE_DATABASE`, `SNOWFLAKE_WAREHOUSE`, `SNOWFLAKE_SCHEMA`. Egress `*.snowflakecomputing.com` is in `.cursor/environment.json`.
- dbt is pinned to 1.12 in `.cursor/install.sh`; `dbt-core-experimental-parser==2.0.0a4` is pinned so the install works offline (see the comment there / dbt-core#15670).
- Do not use dbt MCP (`disableAllMcpServers` is true).
- Blast radius on a changed model `X`:
  - Downstream: `dbt ls --select X+`
  - Upstream: `dbt ls --select +X`
  - Both: `dbt ls --select +X+`
  - Metrics: `dbt ls --resource-type metric --select +X+`
  - Then read `exposures` in `models/marts/_models.yml`
- Presenter script: `demo/FIELD.md`. Lifecycle map: `demo/ADLC.md`.
