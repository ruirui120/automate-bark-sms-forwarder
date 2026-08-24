# 故障排查

## 日志只有 `Notification posted?`

这通常表示 Flow 正在等待目标应用发布新通知，不一定是错误。

检查：

- Package 是否选中了实际发布验证码通知的应用；
- vivo 信息应用可能使用 `com.android.mms.service`，而不是 `com.android.mms`；
- 通知内容是否出现在 `Message` 或 `Ticker text` 输出变量中；
- 表达式是否使用 `notify_ticker || notify_text`。

## 普通短信可以，平台验证码不可以

不要只依赖 `SMS received`。部分运营商验证码在厂商短信应用中经过特殊处理，但仍然会发布系统通知。

改用 `Notification posted`，并按实际包名过滤。

## 日志出现 `Stopped by failure`

如果上一行是 `HTTP request`，通常是网络、DNS、VPN 或 Bark 服务连接失败。

主 Flow 必须使用 `Failure catch`，并把 FAIL 路径接回 `Notification posted`。

## 手机重启后不工作

检查：

1. Automate 的 `Run on system startup`；
2. vivo 自启动权限；
3. 后台耗电和电池优化设置；
4. Automate 常驻通知是否出现；
5. 通知访问权限开关是否需要重新切换。

可按 [`notification-repair.md`](notification-repair.md) 创建自动修复 Flow。

## Bark 收到标题但正文为空

不同通知使用的字段不同：有些正文在 `Message`，有些在 `Ticker text`。使用：

```text
notify_ticker || notify_text
```

发送前用 `urlEncode(...)`，避免中文、空格、换行或特殊字符破坏 URL。

## VPN 开关是否影响

Bark 不要求 VPN。只要安卓手机能够访问 `api.day.app` 就可以推送。

某些代理使用 `198.18.0.0/15` Fake-IP；代理切换期间可能暂时连接失败。`Failure catch` 可以防止这种单次错误停止整个 Flow。

