# Codex 完成任务后通过 Bark 提醒

[`scripts/codex-bark-notify.ps1`](../scripts/codex-bark-notify.ps1) 接收 Codex 的 `agent-turn-complete` 回调，并在本轮任务耗时达到 3 分钟时发送 Bark。

## 提醒规则

- 耗时小于 180 秒：不提醒；
- 耗时等于或大于 180 秒：任务结束时提醒；
- 找不到本轮耗时：不提醒，并在 `bark-notify.log` 中记录 `duration unavailable`；
- 权限申请提醒不受这个阈值影响，应继续使用单独的 permission hook。

Codex 的标准 `notify` JSON 包含 `thread-id` 和 `turn-id`，但不直接提供耗时。脚本用这两个 ID 定位本机 `.codex/sessions` 中相同轮次的 `task_complete.duration_ms`，避免拿上一轮或另一个任务的时间做判断。

## 安装

把脚本复制到个人 hook 目录，例如：

```powershell
Copy-Item .\scripts\codex-bark-notify.ps1 "$env:USERPROFILE\.codex\hooks\bark-notify.ps1"
```

脚本从以下 DPAPI 文件读取 Bark Device Key，不要把明文 Key 写入仓库：

```text
%USERPROFILE%\.codex\secrets\bark-device-key.dpapi
```

如果尚未创建，可在 PowerShell 中交互式输入并加密保存：

```powershell
$secretDirectory = Join-Path $env:USERPROFILE ".codex\secrets"
New-Item -ItemType Directory -Force -Path $secretDirectory | Out-Null
$secureKey = Read-Host "Bark Device Key" -AsSecureString
$secureKey | ConvertFrom-SecureString | Set-Content (Join-Path $secretDirectory "bark-device-key.dpapi")
```

然后在个人级 `~/.codex/config.toml` 中把 `notify` 指向脚本。[Codex 官方通知配置](https://developers.openai.com/codex/config-advanced#notifications)说明，`notify` 当前会为 `agent-turn-complete` 调用外部程序，并把一个 JSON 参数传给脚本：

```toml
notify = ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "C:\\path\\to\\bark-notify.ps1"]
```

若桌面端已有通知包装程序，应保留包装程序，只替换它的 `--previous-notify` 脚本路径。

## 测试

测试只使用 `DryRun`，不会真的发送 Bark：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\codex-bark-notify.Tests.ps1
```

覆盖 179.999 秒、恰好 180 秒、超过 180 秒和非完成事件。
