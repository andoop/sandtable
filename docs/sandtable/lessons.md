# 全局教训台账 · Lessons（跨 feature 累积，只增不改历史条目）

> 每条来自一次已关闭的验收反馈/缺陷。开新需求时 RECON / 红蓝对抗 / 写 PRD 若存在本文件则必读，把过去的坑变成未来的检查项与攻击向量。

## 2026-06-06 · 来源 2026-06-06-post-landing-loop / 镜像遗漏（plugin-update 推演中发现）
- 根因摘要：post-landing-loop 新增 `templates/feedback.md`/`lessons.md` 时未镜像到 en 模板根。误把"en 模板根"当成 `locales/en/templates`（空目录），据此判"en 不镜像模板"；真正的 en 模板源是 `templates/en/`（见 INSTALL.md §3:84、§5.1 `TEMPLATES_SRC`）。导致 en 用户安装/更新后缺这两个模板。
- 怎么预防：**新增/改动任何"语言相关资产"时，必须对照 INSTALL.md §3 的源路径映射逐项核对每个 locale 的真实源路径**，不能只看"最显眼的目录"。镜像核对脚本应覆盖 `templates/en/`，而非 `locales/en/templates/`。
- 吸取的教训：判断"是否需要 en 镜像 / en 源在哪"，以 INSTALL.md §3 的权威映射为准，不靠目录名直觉；空目录 ≠ 不镜像。
- 候选红线/检查项更新：RECON 清单加一项——"涉及多 locale 资产的需求，开工前对照 INSTALL.md §3 列全每个 locale 的真实源/目标路径"；可考虑加一个镜像完整性自检（比对 root templates 与 templates/en 的文件集差异）。
- 采纳情况：待定（教训已记；是否落 constraints.md/RECON 清单由开发者拍板）。

## 2026-06-19 · 来源 2026-06-13-mobile-on-demand-sync / 等待器静默失败与主动同步发错会话
- 根因摘要：Codex 沙箱禁止 loopback 时，wait 脚本把 curl 失败吞成空 inbox 并永久等待；同时 mobile-sync 在 session 被替换后保留 stale sessionId，使电脑端主动进展没有稳定目标。规则虽要求关键时刻同步，但缺少统一可执行入口，`agent-state` 又被误当成可见会话进展。
- 怎么预防：等待通道必须区分传输错误与空消息，并提供基于 mailbox source of truth 的独立取件路径；主动同步必须由 server 解析当前 session，统一走 `/mobile-sync/notify`，且用真实会话消息做端到端验收。
- 吸取的教训：异步伴随通道不能只验证“服务活着”和“规则写了”；必须同时验证消息可达、会话身份正确、关键节点在用户实际看到的会话中可见。
- 候选红线/检查项更新：建议在 `constraints.md` 增加“任何常驻通知义务必须有统一可执行入口，状态指示器不得替代用户可见消息”；RECON 增加“检查 transport failure 与 empty queue 是否可区分、session identity 是否可能 stale”。
- 采纳情况：待定（是否写入 constraints.md / RECON 清单由开发者拍板）。

## 2026-06-20 · 来源 2026-06-13-mobile-on-demand-sync / Agent 手机消息格式逐轮退化
- 根因摘要：App 已支持 Markdown，但 PRD 和 agent 常驻规则没有定义格式 MUST，统一 notify 工具又拒绝多行输入；多事实进展因此容易退化成无结构长段落。
- 怎么预防：长期展示行为必须同时提供 PRD 要求、常驻基线、固定模板、可执行入口和视觉回归；`status/phase` 保持单行，复杂内容统一使用 `chat/question` 多行 Markdown。
- 吸取的教训：不能把稳定 UX 寄托在 agent 的临场审美上；格式必须成为工具可执行、测试可验证的契约。
- 候选红线/检查项更新：建议 `constraints.md` 增加“用户可见的 agent 长期行为必须有模板 + 工具 + 验收用例，不得只写抽象要求”；RECON 检查“现有 UI 能力是否已有但缺 agent 输出契约”。
- 采纳情况：待定（是否写入 constraints.md / RECON 清单由开发者拍板）。
