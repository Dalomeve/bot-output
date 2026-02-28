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