# evidence-link-auditor Skill

Automated skill for auditing evidence links in task outputs, verifying link validity, and checking for unresolved markers.

## Triggers

Activate this skill when:
- User requests link verification for task outputs
- Pre-merge validation is needed for bot-generated content
- Quality assurance check on evidence artifacts
- Manual audit of external references in documentation
- Periodic health check on output integrity

## Workflow

### Phase 1: Discovery
1. Scan target directory for markdown files
2. Extract all URLs and hyperlinks from content
3. Identify internal references (relative paths, anchors)
4. Catalog external links by domain/type

### Phase 2: Validation
1. Check each external link for accessibility (HTTP status)
2. Verify internal links resolve to existing files
3. Detect redirect chains and final destinations
4. Measure response times for performance baseline

### Phase 3: Marker Detection
1. Search for unresolved markers: `PENDING`, `TODO`, `TBD`
2. Flag incomplete sections or placeholder content
3. Identify draft states and work-in-progress indicators
4. Report marker locations with context

### Phase 4: Reporting
1. Generate pass/fail summary
2. List broken or suspicious links
3. Document unresolved markers with line numbers
4. Provide remediation recommendations

## Pass/Fail Checks

### PASS Criteria (all must be true)
- [ ] All external links return HTTP 200 or valid redirect (3xx)
- [ ] All internal links resolve to existing files/anchors
- [ ] No unresolved markers (PENDING, TODO, TBD) in final deliverables
- [ ] No 4xx/5xx errors on critical links
- [ ] Link count matches expected artifacts

### FAIL Conditions (any triggers failure)
- [ ] Any link returns 404, 403, or 5xx error
- [ ] Internal reference points to non-existent file
- [ ] Unresolved markers found in claimed-complete work
- [ ] SSL certificate errors on HTTPS links
- [ ] Timeout on link validation (>10 seconds)

## Unresolved Marker Checks

Search patterns (case-insensitive):
- `PENDING` - awaiting action or decision
- `TODO` - incomplete implementation
- `TBD` - to be determined/decided
- `FIXME` - known issue requiring fix
- `XXX` - attention needed
- `HACK` - temporary workaround

Marker report format:
```
File: path/to/file.md
Line: 42
Marker: TODO
Context: "TODO: Add error handling for edge cases"
Severity: warning|error (based on section criticality)
```

## Link Verification Checklist

### External Links
- [ ] URL syntax is valid (proper scheme, domain, path)
- [ ] Domain is reachable and not parked/suspended
- [ ] HTTPS is used where available (security check)
- [ ] No excessive redirect chains (>3 redirects)
- [ ] Content-Type matches expected resource type
- [ ] No malware/security warnings from reputation services

### Internal Links
- [ ] Relative paths resolve from current file location
- [ ] Anchor links (#section) match existing headings
- [ ] Cross-file references point to existing documents
- [ ] No circular reference loops
- [ ] Path casing matches filesystem (case-sensitive systems)

### Evidence Links (GitHub/Dashboards)
- [ ] Commit hashes exist in repository
- [ ] PR/Issue numbers are valid and accessible
- [ ] Dashboard URLs are not expired/temporary
- [ ] Screenshot/artifact links are still hosted
- [ ] API endpoints return expected data structures

## Usage Examples

```bash
# Run full audit on directory
openclaw skill evidence-link-auditor --target ./outputs/2026-03-01

# Check specific file
openclaw skill evidence-link-auditor --file report.md

# Generate report only (no fixes)
openclaw skill evidence-link-auditor --report-only

# Check for markers only
openclaw skill evidence-link-auditor --markers-only
```

## Output Format

```json
{
  "audit_date": "2026-03-01T01:24:00Z",
  "target": "./outputs/2026-03-01",
  "status": "PASS|FAIL",
  "links_checked": 42,
  "links_passed": 40,
  "links_failed": 2,
  "markers_found": 3,
  "failed_links": [...],
  "unresolved_markers": [...],
  "recommendations": [...]
}
```

## Integration Points

- Pre-merge CI/CD validation
- Scheduled quality audits (cron)
- Manual QA workflows
- Documentation generation pipelines
- Compliance verification processes

## Maintenance

- Update marker patterns as team conventions evolve
- Adjust timeout thresholds based on network conditions
- Add domain-specific validation rules as needed
- Review and update pass/fail criteria quarterly
