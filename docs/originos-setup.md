# vivo / OriginOS 后台设置

OriginOS 的后台限制可能导致 Automate 进程、开机广播或通知监听服务失效。以下设置建议全部完成。

## Automate 内部设置

打开 Automate 设置：

1. 开启 `Run on system startup`；
2. 保留 Automate 的常驻运行通知；
3. 启动“消息推送”和“通知修复”两个 Flow；
4. 正常情况下常驻通知应显示 `Running 2 fibers`。

## 系统权限

进入系统设置，为 Automate 开启：

- 通知权限；
- 通知使用权 / 通知访问权限；
- 自启动；
- 允许后台活动或允许后台耗电；
- 忽略电池优化；
- 忽略应用休眠。

不同 OriginOS 小版本的菜单名称可能略有不同，可以在系统设置中搜索“自启动”“电池优化”“通知使用权”。

## 最近任务锁定

可以在最近任务界面锁定 Automate，减少一键清理时被结束的概率。这不能替代自启动和后台耗电权限。

## 重启验证

重启后等待约一分钟，再检查：

1. Automate 常驻通知是否出现；
2. 是否显示两个运行中的 fibers；
3. 通知访问权限中 Automate 是否仍然开启；
4. 发送一条测试短信，日志是否依次出现：

```text
Notification posted?
Expression true?
Failure catch
HTTP request
```

