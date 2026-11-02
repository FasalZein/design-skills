# Retro scripts

Two scripts measure how design and design-builder child sessions used design-craft. Run them after each batch of design runs, then compare against the last batch.

## Run

```
bash evals/retro/index.sh                      # writes ~/.pi/artifacts/retro/sessions.tsv
bash evals/retro/compliance.sh 2026-10-23T13   # sessions since that start time
```

Both take optional arguments: `index.sh [OUT.tsv]`, `compliance.sh [SINCE] [sessions.tsv]`. Set `PI_SESSIONS_DIR` to read sessions from a folder other than ~/.pi/agent/sessions. They need `jq` and `rg`.

## What they count

- **Skills returned**: a skill counts as loaded only when its text came back in a tool result, found by its frontmatter `name:` line followed by a `description:` line. A SKILL.md path in a call argument does not count: the read can fail, the tool-result cap can cut it, or the path names a template.
- **Passes**: the `-> applied:` and `-> n/a:` lines in the final report's PASSES block.
- **Cost, peak context, duration, errors** from the session's assistant messages.
- **Owner corrections**: `followups` (user messages after the launch brief) and `asks` (ask_user calls).
- **Checks**: scanner runs, screenshots, agent-browser-chrome versus plain agent-browser commands, typecheck runs.

The summary groups runs by agent and model. Compare `zero_skill_runs`, `skills_mean`, cost and peak context with the previous batch.
