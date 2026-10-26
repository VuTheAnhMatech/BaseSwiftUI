# AI Execution Gates

Follow root `AGENTS.md` for routing, impact, instruction safety, and build rules.

1. Questions remain read-only. Announce implementation scope briefly.
2. Read `WORKFLOW_AI.md` only for architecture/data-flow decisions; select the
   relevant branch, not the entire workflow for ordinary screen wiring.
3. Keep one primary skill and reuse unchanged context. Local items and routine
   route/Factory entries alone do not require architecture or model references.
4. Apply only checks relevant to the changed behavior. Report source checks,
   build evidence, and runtime checks separately; compilation is not visual QA.

For repeated/list UI, default to `BaseDataSource` and the closest Base view.
Ask a blocking question only when repository evidence cannot resolve a choice
that materially changes the result.
