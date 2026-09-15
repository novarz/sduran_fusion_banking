# Prompt — generate the Field/TAM slide deck

Paste the block below into Agent Chat. English output. 8–9 slides.

```
Design a Field/TAM deck titled:

**Analytics development lifecycle with dbt and Cursor**

Thesis: dbt is the warehouse contract. Cursor is the role the team plays at each ADLC stage. Map every stage to (1) Cursor’s job, (2) primary persona, (3) required Cursor capabilities. One line on what dbt still does in that stage.

English. 8–9 slides. Audience knows dbt. Say dbt, never Core vs Fusion. MCP is out.

LIVE TODAY: prompts 1 → 4 → 10 only (Develop / Test / Deploy) from demo/FIELD.md.
TOLD: Intake, Integrate, Review-at-scale, Operate — same map, label “not shown today.”

Use this mapping (do not drop stages):

| Stage | Cursor’s role | Persona | Capabilities | dbt still does |
| Intake | Turn a ticket into a branch/PR | DE | Cloud Agent, Linear automation, rules | Nothing until code exists |
| Develop | Author and explain models | Architect + DE | Agent Chat, rules/skills, dbt extension | Compile/run when asked |
| Test | Treat WARN/ERROR as incidents | DE + Risk | Agent + terminal (dbt test) | Executes tests |
| Integrate | Read CI, comment, don’t run prod | Platform | Automation on checks completed, GitHub | CI job runs dbt |
| Review | Blast radius + SQL review | Architect + DE | Bugbot, Agent on the PR | Manifest / exposures in Git |
| Deploy | Selector-scoped change, not full rebuild | Platform + DE | Agent (Prompt 10) | dbt run --select … |
| Operate | Job WARN → explain → hotfix PR | Platform + Risk | Cron/webhook, Slack, Cloud Agent | Nightly dbt job |

Banco Fusión proof: 18 models, 53 tests, intentional risk_level WARN. Repo: this project. Presenter script: demo/FIELD.md. Lifecycle map: demo/ADLC.md.

Slides:
1. Thesis
2. Mermaid of 7 stages (dbt vs Cursor on arrows)
3. The map table — stage | persona | Cursor role | capabilities | live vs told
4. Zoom TODAY: 1, 4, 10
5. Zoom LATER: Intake + Integrate + Operate (3 boxes)
6. What we won’t click + Cursor does not replace the CI runner
7. Proof + CTA

Speaker notes in italics. On later-stage slides: “We will not open Linear or Actions today.”
Markdown slides separated by ---.
Leave-behind = the map table only.
No images.
```
