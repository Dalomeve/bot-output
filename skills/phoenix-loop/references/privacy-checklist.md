# 隐私安全检查清单

在发布或使用 phoenix-loop 技能前，必须完成以下检查：

## 文件扫描

```powershell
# 扫描敏感模式
Get-ChildItem skills/local/ -Recurse -File | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match 'apiKey|token|secret|password|Bearer |sk-|OPENCLAW_') {
        Write-Warning "敏感内容：$($_.FullName)"
    }
}
```

## 检查清单

- [ ] 技能文件不包含 API 密钥
- [ ] 技能文件不包含 gateway token
- [ ] 技能文件不包含个人邮箱/电话
- [ ] 技能文件不包含绝对路径（如 C:\Users\{name}\...）
- [ ] 记忆文件已脱敏（仅记录模式，不记录具体内容）
- [ ] 所有数据存储在本地 (`skills/local/`, `memory/`)

## 允许的内容

✅ 模式名称（如 `missing-api-key`）
✅ 通用解决步骤（如 `运行 openclaw configure`）
✅ 验证命令（如 `Test-Path`）
✅ 工具名称和命令

## 禁止的内容

❌ 实际密钥值
❌ 用户特定路径
❌ 个人身份信息
❌ 外部服务 URL（除非官方文档）

## 发布前验证

```powershell
# 运行检查
$files = Get-ChildItem skills/local/phoenix-loop* -Recurse -File
foreach ($f in $files) {
    $c = Get-Content $f.FullName -Raw
    if ($c -match '(?i)apiKey|token|secret|password') {
        throw "敏感内容检测：$($f.FullName)"
    }
}
Write-Host "隐私检查通过 ✓"
```
