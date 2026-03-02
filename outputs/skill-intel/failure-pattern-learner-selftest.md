# Failure Pattern Learner Self-Test Report

**Date:** 2026-03-02  
**TaskId:** skill-install-check  
**ErrorText:** tool not found after session lock timeout

---

## LESSONS_MATCHED: 2

### Matched Lesson 1
- **Lesson ID:** LESSON-0e0d6e561b6d
- **Count:** 2
- **Class:** network
- **Signature:** gateway closed (<num> abnormal closure (no close frame)): no close reason; session file locked timeout
- **Action:** Check connectivity and proxy/no_proxy, then retry with reduced scope and explicit timeout.

### Matched Lesson 2
- **Class:** session_or_tool_registry
- **Count:** 3
- **Action:** Detect lock/tool registry corruption first, recover session, then retry tool calls.

---

## File Paths Used

| File | Path |
|------|------|
| Event File | C:\Users\davemelo\.openclaw\workspace\memory\failure-events\2026-03-02.jsonl |
| Playbook | C:\Users\davemelo\.openclaw\workspace\memory\failure-playbook.md |
| Capture Script | skills/local/failure-pattern-learner/scripts/capture-failure.ps1 |
| Build Script | skills/local/failure-pattern-learner/scripts/build-playbook.ps1 |
| Load Script | skills/local/failure-pattern-learner/scripts/load-lessons.ps1 |
| Output Report | C:/Users/davemelo/.openclaw/workspace/bot-output/outputs/skill-intel/failure-pattern-learner-selftest.md |

---

## Execution Summary

1. [OK]capture-failure.ps1 executed - EventFile created with LessonId 0030f885c7c2
2. [OK]build-playbook.ps1 executed - PLAYBOOK_UPDATED
3. [OK]load-lessons.ps1 executed - LESSONS_MATCHED: 2
4. [OK]Report written to output path

