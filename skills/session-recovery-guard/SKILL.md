# session-recovery-guard

## Description
Auto-detects session tool corruption after tool errors and triggers recovery without user intervention. Prevents workflow interruption when sessions become unusable due to "Tool not found" errors despite healthy gateway.

## Trigger
- Tool call returns error response (any tool: browser, exec, web_fetch, etc.)
- Subsequent tool call in same session fails with "Tool not found" or similar I/O error
- Gateway health check confirms gateway is running normally
- Session age < 24 hours (excludes natural expiration)

## Workflow

### 1. Detect Tool Failure Pattern
- Monitor tool call responses for errors
- On first tool error, set internal flag: tool_error_detected = true
- Log error type, timestamp, and tool name to memory

### 2. Verify Session Corruption
- On next tool call attempt, check if error indicates tool unavailability
- Confirm gateway health via session_status or gateway health endpoint
- If gateway healthy but tools unavailable, mark session as corrupted

### 3. Auto-Recovery Sequence
- Pause current task execution
- Send system message: "Detected session tool corruption. Initiating recovery..."
- Trigger session reset via sessions_list/sessions_history to preserve context
- Wait for reset confirmation (max 10 seconds)

### 4. Restore Context
- Reload last 5-10 messages from session history using sessions_history
- Re-initialize tool registry implicitly via new session context
- Verify tool availability with simple test call (e.g., session_status)

### 5. Resume Task
- Notify user: "Session recovered. Resuming [task name]..."
- Retry the failed tool call from step 1
- Continue normal execution

### 6. Log Recovery Event
- Write to memory/YYYY-MM-DD.md:
  - Timestamp
  - Original error type
  - Recovery success/failure
  - Time to recovery

## Verification Checklist

- [ ] Tool error detected within 1 second of occurrence
- [ ] Session corruption confirmed (gateway healthy, tools unavailable)
- [ ] Recovery initiated within 3 seconds of corruption detection
- [ ] All core tools (read, write, exec, browser) available after reset
- [ ] Original task resumes without user re-prompting
- [ ] Recovery event logged to memory file
- [ ] If recovery fails after 2 attempts, escalate to user with exact error

## Fallback

**If auto-recovery fails:**
1. Notify user immediately: "Session recovery failed. Manual reset required."
2. Provide exact reset command or gateway restart instruction
3. Preserve session history to memory file before reset
4. Offer to resume task in new session with context restored

**If corruption recurs >3 times in 24 hours:**
1. Flag as systemic issue
2. Create GitHub issue with error logs
3. Disable auto-recovery, require manual intervention
4. Notify user of pattern and recommended workaround

## Privacy/Safety Notes

- **No data loss:** Session message history preserved before reset
- **User notification:** Always inform user before and after recovery action
- **Bounded retries:** Maximum 2 auto-recovery attempts before escalation
- **No silent resets:** Recovery only triggers on confirmed corruption pattern
- **Audit trail:** All recovery events logged with timestamps and error details
- **No external exposure:** Recovery uses internal APIs only, no external calls

## Evidence Links

- **Source Issue:** https://github.com/openclaw/openclaw/issues/30723
- **Fix PR:** https://github.com/openclaw/openclaw/pull/30735

## Success Metrics

- Recovery success rate: >90% of corrupted sessions recovered automatically
- Time to recovery: <15 seconds from corruption detection to task resume
- User intervention rate: <10% of cases require manual reset
- Task completion rate: >95% of interrupted tasks complete after recovery
- False positive rate: <1% (no recovery triggered on healthy sessions)
