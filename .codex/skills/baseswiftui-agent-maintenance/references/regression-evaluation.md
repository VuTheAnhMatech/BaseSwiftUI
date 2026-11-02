# Skill regression evaluation

Adapt evaluation ideas from Prompt Optimizer, DeepEval, and One-Eval without
adding an LLM benchmark runtime to the iOS project.

## Evaluation loop

1. Establish the current routing result as the baseline.
2. Use `assets/routing-cases.json` as the committed dataset. Add a case for
   every reported miss and every new trigger boundary.
3. Run a smoke subset first: one positive case, one adjacent-skill case, and
   one negative case for each changed skill.
4. Score separately:
   - trigger precision: unrelated prompts do not select the skill;
   - trigger recall: intended prompts select it;
   - routing correctness: the most specific skill wins;
   - instruction fidelity: project constraints survive execution;
   - artifact validity: files, frontmatter, references, and metadata validate.
5. Change one causal area at a time, rerun the same cases, and compare with the
   baseline. Do not lower acceptance rules merely to make a revision pass.
6. Stop when the changed cases pass and unchanged cases do not regress. Record
   uncertainty when no agent invocation harness is available.

## Evidence contract

Keep input prompts once; do not duplicate long context. Store expected routing
and constraints, not a full desired answer. A failure report names the case,
observed route, expected route, and smallest likely prompt/skill change.

Deterministic file validation is not behavioral evaluation. When available,
forward-test routing in fresh agent sessions that see the skill and raw task,
not the intended answer.

## Small-project routing probes

Use the Vietnamese cases for explanation, a local UI edit, one Figma screen
with wiring, debugging, and shared-contract work. Keep the actual prompt
natural; do not tell the evaluated agent which skill or mode should win.
The JSON defines expected primary/mode, forbidden companion skills, required
and forbidden references, and operation limits. `expected: null` explicitly
means no project skill, no skill references, and no mode. Missing `expected`
is an error. File/metadata validation does not execute those prompts.

Compare the same prompts on equivalent checkouts before/after a router change,
with the same model and MCP/tool setup. Record cold/warm build state; keep the
DerivedData strategy consistent. For each run, capture the transcript/tool log,
loaded skills/references, time to first edit, MCP time, build time, and total
elapsed time. Use repeated runs and compare per-case medians, not a mixed-task
average. Accept speed improvements only if scope, correctness, fidelity, and
necessary verification are preserved. Do not automatically launch paid runs,
parallel agents, builds, or simulator sessions from the validator.

Store observations outside the repo (for example `/private/tmp/routing-runs.json`)
and check them with:

```sh
python3 .codex/skills/baseswiftui-agent-maintenance/scripts/validate_agent_setup.py --observations /private/tmp/routing-runs.json
```

Format example only, not measured evidence:

```json
{"runs":[{
  "case_id":"figma-screen-wiring-vi",
  "run_id":"unique-session-id",
  "model":"actual-model-and-effort",
  "revision":"actual-checkout-revision-plus-dirty-state",
  "evidence":"path-or-link-to-the-session-log",
  "primary":"baseswiftui-figma-ui",
  "mode":"screen",
  "loaded_skills":["baseswiftui-figma-ui"],
  "loaded_references":[".codex/skills/baseswiftui-swiftui-ui/references/navigation-ownership.md"],
  "counts":{"builds":1,"edits":4,"index_refreshes":0,"design_context_calls":1},
  "timings_seconds":{"total":120,"mcp":15,"build":30,"first_edit":25}
}]}
```

Count all build attempts, editing tool calls, GitNexus refreshes and Figma
design-context calls from the trace, including failed attempts. Zero limits
for read-only probes are strict. A legitimate compiler fix or changed design
can exceed a budget: preserve the counts and explain the exception in the
review; do not hide it to obtain a pass. Evidence fields are provenance, not
proof: a reviewer must inspect the linked trace. The checker reports observed
coverage separately; its own unit tests use synthetic records and never count
as behavioral evaluations. Without real records, report routing/latency NOT RUN.

`loaded_references` is required, even when empty. List canonical repo-relative
paths for project skill references actually read, including reused context.
Record a no-skill run with `primary: null`, no mode (or `mode: null`), and empty
`loaded_skills`/`loaded_references`. Do not silently convert older observation
records that lack reference evidence; recover it from the transcript first.

## Ten-entry quality boundary

Simple source explanations bypass skills; specialist diagnosis still selects
a mode. Model ownership and complete guidelines are conditional architecture
references. Source review, debug/test, API maintenance and Instruments remain
distinct modes of swiftui-review; choosing one does not preload the others.
The dataset includes read-only diagnosis, test plans, existing-trace analysis,
and no-build API audits to protect authorization boundaries.

For bounded-reading changes, compare ordinary entitlement icons, exact-node
icons, paywall sale copy, and changed unlock behavior. The first two reuse
existing state with UI/Figma; the latter two keep IAP ownership. Inspect the
transcript for why each extra file/reference was needed, reuse of unchanged
evidence, and retained build/impact gates. These are manual observations, not
properties proven by dataset validation. Changed source/design, new failures,
or uncertain ownership require fresh evidence and relevant checks; reuse must
not hide a stale result. Do not enforce an arbitrary file-read ceiling.

The ten entry points cover this repo only; global/system/plugin skills are
outside this count. Fewer descriptions reduce discovery text, but do not
prove fewer billed tokens or lower task latency. Keep app-quality evidence
separate from router/checker tests and measure real tasks before making claims.

## Figma evidence and correction probes

Use the partial-context, asset-mismatch, no-export, post-build-correction, and
font-fallback cases to review actual transcripts. Check that:

- Additional MCP calls resolve a named gap in the relevant node/property;
  child-node inspection stays `quick` without unrelated screen traversal.
- Existing assets are checked for visual match and usable resolution before
  reuse/export. A no-export request leaves mismatches reported, not downloaded.
- Further Swift edits trigger another build, even after a successful build;
  unchanged design evidence is reused rather than fetched again.
- Font fallback names the requested/used families and remaining fidelity gap;
  successful compilation is not claimed as visual equality.

Cases with recovery or iterative correction omit a fixed call/build ceiling;
this does not excuse redundant work. Assess necessity from the transcript.
The validator checks routing/count declarations, not these visual or causal
properties. Do not report them as passed without actual session evidence.

## Duo adaptation probes

Use `duo-*` cases for `adapt` versus read-only `assess`, unavailable SDKs,
hidden secondary panes, BaseDataSource continuity and existing screen wiring.
Adjacent cases keep exact-node Figma, IAP, architecture and general SDK audits
with their owners; incidental device mentions and ordinary responsive work do
not activate Duo. Owners may read one Duo reference without loading its skill.

Inspect the real artifact for iOS 17/Swift 5 compatibility, one stable Container
and data source, accessible secondary actions, preserved scroll/draft/navigation,
and no new-API symbols hidden only behind runtime guards on an incapable SDK.
Check actual content/window fit instead of a fixed canvas-height scroll rule,
while retaining exact-node visual fidelity. No automatic Simulator, toolchain
download, CI change or upstream script execution. The case checker does not
prove any of these behaviors; compare real runs before claiming speed gains.

## Adaptive-window probes

New-screen and responsive-change cases read the shared UI adaptive-window
reference while keeping one primary skill. Cover iPad dragging, a short
keyboard-visible Figma window, all-device Duo work, paywalls and normal new
screens. An incidental device mention or label-only edit must not preload
the reference. Source checks protect iOS 17, stable Container/data-source
ownership, legal/action access and one scroll owner. Actual resizing, keyboard
and continuity observations require an explicitly authorized runtime session.
