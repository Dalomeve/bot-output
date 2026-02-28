# evidence-link-auditor Examples

Practical examples of using the evidence-link-auditor skill for various audit scenarios.

## Example 1: Full Directory Audit

**Scenario**: Validate all links and markers in a completed task output directory.

**Command**:
```bash
openclaw skill evidence-link-auditor --target ./outputs/2026-03-01-xtrending
```

**Expected Output**:
```markdown
## Audit Report: 2026-03-01-xtrending

**Status**: PASS
**Date**: 2026-03-01T01:30:00Z
**Files Scanned**: 12
**Links Checked**: 47
**Links Passed**: 47
**Links Failed**: 0
**Markers Found**: 0

### Summary
All evidence links verified successfully. No unresolved markers detected.
Ready for merge.
```

---

## Example 2: Single File Check

**Scenario**: Verify links in a specific verification report before publishing.

**Command**:
```bash
openclaw skill evidence-link-auditor --file ./outputs/2026-03-01-xtrending/report/verification.md
```

**Expected Output**:
```markdown
## File Audit: verification.md

**Status**: FAIL
**Links Checked**: 8
**Links Passed**: 7
**Links Failed**: 1

### Failed Links
| Line | URL | Status | Error |
|------|-----|--------|-------|
| 23 | https://github.com/Dalomeve/xtrending-20260301/commit/abc123 | 404 | Not Found |

### Action Required
Fix broken commit link on line 23 before publishing.
```

---

## Example 3: Marker-Only Scan

**Scenario**: Check for incomplete work in claimed-finished deliverables.

**Command**:
```bash
openclaw skill evidence-link-auditor --markers-only --target ./outputs/2026-03-01-self-evolution
```

**Expected Output**:
```markdown
## Marker Scan Results

**Files Scanned**: 8
**Markers Found**: 3

### Unresolved Markers

#### File: task-a-attempt2.md
- **Line 15**: `TODO: Implement retry logic for failed API calls`
- **Line 42**: `PENDING: Awaiting user confirmation on approach`

#### File: implementation.md
- **Line 88**: `TBD: Final performance benchmarks`

### Recommendation
Remove or resolve markers before marking task complete.
```

---

## Example 4: Pre-Merge Validation

**Scenario**: Automated check before merging bot output to main branch.

**Command**:
```bash
openclaw skill evidence-link-auditor --target ./outputs/latest --report-only --format json > audit-report.json
```

**Expected Output** (JSON):
```json
{
  "audit_date": "2026-03-01T01:45:00Z",
  "target": "./outputs/latest",
  "status": "PASS",
  "links_checked": 156,
  "links_passed": 156,
  "links_failed": 0,
  "markers_found": 0,
  "failed_links": [],
  "unresolved_markers": [],
  "recommendations": ["Consider adding SSL expiry monitoring for external links"]
}
```

---

## Example 5: GitHub Evidence Verification

**Scenario**: Validate all GitHub links (commits, PRs, issues) in output.

**Command**:
```bash
openclaw skill evidence-link-auditor --target ./outputs/2026-03-01 --github-only
```

**Expected Output**:
```markdown
## GitHub Link Verification

**Status**: PASS
**GitHub Links Checked**: 24

### Link Types
- Commit links: 12 [OK]
- PR links: 6 [OK]
- Issue links: 4 [OK]
- Repository links: 2 [OK]

### Verification Details
All commit hashes exist in respective repositories.
All PR/Issue numbers are valid and accessible.
No 404 errors on GitHub resources.
```

---

## Example 6: CI/CD Integration

**Scenario**: Add to GitHub Actions workflow for automated validation.

**Workflow Snippet** (`.github/workflows/validate.yml`):
```yaml
name: Evidence Link Validation

on:
  pull_request:
    paths:
      - 'outputs/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Evidence Link Auditor
        run: |
          openclaw skill evidence-link-auditor \
            --target ./outputs \
            --format json \
            --output audit-results.json
      
      - name: Check Results
        run: |
          STATUS=$(jq -r '.status' audit-results.json)
          if [ "$STATUS" != "PASS" ]; then
            echo "Audit failed. Review audit-results.json"
            exit 1
          fi
```

---

## Example 7: Scheduled Quality Audit

**Scenario**: Weekly automated audit of all outputs.

**Cron Job**:
```bash
# Run every Monday at 9 AM
0 9 * * 1 openclaw skill evidence-link-auditor --target ~/.openclaw/workspace/bot-output/outputs --report-only --email-report team@example.com
```

**Report Email Subject**: `Weekly Evidence Audit Report - 2026-03-01 - PASS`

---

## Example 8: Link Health Dashboard

**Scenario**: Generate ongoing link health metrics for monitoring.

**Command**:
```bash
openclaw skill evidence-link-auditor --target ./outputs --format json | jq '.links_failed' > link-health-metrics.json
```

**Metrics Tracked**:
- Total links over time
- Failure rate trend
- Most common failure domains
- Average response times
- SSL certificate expiry alerts

---

## Best Practices

1. **Run before merges**: Always audit before merging bot outputs
2. **Fix immediately**: Address failed links before they accumulate
3. **Document exceptions**: If a link is expected to fail, document why
4. **Regular audits**: Schedule periodic scans even without changes
5. **Version control**: Keep audit reports with corresponding outputs

## Common Issues & Resolutions

| Issue | Cause | Resolution |
|-------|-------|------------|
| 404 on commit link | Wrong hash or force-push | Verify hash, update link |
| TODO markers found | Incomplete work | Complete or remove marker |
| SSL error | Certificate expired | Contact site admin or find alternative |
| Timeout | Slow/unreachable server | Increase timeout or mark as external dependency |
| Internal link broken | File moved/renamed | Update relative path |
