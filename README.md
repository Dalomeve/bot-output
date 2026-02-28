# Bot Output Repository

**以后所有任务输出都放在这个仓库按日期分目录**

All future task outputs will be stored in this repository, organized by date in subdirectories under `outputs/`.

## Structure

```
bot-output/
├── README.md          # This file
├── INDEX.md           # Index of all outputs
└── outputs/
    └── YYYY-MM-DD-project-name/
        ├── README.md
        ├── methods.md
        └── report/
            ├── data.json
            └── verification.md
```

## Usage

- Each output is stored in `outputs/<date>-<project-name>/`
- See [INDEX.md](./INDEX.md) for a complete list of all outputs
- Verification reports are in each project's `report/verification.md`

## Guidelines

1. Date format: `YYYY-MM-DD`
2. Project names use lowercase with hyphens
3. Each output must include verification evidence
4. INDEX.md is updated automatically when new outputs are added
