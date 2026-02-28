# Self-Evolution Loop (OpenClaw)

This folder defines a repeatable improvement loop for the agent.

Cycle steps:
1. Run one task from `TASKSET.md`.
2. Produce output with evidence.
3. Run critique using `CRITIQUE_TEMPLATE.md`.
4. Write one reusable rule into `memory/tasks.md` and `SCOREBOARD.md`.
5. Retry same task once with improved rule.
6. Compare pass/fail delta.

Success metric:
- Weekly completion rate improves.
- Mid-task stall rate decreases.
- Evidence quality remains verifiable.