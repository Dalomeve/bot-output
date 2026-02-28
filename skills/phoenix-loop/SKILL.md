---
name: phoenix-loop
description: Turn agent failures into permanent improvements. Auto-diagnose blocked tasks, extract lessons, and wire them into reusable skills. Privacy-first: all data stays local.
---

# Phoenix Loop 🦅

**从失败中重生，持续完成任务。**

当 agent 遇到阻塞、失败或重复摩擦时，此技能启动自愈循环：诊断 → 学习 → 固化 → 验证。

## 核心机制

### 1. 失败诊断 (Diagnose)

```powershell
# 读取最近的阻塞记录
Get-Content memory/blocked-items.md | Select-String "Blocker" -Context 3

# 提取失败模式
Get-Content memory/tasks.md | Select-String "Status: failed" -Context 5
```

**诊断检查清单**:
- [ ] 失败原因是否明确？
- [ ] 是否已尝试至少 2 种解决路径？
- [ ] 是否有最小解锁输入定义？

### 2. 经验提取 (Extract)

从失败中提取可复用的模式：

```markdown
## 失败模式：{pattern_name}
- 触发条件：{when_this_happens}
- 根本原因：{root_cause}
- 解决方案：{fix_steps}
- 验证标准：{verification_criteria}
```

### 3. 技能固化 (Crystallize)

将经验写入本地技能：

```
skills/local/{pattern_name}-recovery.md
```

**技能模板**:
```markdown
# {Pattern Name} Recovery

## Trigger
当 {condition} 发生时

## Steps
1. {step_1}
2. {step_2}
3. {step_3}

## Verification
- [ ] {check_1}
- [ ] {check_2}

## Fallback
如果失败，执行 {fallback_action}
```

### 4. 验证循环 (Verify)

下次遇到相似问题时：
1. 搜索 `skills/local/` 匹配的技能
2. 执行恢复步骤
3. 记录结果到 `memory/{date}.md`
4. 更新技能（如果需要）

## 隐私安全 (Privacy First) 🔒

**所有数据本地存储**:
- ❌ 不发送失败日志到外部服务
- ❌ 不包含 API 密钥或 token 在技能文件中
- ❌ 不上传用户任务内容
- ✅ 仅记录模式名称和解决步骤
- ✅ 技能存储在 `skills/local/` 本地目录

**敏感信息过滤**:
在写入任何记忆或技能前，检查并移除：
- `apiKey`, `token`, `secret`, `password`
- `Bearer `, `sk-`, `OPENCLAW_`
- 个人邮箱、电话、地址

## 可执行完成标准

一个 phoenix-loop 任务完成当且仅当：

| 标准 | 验证命令 |
|------|----------|
| 失败模式已命名 | `Select-String "失败模式" memory/blocked-items.md` |
| 本地技能已创建 | `Test-Path skills/local/{name}-recovery.md` |
| 技能包含触发条件 | `Select-String "## Trigger" skills/local/{name}.md` |
| 技能包含验证步骤 | `Select-String "## Verification" skills/local/{name}.md` |
| 记忆已更新 | `Select-String "phoenix-loop" memory/{today}.md` |
| 隐私检查通过 | 技能文件不包含 `apiKey|token|secret` |

## 使用示例

### 场景：API 密钥缺失导致任务阻塞

**1. 诊断**:
```
阻塞原因：缺少 Brave API 密钥
已尝试：web_search (失败)
解锁输入：用户运行 openclaw configure --section web
```

**2. 提取模式**:
```
失败模式：missing-api-key
触发条件：工具需要未配置的 API 密钥
解决方案：1. 检测缺失密钥 2. 返回配置命令 3. 提供 fallback
```

**3. 固化技能**:
```markdown
# Missing API Key Recovery

## Trigger
当工具返回 "missing_*_api_key" 错误时

## Steps
1. 提取需要的密钥名称
2. 返回配置命令：openclaw configure --section {section}
3. 提供 manual fallback 选项

## Verification
- [ ] 用户收到清晰的配置指令
- [ ] 提供至少 1 个替代方案
```

**4. 验证**:
下次遇到 API 密钥问题时，自动应用此技能。

## 心跳集成

在 `HEARTBEAT.md` 中添加：

```markdown
## 自检 (每 24 小时)
1. 检查 `memory/blocked-items.md` 是否有超过 24 小时的阻塞
2. 对每个长期阻塞，运行 phoenix-loop 诊断
3. 如果找到可复用模式，创建或更新技能
```

## 回滚

如果技能导致问题：

```powershell
# 禁用技能（重命名）
Rename-Item skills/local/{name}-recovery.md skills/local/{name}-recovery.md.disabled

# 删除技能
Remove-Item skills/local/{name}-recovery.md
```

## 参考

- `memory/blocked-items.md` - 阻塞记录
- `memory/tasks.md` - 任务历史
- `skills/local/` - 本地技能库

---

**凤凰涅槃，越挫越强。** 🦅
