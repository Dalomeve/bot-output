# GitHub Research: Trending Projects & Pain Points

**Date**: 2026-03-01
**Source**: GitHub Trending (https://github.com/trending)

---

## Projects Analyzed (14 Total)

### Agent & Automation (5)
| Project | Stars | Description |
|---------|-------|-------------|
| anthropics/claude-code | 71,758 | Agentic coding tool in terminal |
| bytedance/deer-flow | 22,547 | SuperAgent with sandboxes, memory, skills |
| ruvnet/ruflo | 16,411 | Agent orchestration for Claude |
| obra/superpowers | 65,811 | Agentic skills framework |
| X-PLUG/MobileAgent | 7,479 | GUI agent for mobile |

### DevTools & Infrastructure (4)
| Project | Stars | Description |
|---------|-------|-------------|
| superset-sh/superset | 2,370 | IDE for AI Agents Era |
| alibaba/OpenSandbox | 1,767 | Sandbox platform for AI apps |
| Wei-Shaw/claude-relay-service | 8,678 | Claude proxy service |
| Wei-Shaw/sub2api | 2,373 | Unified API subscription |

### Knowledge & Data (3)
| Project | Stars | Description |
|---------|-------|-------------|
| Shubhamsaboo/awesome-llm-apps | 98,169 | LLM apps collection |
| datagouv/datagouv-mcp | 620 | MCP server for open data |
| moonshine-ai/moonshine | 6,187 | Speech recognition |

### Other (2)
| Project | Stars | Description |
|---------|-------|-------------|
| ruvnet/wifi-densepose | 10,883 | WiFi-based pose estimation |
| moeru-ai/airi | 19,234 | Self-hosted Grok companion |

---

## Identified Pain Points (5)

### 1. Skill/Tool Fragmentation
**Problem**: Skills built for one agent framework (Claude Code, Codex, etc.) don't transfer to others. Each platform reinvents the wheel.
**Evidence**: ruflo, superpowers, deer-flow all have separate skill systems.

### 2. Context Loss Between Sessions
**Problem**: Agents lose context when sessions end. No persistent memory across runs.
**Evidence**: Most projects mention "memory" but it's session-scoped.

### 3. Verification Gap ⭐ (Selected)
**Problem**: Hard to verify what agents actually did. No audit trail, no evidence links, no reproducibility.
**Evidence**: None of the trending projects focus on verifiable execution logs.

### 4. Cost Management Complexity
**Problem**: Multiple API subscriptions (Claude, OpenAI, Gemini) with no unified tracking.
**Evidence**: claude-relay-service, sub2api both address this (8k+ stars each).

### 5. Evidence Tracking Missing
**Problem**: Agent outputs claim completion but provide no verifiable artifacts.
**Evidence**: "awesome-llm-apps" has 98k stars but is just a list, not verifiable executions.

---

## Selected Direction: Verification Gap

**Project**: `agent-audit-trail` - Lightweight evidence tracker for agent workflows

**Why This Direction**:
1. No trending project addresses verifiable execution
2. Critical for production agent deployment
3. Framework-agnostic (works with Claude Code, Codex, any agent)
4. Solves our own pain point from tonight's skill publishing

**MVP Scope**:
- Record agent actions with timestamps
- Capture evidence artifacts (files, URLs, commands)
- Generate verifiable audit report
- Simple CLI + library API

---

**Next**: Implement MVP and publish to Dalomeve/agent-audit-trail
