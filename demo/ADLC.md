# Analytics development lifecycle — dbt and Cursor

Leave-behind for the Field/TAM deck. **dbt** is the warehouse contract. **Cursor** is the role at each stage. We do not distinguish Core vs Fusion in the pitch.

Live today: Agent Chat, prompts **1 → 4 → 10** in [FIELD.md](FIELD.md).  
Told on slides, not clicked: Linear, GitHub Actions, Cloud Agents, Slack.

Cursor does **not** replace the CI runner. dbt still executes `run` / `test` on Snowflake. Agents read artifacts (`run_results.json`, `dbt.log`) when CI exists.

MCP is **out**. Team admin blocks it; CLI + Agent is the demo.

## Stage map

| Stage | Cursor’s role | Persona | Capabilities | dbt still does | Today vs later |
|---|---|---|---|---|---|
| Intake | Turn a ticket into a branch/PR | DE | Cloud Agent, Linear automation, rules | Nothing until there is code | Later |
| Develop | Author and explain models | Architect + DE | Agent Chat, rules/skills, dbt editor extension | Compile/run when asked | **Live (prompt 1)** |
| Test | Treat WARN/ERROR as incidents | DE + Risk | Agent + terminal (`dbt test`) | Executes tests | **Live (prompt 4)** |
| Integrate | Read CI, comment on the PR | Platform | Automation on checks completed, GitHub | CI job runs dbt on a PR schema | Later |
| Review | Blast radius + SQL review | Architect + DE | Bugbot, Agent on the PR | Manifest / exposures in Git | Later (taste in prompt 1) |
| Deploy | Selector-scoped change, not a full rebuild | Platform + DE | Agent | `dbt run --select …` | **Live (prompt 10)** |
| Operate | Job WARN → explain → hotfix PR | Platform + Risk | Cron/webhook, Slack, Cloud Agent | Nightly dbt job | Later |

## What we say out loud

- *dbt runs the warehouse. Cursor ships the change.*
- *We will not open Linear or Actions in this meeting.*
- *The same agent can sit on a ticket and on CI logs the day those exist.*

## Deck generator

Copy [DECK_PROMPT.md](DECK_PROMPT.md) into a new Agent Chat if you need slides from scratch.
