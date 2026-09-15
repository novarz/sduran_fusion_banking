# Field / TAM — Banco Fusión (dbt + Snowflake)

Private Field/TAM copy of the retail-banking dbt demo. Use this to show Cursor
on a real warehouse: architecture, a live test warning, a regulatory TAE fix,
and a CI/deploy conversation.

**Audience:** Data Architect, Data Engineer, DevOps (or a mixed buying committee).  
**Runtime:** ~12 minutes for prompts 1 → 4 → 10. Optional encore: 5 (TAE). Full set is below if you have a longer slot.  
**Stack:** dbt Core + `dbt-snowflake` against Snowflake (Fusion/`dbtf` is fine if installed).

This is **not** an internalsphere web app. Clone it in Cursor and drive Agent Chat.

---

## Before the meeting (5 minutes)

```bash
git clone https://github.com/anysphere/fusion-banking-dbt-demo.git
cd fusion-banking-dbt-demo
python3 -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
python -m pip install --upgrade pip
pip install dbt-core dbt-snowflake
```

Copy [profiles.example.yml](../profiles.example.yml) to `~/.dbt/profiles.yml`.
The project profile name **must** be `analytics` (see `dbt_project.yml`).

Use a **personal or shared Field Snowflake schema** (`ANALYTICS_<you>`), not a
shared `ANALYTICS` if two people might `dbt run` at once.

```bash
source .venv/bin/activate
dbt debug && dbt seed && dbt run && dbt test
```

Expected last time we ran it:

| Command | Result |
|---|---|
| `dbt debug` | connection OK |
| `dbt seed` | 6/6 (100 customers, 25 branches, 30 products, 110 accounts, 268 tx, 40 loans) |
| `dbt run` | 18/18 |
| `dbt test` | 52 PASS, **1 WARN** |

**Leave the warning in place** until you run Prompt 4 live. It is the demo.

Enable the **dbt** Cursor plugin (marketplace) if you want Agent skills
(`running-dbt-commands`, `adding-dbt-unit-test`, …). Do **not** use dbt MCP
(blocked by team admin). CLI is enough.

Lifecycle map and slide prompt: [ADLC.md](ADLC.md), [DECK_PROMPT.md](DECK_PROMPT.md).

---

## Live order

**Default 12-minute set**

| # | Role | Prompt | What the room should see |
|---|---|---|---|
| 1 | Architect | 1 | Colored warehouse + dashboard ownership |
| 2 | Engineer | 4 | Live test warning → 8-row table → fix → green tests |
| 3 | DevOps | 10 | Loan-path selector graph (no full rebuild) |

**Encore (Risk / Compliance):** Prompt 5 (TAE vs origination fees).  
**Skip in a short demo:** Prompts 2, 3, 6–9, 11 (workshop material, not the live show).

Copy-paste the prompts below into Agent Chat. Use a terminal **without** a Core venv if you are on Fusion (`dbtf`), or activate `.venv` if you are on Core.

---

## Data Architect

### Prompt 1 — Warehouse walkthrough for Risk & Marketing

```
You are the data architect for Banco Fusión, a Spanish retail bank.

Walk a mixed audience (Risk, Marketing, Branch Ops) through this dbt project.
Do NOT dump file lists. Produce a visual brief:

1. A Mermaid flowchart of the warehouse:
   seeds (raw_*) → staging (stg_*) → intermediate (int_*) → marts (dim_*, fct_*, rpt_*) → exposures.
   Color-code layers. Annotate grain on each mart (one row per customer / transaction / loan / branch / product / product+region).

2. A second Mermaid diagram for the three exposures in models/marts/_models.yml:
   - customer_analytics_dashboard
   - loan_portfolio_report
   - branch_performance_report
   Show owners, maturity, and which models each dashboard depends on.

3. Call out one architectural risk: fct_loans is a thin wrapper over int_loan_enriched
   (TAE and risk_level live in intermediate, not in the fact). Explain why that
   is good or dangerous for a regulated bank, in 4 bullets max.

Keep the whole answer presentation-ready. No code unless it supports a diagram.
```

### Prompt 2 — Semantic Layer as the contract with BI

```
You are the data architect. Looker / a BI tool will query this project via the
dbt Semantic Layer — they must NOT write SQL against fct_loans directly.

Read models/marts/_semantic_models.yml end to end.

Deliver:
1. A Mermaid ER-style diagram of the 3 semantic models (sm_customers, sm_transactions,
   sm_loans): primary/foreign entities, time dimensions, and 2–3 key categorical
   dimensions each.
2. A table of the 23 metrics grouped as Customer / Transactions / Loans.
   For derived metrics (net_transaction_flow, commission_rate, default_rate,
   loan_amortization_ratio) write the formula in plain language AND the expr.
3. A "gotcha" callout: completed_transactions, credit_volume and debit_volume
   filter is_excluded_from_metrics = false. Explain why that exists by looking
   at fct_transactions (reversed / fraud) and tests/assert_transactions_exclude_reversed.sql.
4. One slide-worth recommendation: which 5 metrics would you put on an
   executive homepage and why.

Visual first. No YAML dumps.
```

### Prompt 3 — Blast radius of changing fct_loans

```
You are reviewing a change request: "recalculate TAE in fct_loans to include
origination fees (Bank of Spain)."

Before anyone touches SQL, produce an impact / lineage brief:

1. Mermaid lineage: every model, test, metric, and exposure that would break
   or change if fct_loans.tae or int_loan_enriched.tae changes.
   Start from int_loan_enriched → fct_loans → rpt_loan_risk_summary,
   then fan out to average_tae, high_risk_loan_amount, loan_portfolio_report.

2. A RACI-style table:
   Artifact | Type (model/test/metric/exposure) | Owner | What changes | Severity
   Pull owners from the exposures YAML where they exist.

3. A 5-line go/no-go: is this a marts-only change, or does it have to land in
   int_loan_enriched first because fct_loans just selects le.tae?

Use dbt ls --select +int_loan_enriched,+fct_loans if useful. Show the graph,
not the raw CLI dump.
```

---

## Data Engineer

### Prompt 4 — Production warning: 8 unclassified loans

```
You are on-call data engineer. CI just reported:

  Warning in test no_default_classification_int_loan_enriched_risk_level__Sin_clasificar
  Got 8 results, configured to warn if != 0

This is a live quality issue in Banco Fusión's loan risk classification.

Work it like a real incident, in this order:

1. Run: dbt test --select no_default_classification_int_loan_enriched_risk_level__Sin_clasificar
   Show the warning, not the full 53-test suite.

2. Read models/intermediate/int_loan_enriched.sql (the risk_level CASE)
   and models/intermediate/_int_models.yml (the test config, severity: warn).
   Explain WHY completed loans fall into else 'Sin clasificar'.

3. Query the 8 rows (loan_id, status, remaining_balance, start_date, risk_level)
   via dbt show or compiled SQL. Put them in a table.

4. Propose the CASE fix so:
   - defaulted → Alto
   - active + low amortization + old vintage → Medio
   - active → Bajo
   - completed → Nulo   (YAML already documents "Nulo" as valid)
   Do not invent extra statuses.

5. Apply the fix, then:
   dbt run --select int_loan_enriched+
   dbt test --select int_loan_enriched fct_loans rpt_loan_risk_summary
   Show before/after: warning gone, and a tiny before/after count of risk_level.

Present it as an incident write-up: Symptom → Root cause → Fix → Verification.
```

### Prompt 5 — Regulatory defect: TAE ignores origination fees

```
You are a data engineer pairing with Compliance.

Spanish TAE (Tasa Anual Equivalente) must reflect the real cost of credit,
including origination fees. Today int_loan_enriched.sql computes TAE from TIN only:

  round((power(1 + (interest_rate / 100 / 12), 12) - 1) * 100, 2)

rpt_loan_risk_summary even flags this: tae_tin_spread is described in the YAML as
low values possibly meaning omitted fees (Spanish: "Valores bajos indican posible omisión de comisiones.").

Treat this as a regulatory defect, not a refactor:

1. Show current TAE vs interest_rate for 5 sample loans (dbt show on fct_loans).
   Highlight how small the spread is.

2. Implement the demo-agreed fix in int_loan_enriched.sql: treat origination fee
   as +1.0 percentage points on the rate:
     power(1 + ((interest_rate + 1.0) / 100 / 12), 12)
   Keep it as a clearly commented approximation (this is a demo bank, not a
   full IRR engine). Update the YAML descriptions for tae on int_loan_enriched
   and fct_loans, and the tae_tin_spread description if needed.

3. Rebuild only the loan path:
   dbt run --select int_loan_enriched+
   dbt test --select int_loan_enriched fct_loans rpt_loan_risk_summary

4. Produce a Compliance slide:
   - formula before / after
   - 3-row sample: loan_id | TIN | TAE old | TAE new | spread
   - what rpt_loan_risk_summary.avg_tae and metric average_tae will now show
   - residual risk: this is still not a true TAE (no insurance, no IRR)

Do not touch unrelated models.
```

### Prompt 6 — Missing mart: branch commercial KPIs

```
Commercial leadership asked for a weekly branch scorecard. dim_branches already
has total_customers, total_deposits, total_loans_outstanding — but they also
want activity and a loans-to-deposits ratio, and they want it tested.

You are the data engineer. Design and ship int_branch_kpis (intermediate)
that the existing branch_performance_report could later consume.

Requirements:
- Grain: one row per branch_id
- Inputs: stg_branches, stg_customers or dim_customers, stg_accounts,
  fct_loans / stg_loans, fct_transactions (completed only)
- Columns at minimum:
  branch_id, branch_name, region,
  total_customers, total_deposits, active_loans, outstanding_loan_balance,
  completed_tx_count, completed_tx_volume, loan_to_deposit_ratio
- YAML: unique + not_null on branch_id; short Spanish or English descriptions
- Do not duplicate dim_branches; this is the KPI enrichment layer

Then:
  dbt run --select int_branch_kpis
  dbt test --select int_branch_kpis
  dbt show --select int_branch_kpis --limit 8

End with a Mermaid snippet showing how this would plug into
branch_performance_report next to dim_branches and fct_transactions.
```

### Prompt 7 — Data-quality fire drill

```
You are the data engineer running the monthly quality review for Banco Fusión.

The singular tests in tests/ encode real Spanish-retail-bank rules:

- assert_positive_account_balance
  savings/deposit accounts must not go negative (credit cards can)
- assert_transactions_exclude_reversed
  reversed/fraud tx must be flagged is_excluded_from_metrics
- assert_loan_default_rate_threshold
  default_rate > 5% on products with >= 15 loans → warn (Bank of Spain-style)
- assert_valid_customer_segment
  Young < 30, Senior > 60 — warn if segment vs age is incoherent

Do this as a fire drill, not a lecture:

1. dbt test --select test_type:singular
2. For each test: one sentence business rule, severity (error vs warn),
   PASS/WARN/FAIL, and which model it reads.
3. If anything warns or fails, diagnose with dbt show / compiled SQL.
   Put failing grain (product_id, customer_id, transaction_id) in a table.
4. Rank the four tests by "if this were live, who pages?" (Risk / Ops / Marketing).
5. Recommend ONE test that should be promoted from warn → error before go-live,
   and one that should stay warn, with a one-line reason each.

Output as a quality-review slide deck in markdown (tables + 1 mermaid of test → model).
```

---

## DevOps

### Prompt 8 — Pre-prod health check, executive one-pager

```
You are DevOps preparing a go-live checklist for this dbt project
on Snowflake (see profiles.yml: database / schema / warehouse).

Run the full path against the existing profile `analytics` / target `dev`:

  dbt debug
  dbt seed
  dbt run
  dbt test
  dbt docs generate

Then produce an executive one-pager:

| Stage | Command | Duration | PASS | WARN | ERROR | Verdict |
plus:
- Adapter + dbt-core versions
- Object counts: 18 models, 6 seeds, 53 tests, 3 exposures, 23 metrics, 3 semantic models
- Known accepted warning (if still present): unclassified loans / TAE
- Is it production-ready? Use: Green / Amber / Red with 3 bullets max
- Top 2 operational risks (e.g. overly broad Snowflake role, Python 3.9, dbt 1.10 deprecated)

Do not paste full logs. Extract timings from the "Finished running … in …" lines.
```

### Prompt 9 — PR gate: GitHub Actions for a regulated warehouse

```
You are DevOps. This repo must not run dbt against prod from a PR.

Design a GitHub Actions workflow (.github/workflows/dbt-ci.yml) that:

On pull_request:
1. Checkout, set up Python 3.11 (not 3.9 — call that out)
2. python -m venv .venv && pip install dbt-core dbt-snowflake
3. Write a CI profiles.yml from secrets:
   SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_PASSWORD, SNOWFLAKE_ROLE,
   SNOWFLAKE_DATABASE, SNOWFLAKE_WAREHOUSE
   Force schema: CI_{{ github.head_ref sanitized }} or ANALYTICS_CI so
   engineers never clobber ANALYTICS.
4. dbt parse && dbt seed --full-refresh && dbt run && dbt test
5. Fail the job on ERROR; print a clear summary of WARN (do not fail on warn yet)
6. Upload target/run_results.json as an artifact

Also:
- A short comment in the YAML: never commit profiles.yml or .env
- A secrets checklist table for the GitHub repo settings
- Explain why we compile+run on a CI schema instead of dbt compile only
  (this project has SQL tests that need data)

Show the full YAML, then a Mermaid of the pipeline stages.
Do not invent a Snowflake account — use placeholder secret names.
```

### Prompt 10 — Hotfix deploy: only the loan path

```
You are DevOps. Prod is green except fct_loans / TAE. We must NOT rebuild
customer staging or 268 transaction rows.

Using this project's graph:

1. Show the subgraph with:
     dbt ls --select int_loan_enriched+ --output name
     dbt ls --select +fct_loans --output name
   Render it as Mermaid (not a raw list).

2. Propose the exact production commands, in order, with why each selector:
   - dbt run --select int_loan_enriched+          # rebuild enriched → facts → rpt
   - dbt test --select int_loan_enriched+         # tests downstream of the change
   Contrast with dbt run --select marts which would skip int_loan_enriched
   (a trap, because TAE is calculated there).

3. Rollback plan: what to revert (git + dbt run --select …) if rpt_loan_risk_summary
   avg_tae jumps in a way Compliance did not sign off.

4. A change window table: estimated runtime based on the last local run
   (~10s for 18 models; loan path should be a subset).

This is a deployment playbook, not a tutorial on dbt selectors.
```

### Prompt 11 — Docs, coverage, and alerting

```
You are DevOps / analytics platform. Leadership wants "we can observe this
warehouse" before the Banco Fusión demo.

1. Run dbt docs generate. Summarize what landed in target/ (manifest, catalog).
   Do not start dbt docs serve unless asked.

2. Coverage audit as tables:
   - Models with vs without description in YAML
     (staging/_stg_models.yml, intermediate/_int_models.yml, marts/_models.yml)
   - Tests by severity: error vs warn (include the four singular tests
     and no_default_classification)
   - Exposures missing a url or owner (there shouldn't be any — verify)

3. Propose a CI alerting policy in a table:
   Signal | Source | Threshold | Page who | Channel
   Include: dbt test ERROR, dbt test WARN on int_loan_enriched, default_rate
   metric, job runtime > 15 min, docs generate failure.

4. One mermaid: "happy path" nightly job vs "warn path" (Slack only) vs
   "error path" (page Risk + Data Eng).

Keep it visual and opinionated. No generic observability essay.
```

---

## Presenter notes

- **Do not pre-fix** `int_loan_enriched` risk_level or TAE. Prompt 4 and 5 are the show.
- After a dry run, `git checkout -- models/intermediate/int_loan_enriched.sql` (and YAML) so the next meeting starts dirty again.
- Seed data is Spanish (DNI, autonomous communities, Bank of Spain). Lean into that with Risk/Compliance buyers. Prompts stay in English.
- Do not demo dbt MCP. CLI + Agent Chat is enough.
- Source of the warehouse models: personal demo `novarz/sduran_fusion_banking`. This org copy is the Field/TAM one.
