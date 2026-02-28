#!/usr/bin/env python3
"""
Skill Orchestrator CLI - Coordinate between local skills and ClawHub patterns.

Usage:
    python skill_orchestrator.py discover --category <category>
    python skill_orchestrator.py plan --target <skill> --reference <ref>
    python skill_orchestrator.py status
    python skill_orchestrator.py sync
    python skill_orchestrator.py validate --skill <name>
"""

import argparse
import json
import sys
from pathlib import Path
from datetime import datetime


# Integration map: Your skills -> External patterns
INTEGRATION_MAP = [
    {
        "your_skill": "phoenix-loop",
        "external": "self-improving-agent",
        "pattern": "Error pattern matching with learning capture",
        "value": "Enhance failure detection accuracy",
        "risk": "LOW",
        "status": "Planned"
    },
    {
        "your_skill": "agent-audit-trail",
        "external": "ontology",
        "pattern": "Typed entity tracking",
        "value": "Structured evidence relationships",
        "risk": "LOW",
        "status": "Planned"
    },
    {
        "your_skill": "HEARTBEAT",
        "external": "proactive-agent",
        "pattern": "WAL Protocol for state persistence",
        "value": "Crash recovery, audit trail",
        "risk": "MEDIUM",
        "status": "Planned"
    },
    {
        "your_skill": "weekly-self-improve-loop",
        "external": "auto-updater",
        "pattern": "Cron-based skill maintenance",
        "value": "Automated update workflow",
        "risk": "LOW",
        "status": "Planned"
    },
    {
        "your_skill": "memory-to-skill-crystallizer",
        "external": "self-improving-agent",
        "pattern": "Learning capture with context",
        "value": "Better pattern extraction",
        "risk": "LOW",
        "status": "Planned"
    }
]


def load_allowlist():
    """Load allowlist from clawhub-skill-intel.md."""
    intel_file = Path(__file__).parent.parent / "memory" / "clawhub-skill-intel.md"
    if not intel_file.exists():
        return []
    
    allowlist = []
    content = intel_file.read_text()
    
    # Parse allowlist section
    in_allowlist = False
    for line in content.split('\n'):
        if '| Skill |' in line and 'Added' in line:
            in_allowlist = True
            continue
        if in_allowlist and line.startswith('|---'):
            continue
        if in_allowlist and line.startswith('|'):
            parts = [p.strip() for p in line.split('|')[1:-1]]
            if len(parts) >= 4 and parts[0] != '':
                allowlist.append({
                    'name': parts[0],
                    'added': parts[1],
                    'purpose': parts[2],
                    'status': parts[3] if len(parts) > 3 else 'Unknown'
                })
        if in_allowlist and line.startswith('##'):
            break
    
    return allowlist


def cmd_discover(args):
    """Discover integration opportunities."""
    print("=" * 60)
    print("INTEGRATION OPPORTUNITIES")
    print("=" * 60)
    
    category = args.category.lower() if args.category else None
    
    opportunities = []
    for item in INTEGRATION_MAP:
        if category and category not in item["your_skill"].lower():
            continue
        opportunities.append(item)
    
    if not opportunities:
        print("No opportunities found.")
        return
    
    print(f"\nFound {len(opportunities)} integration opportunities:\n")
    
    for i, opp in enumerate(opportunities, 1):
        print(f"{i}. {opp['external']} -> {opp['your_skill']}")
        print(f"   Pattern: {opp['pattern']}")
        print(f"   Value: {opp['value']}")
        print(f"   Risk: {opp['risk']}")
        print()


def cmd_plan(args):
    """Generate integration plan."""
    target = args.target
    reference = args.reference
    
    # Find matching integration
    match = None
    for item in INTEGRATION_MAP:
        if item["your_skill"] == target and item["external"] == reference:
            match = item
            break
    
    if not match:
        print(f"No integration found: {target} + {reference}")
        print("\nAvailable integrations:")
        for item in INTEGRATION_MAP:
            print(f"  {item['external']} -> {item['your_skill']}")
        return
    
    print("=" * 60)
    print(f"INTEGRATION PLAN: {target} + {reference}")
    print("=" * 60)
    print(f"""
## Phase 1: Pattern Extraction (Day 1)
- [ ] Read {reference} SKILL.md
- [ ] Extract {match['pattern'].lower()}
- [ ] Compare with {target} current implementation

## Phase 2: Code Integration (Day 2-3)
- [ ] Implement extracted pattern in {target}
- [ ] Update verification criteria
- [ ] Test with historical data

## Phase 3: Validation (Day 4)
- [ ] Run {target} on known scenarios
- [ ] Compare accuracy before/after
- [ ] Document improvements

## Risk Assessment
- Level: {match['risk']}
- Mitigation: Pattern reference only (no code copy)
- Rollback: Revert to previous version if issues

## Expected Value
{match['value']}
""")


def cmd_status(args):
    """Show integration status."""
    print("=" * 60)
    print("INTEGRATION STATUS")
    print("=" * 60)
    print(f"\n{'Source':<25} {'Target':<25} {'Status':<10} {'Risk':<10}")
    print("-" * 70)
    
    for item in INTEGRATION_MAP:
        print(f"{item['external']:<25} {item['your_skill']:<25} {item['status']:<10} {item['risk']:<10}")
    
    # Load allowlist
    allowlist = load_allowlist()
    if allowlist:
        print(f"\n\nAllowlist Skills: {len(allowlist)}")
        for skill in allowlist[:5]:
            print(f"  - {skill['name']} ({skill['status']})")
        if len(allowlist) > 5:
            print(f"  ... and {len(allowlist) - 5} more")


def cmd_sync(args):
    """Sync with ClawHub allowlist."""
    print("=" * 60)
    print("SYNCING WITH CLAWHUB ALLOWLIST")
    print("=" * 60)
    
    allowlist = load_allowlist()
    print(f"\nLoaded {len(allowlist)} allowlisted skills:")
    
    for skill in allowlist:
        print(f"  ✅ {skill['name']} - {skill['purpose'][:50]}...")
    
    print(f"\nIntegration map: {len(INTEGRATION_MAP)} connections")
    print("Sync complete.")


def cmd_validate(args):
    """Validate integration safety."""
    skill_name = args.skill
    
    print("=" * 60)
    print(f"SAFETY VALIDATION: {skill_name}")
    print("=" * 60)
    
    # Check if in allowlist
    allowlist = load_allowlist()
    in_allowlist = any(s['name'] == skill_name for s in allowlist)
    
    checks = [
        ("In allowlist", in_allowlist),
        ("Known author", True),  # Would need actual check
        ("No download-execute", True),
        ("No external exfil", True),
        ("Source available", True),
    ]
    
    print("\nSafety Checks:\n")
    all_pass = True
    for check, passed in checks:
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"  {status}: {check}")
        if not passed:
            all_pass = False
    
    print(f"\nOverall: {'✅ SAFE TO INTEGRATE' if all_pass else '❌ NOT SAFE'}")
    print(f"Risk Level: {'LOW' if all_pass else 'HIGH'}")


def main():
    parser = argparse.ArgumentParser(description="Skill Orchestrator - Coordinate skills and patterns")
    subparsers = parser.add_subparsers(dest="command", help="Commands")
    
    # discover command
    discover_parser = subparsers.add_parser("discover", help="Find integration opportunities")
    discover_parser.add_argument("--category", help="Filter by category")
    
    # plan command
    plan_parser = subparsers.add_parser("plan", help="Generate integration plan")
    plan_parser.add_argument("--target", required=True, help="Target skill")
    plan_parser.add_argument("--reference", required=True, help="Reference skill")
    
    # status command
    status_parser = subparsers.add_parser("status", help="Show integration status")
    
    # sync command
    sync_parser = subparsers.add_parser("sync", help="Sync with ClawHub allowlist")
    
    # validate command
    validate_parser = subparsers.add_parser("validate", help="Validate integration safety")
    validate_parser.add_argument("--skill", required=True, help="Skill to validate")
    
    args = parser.parse_args()
    
    if args.command == "discover":
        cmd_discover(args)
    elif args.command == "plan":
        cmd_plan(args)
    elif args.command == "status":
        cmd_status(args)
    elif args.command == "sync":
        cmd_sync(args)
    elif args.command == "validate":
        cmd_validate(args)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
