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
