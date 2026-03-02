# Research Notes: Weekly Sync 2026-03-02

**Generated:** 2026-03-02 09:00 (Asia/Shanghai)  
**Sources:** OpenClaw docs, arXiv (Reflexion 2303.11366, Voyager 2305.16291), SWE-agent repo/docs

---

## Primary Source Updates

### 1. Reflexion (arXiv:2303.11366)

**Latest Version:** v4 (2023-10-10)  
**Key Contribution:** Linguistic feedback reinforcement without weight updates

**Core Mechanism:**
- Agents verbally reflect on task feedback signals
- Maintain reflective text in episodic memory buffer
- Induces better decision-making in subsequent trials

**Performance:**
- 91% pass@1 on HumanEval coding benchmark (vs 80% GPT-4 baseline)
- Flexible: incorporates scalar values or free-form language feedback
- Works with external or internally simulated feedback signals

**Actionable for Autonomy Loop:**
- ✅ Add verbal reflection step after each task (success or failure)
- ✅ Maintain `memory/reflections/` buffer with structured reflection entries
- ✅ Use reflections to inform next task attempt strategy

**Reference:** [arXiv:2303.11366v4](https://arxiv.org/abs/2303.11366v4) | [PDF](https://arxiv.org/pdf/2303.11366)

---

### 2. Voyager (arXiv:2305.16291)

**Latest Version:** v2 (2023-10-19)  
**Key Contribution:** LLM-powered embodied lifelong learning agent

**Core Components:**
1. **Automatic curriculum** - maximizes exploration
2. **Ever-growing skill library** - stores/retrieves executable code for complex behaviors
3. **Iterative prompting mechanism** - incorporates environment feedback, execution errors, self-verification

**Performance:**
- 3.3x more unique items than prior SOTA
- 2.3x longer travel distances
- 15.3x faster at unlocking key tech tree milestones
- Skills are temporally extended, interpretable, compositional

**Actionable for Autonomy Loop:**
- ✅ Build `skills/local/` library with executable, composable skill scripts
- ✅ Implement automatic curriculum generation from task queue
- ✅ Add self-verification step before marking tasks complete

**Reference:** [arXiv:2305.16291v2](https://arxiv.org/abs/2305.16291v2) | [Project](https://voyager.minedojo.org/)

---

### 3. SWE-agent

**Latest Status:** mini-SWE-agent recommended over full SWE-agent  
**Key Update:** July 2024 - mini-SWE-agent achieves 65% on SWE-bench verified in 100 lines of Python

**Design Principles:**
- Simplicity: 100 lines of Python matches full SWE-agent performance
- Configurable: governed by single YAML file
- Research-friendly: simple and hackable by design

**Recent Milestones:**
- Feb 2024: SWE-agent 1.0 + Claude 3.7 is SoTA on SWE-bench full
- May 2024: SWE-agent-LM-32b achieves open-weights SOTA
- July 2024: mini-SWE-agent supersedes full implementation

**Actionable for Autonomy Loop:**
- ✅ Prefer minimal viable implementation (100-line pattern)
- ✅ Use YAML configuration for task definitions
- ✅ Focus on simplicity over feature completeness

**Reference:** [SWE-agent GitHub](https://github.com/SWE-agent/SWE-agent) | [mini-SWE-agent](https://github.com/SWE-agent/mini-swe-agent)

---

### 4. OpenClaw Documentation

**Status:** Stable documentation structure  
**Key Sections:**
- Core: `concepts/`, `design/`, `reference/`
- Tools: `tools/`, `cli/`, `gateway/`
- Skills: `skills/`, `plugins/`
- Deployment: `install/`, `platforms/`, `security/`

**No Major Changes:** Documentation structure remains stable since last sync.

**Reference:** [docs.openclaw.ai](https://docs.openclaw.ai) | [GitHub](https://github.com/openclaw/openclaw)

---

## Synthesis: Actionable Experiments

### Experiment 1: Reflexion-Style Reflection Loop

**Hypothesis:** Adding structured verbal reflection after each task will improve completion rate by 10%+ within 2 weeks.

**Implementation:**
1. After each task (pass or fail), write reflection to `memory/reflections/YYYY-MM-DD-task-<id>.md`
2. Reflection template:
   - What was attempted
   - What succeeded/failed
   - What would be done differently
   - One concrete lesson for next attempt
3. Before starting new task, read last 3 reflections for pattern matching

**Success Metrics:**
- Completion rate increases from current baseline
- Fewer repeated failure patterns
- Reflections contain actionable lessons (not just descriptions)

**Timeline:** Start 2026-03-02, evaluate 2026-03-16

---

### Experiment 2: Voyager-Style Skill Library

**Hypothesis:** Building composable, executable skill library will reduce task execution time by 30%+ and improve success rate on complex multi-step tasks.

**Implementation:**
1. Create `skills/local/library/` with executable PowerShell scripts
2. Each skill: single responsibility, documented inputs/outputs, verification step
3. Implement skill composition: chain skills for complex tasks
4. Add skill retrieval: search library before attempting new implementation

**Initial Skills to Crystallize:**
- `powershell-safe-chain` - native PowerShell command patterns
- `task-finish-contract` - completion verification
- `evidence-url-verifier` - evidence link validation
- `blocker-min-input` - minimal user input identification

**Success Metrics:**
- Task execution time decreases for recurring patterns
- Skill reuse rate increases (same skill used in 3+ tasks)
- Complex task success rate improves

**Timeline:** Start 2026-03-02, evaluate 2026-03-30

---

## Next Actions

1. **Immediate (2026-03-02):**
   - [x] Create research-notes.md (this file)
   - [ ] Add 2 new experiments to TASKSET.md
   - [ ] Create reflection template in `bot-output/ops/self-evolution/REFLECTION_TEMPLATE.md`

2. **Week 1 (2026-03-02 to 2026-03-08):**
   - [ ] Implement reflection loop for all tasks
   - [ ] Crystallize first 4 skills into `skills/local/library/`
   - [ ] Track metrics in SCOREBOARD.md

3. **Week 2 (2026-03-09 to 2026-03-15):**
   - [ ] Evaluate Experiment 1 results
   - [ ] Expand skill library to 10+ skills
   - [ ] Prepare mid-cycle adjustment if needed

---

## Evidence Links

| Source | URL | Fetched |
|--------|-----|---------|
| Reflexion arXiv | https://arxiv.org/abs/2303.11366 | 2026-03-02 09:00 |
| Voyager arXiv | https://arxiv.org/abs/2305.16291 | 2026-03-02 09:00 |
| SWE-agent GitHub | https://github.com/SWE-agent/SWE-agent | 2026-03-02 09:00 |
| OpenClaw Docs | https://docs.openclaw.ai | 2026-03-02 09:00 |

---

*Auto-generated by weekly-research-sync cron job.*
