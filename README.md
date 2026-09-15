# Banco Fusión — retail banking dbt demo

Fictional Spanish retail bank warehouse for **Cursor Field / TAM** demos. Models, tests, exposures, and a Semantic Layer on Snowflake.

**Presenter guide (English):** **[demo/FIELD.md](demo/FIELD.md)** — setup plus Architect / Engineer / DevOps prompts. Do **not** fix the `risk_level` warning or TAE before the meeting.

**Lifecycle / deck:** [demo/ADLC.md](demo/ADLC.md) · [demo/DECK_PROMPT.md](demo/DECK_PROMPT.md)

## What’s in the warehouse

- **100** customers across Spain
- **25** branches
- **30** products (accounts, cards, loans, investments)
- **110** accounts
- **268** sample transactions
- **40** loans (mortgage, personal, auto, student)

Layers: seeds (`raw_*`) → staging (`stg_*`) → intermediate (`int_*`) → marts (`dim_*`, `fct_*`, `rpt_*`) → exposures.

## Project layout

```
fusion-banking-dbt-demo/
├── models/
│   ├── staging/          # cleaned sources
│   ├── intermediate/     # business logic (TAE and risk_level live here)
│   └── marts/            # dims, facts, risk summary, semantic models
├── seeds/                # CSV sources
├── tests/                # singular data-quality tests
├── demo/
│   ├── FIELD.md          # Field/TAM script and copy-paste prompts
│   └── *.html            # static dashboard mockups
├── profiles.example.yml
└── dbt_project.yml
```

## Demo storylines

1. **Customer segmentation** — CLV-style value, geography, Premium / Standard / Young / Senior
2. **Loan book** — default rates, Bank of Spain-style thresholds, TAE vs TIN
3. **Branch performance** — deposits, customers, transactions per branch

The live quality beat is a **warn** on `int_loan_enriched.risk_level` (`Sin clasificar` for completed loans). The TAE formula is TIN-only until Prompt 5.

## Quick start

See [demo/FIELD.md](demo/FIELD.md) for the full presenter path. Short version:

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install dbt-core dbt-snowflake
# copy profiles.example.yml → ~/.dbt/profiles.yml (profile name: analytics)
dbt debug && dbt seed && dbt run && dbt test
```

Or use **dbt Fusion** (`dbtf`) if you have it installed.

## Exposures

Defined in `models/marts/_models.yml`:

| Dashboard | Use | Models |
|-----------|-----|--------|
| customer_analytics_dashboard | Marketing / personal banking | dim_customers, fct_transactions |
| loan_portfolio_report | Risk / Bank of Spain narrative | rpt_loan_risk_summary, dim_customers, dim_products |
| branch_performance_report | Commercial leadership | dim_branches, fct_transactions |

## Spain localization

Spanish names, DNI/NIE format, real autonomous communities, retail products, Bank of Spain default-rate / TAE language. YAML descriptions in the models may still be Spanish; **all presenter prompts are English**.

## Requirements

- dbt Core 1.5+ **or** dbt Fusion, plus the Snowflake adapter/connection
- `profiles.yml` with profile `analytics`

Internal demo — Field / TAM use.
