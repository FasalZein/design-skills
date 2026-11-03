# Retro scripts

Two scripts measure how design and design-builder child sessions used design-craft. Run them after each batch of design runs, then compare against the last batch.

## Run

```
bash evals/retro/index.sh                      # writes ~/.pi/artifacts/retro/sessions.tsv
bash evals/retro/compliance.sh 2026-10-23T13   # sessions since that start time
```

Both take optional arguments: `index.sh [OUT.tsv]`, `compliance.sh [SINCE] [sessions.tsv]`. Set `PI_SESSIONS_DIR` to read sessions from a folder other than ~/.pi/agent/sessions. They need `jq` and `rg`. Relative paths resolve against your current directory. Both exit 1 on an unreadable input, a failed write or a `PARSE_FAIL` row; a valid empty index exits 0. Tests: `bash evals/retro/tests/run-tests.sh` (scripts/verify.sh runs them).

## What they count

- **Skills returned**: a skill counts as loaded only when its text came back in a tool result: a frontmatter block that holds its `name:` line and a `description:` line, in any order (or a `name:` line directly followed by `description:`), or a named-section read of its SKILL.md whose result holds a markdown heading, or a read of one file under `skills/<skill>/references/` whose returned lines match that file on disk (at least 3 lines of 8 or more characters, and at least half of the returned lines). A SKILL.md or reference path in a call argument alone does not count: the read can fail, the tool-result cap can cut it, or the path names a template.
- **Passes**: the `<pass> -> applied: <change>` and `<pass> -> n/a: <fact>` entries of the PASSES field, kept with name, status and change. The source is the last `write` of the report artifact that the final RESULT message names in ARTIFACT; without one, the final message. The first entry may sit on the PASSES: line. An unfilled template entry (an empty change, or one that starts with `<`) is not an outcome; `<` and `>` later in a change are text. A report changed only by `edit` or `bash` after its last `write` is read as of that write.
- **Result**: the final RESULT message's value; a template line with `|` alternatives reads `none`.
- **Cost, peak context, duration, errors** from the session's assistant messages. A session with a timestamp that jq cannot parse gets a `PARSE_FAIL` row, also when it is the only timestamp.
- **Owner corrections**: `followups` (user messages after the launch brief) and `asks` (ask_user tool calls, direct or as `tools.ask_user(` inside codemode; prose mentions do not count).
- **Checks**: scanner runs, screenshots, agent-browser-chrome versus plain agent-browser commands, typecheck runs.

The summary groups runs by agent and model. Compare `zero_skill_runs`, `skills_mean`, cost and peak context with the previous batch.
