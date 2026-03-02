# Fixed Task Set

Run these repeatedly so scores are comparable.

## Task A
Create a small output file with 3 concrete facts and evidence links.
Pass condition: facts + links + file exists.

## Task B
Recover from one injected failure and complete fallback path.
Pass condition: failure logged + fallback output created + verification exists.

## Task C
Update one report in `outputs/<date>-<project>/` and append index entry.
Pass condition: changed report, updated INDEX.md, and links are valid.

---

# New Experiments (2026-03-02)

## Task D: Reflexion-Style Reflection Loop
**Source:** arXiv:2303.11366 (Reflexion v4)  
**Hypothesis:** Structured verbal reflection after each task improves completion rate by 10%+

**Steps:**
1. Complete one task from Task A/B/C
2. Write reflection to `memory/reflections/YYYY-MM-DD-task-<id>.md` using REFLECTION_TEMPLATE.md
3. Include: what was attempted, what succeeded/failed, what would be done differently, one concrete lesson
4. Before next task, read last 3 reflections for pattern matching

**Pass condition:** Reflection file exists + contains all 4 required sections + next task references at least one prior lesson

**Evidence:** Reflection file path + lesson applied in subsequent task

---

## Task E: Voyager-Style Skill Library
**Source:** arXiv:2305.16291 (Voyager v2) + mini-SWE-agent (100-line pattern)  
**Hypothesis:** Composable skill library reduces task execution time by 30%+ on recurring patterns

**Steps:**
1. Identify one recurring task pattern (e.g., PowerShell file operations, evidence verification)
2. Create executable skill script in `skills/local/library/<skill-name>/script.ps1`
3. Document: inputs, outputs, verification step, usage example
4. Use skill in next matching task and measure time delta vs prior attempts

**Pass condition:** Skill script exists + documented + used in at least one task + execution time recorded

**Evidence:** Skill file path + usage evidence in task output + timing comparison

---

*Tasks D and E added 2026-03-02 from weekly-research-sync. Evaluate 2026-03-16 (Task D) and 2026-03-30 (Task E).*