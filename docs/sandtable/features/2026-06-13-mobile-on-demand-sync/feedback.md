# 验收反馈

## FB-2026-06-19-01 · 手机消息已发送但主 agent 无响应

- **状态**: CLOSED
- **受理时间**: 2026-06-19T20:34:24+08:00
- **用户反馈**: 「我手机上明明已经发消息了呀」
- **期望行为**: 手机发送 chat 消息后，wait 子 agent 在轮询周期内返回，主 agent 处理、回复并 ack。
- **实际行为**: 手机端消息已进入系统并写入 feature journal，但 wait 子 agent 长时间不返回，主 agent无消息可处理。
- **初步分诊**: 真缺陷候选。依据 `tests.md` TC5 要求 wait 脚本在 5 秒轮询内返回 inbox 消息；当前行为与该已确认验收标准不符。
- **运行时证据**: `journal.md` 已记录 2026-06-19T12:24:34.720Z 的「在吗」和 2026-06-19T12:30:57.364Z 的「测试一下」，证明手机到 server 的消息提交成功；根因尚未确认。
- **下一步**: 采集 server 日志、mailbox 文件、进程与 waiter 运行态，建立消息提交到 waiter 获取之间的完整因果链。
- **根因**: Codex 主 agent 与 wait 子 agent 的运行沙箱均禁止访问 loopback。两端执行 `curl http://127.0.0.1:8765/...` 都返回 `Operation not permitted`、退出码 7；与此同时 3 条对应消息 JSON 已存在于 `.sandtable-runtime/mailbox/inbox/`。`scripts/sandtable-mobile-wait.sh:54` 将任意 curl 失败静默替换为 `{"messages":[]}`，导致 waiter 把“无法连接”永久误判为“没有消息”。
- **证据位置**: `/tmp/sandtable-logs/FB-2026-06-19-01/server.log`；waiter 与主 agent 的 curl 输出均记录 `Immediate connect fail ... Operation not permitted`。
- **修复方案**: HTTP 可用时保持原路径；HTTP 不可达时直接读取 server 的 inbox 源文件，并复用 `/mailbox/inbox` 的 `source/feature/after/id sort` 语义。
- **验证结果**: `bash -n` 与 `git diff --check` 通过；runtime server 测试 23/23 通过；回归 waiter 在 `SANDTABLE_MOBILE_PORT=1` 强制 HTTP 不可达时退出码 0，并返回 3 条 inbox 消息（`mobile_paired`、「在吗」、「测试一下」）。3 条消息已 ack，agent 回复已写入会话；同步服务已清理并重新启动。
- **真机回归**: 2026-06-19 21:43 CST 使用配对码 `2960` 成功配对；waiter 返回 `mobile_paired`。手机随后发送「测试一下」，下一位 waiter 正常返回 `chat_message`；主 agent 回复成功且 ack 返回 `acked: 1`。
- **待确认**: 开发者使用新配对码重新连接并发送消息，确认手机能收到 agent 回复后，方可进入 USER_CONFIRMED/CLOSED。
- **用户确认**: 2026-06-19 22:01 CST，手机消息「确认了」，消息 id `20260619T140119003Z-mobile-dh-JGcnV`。
- **怎么预防**: wait 通道必须把“无消息”和“传输失败”分开处理；HTTP 不可达时读取同一 mailbox source of truth，并保留强制 loopback 失败的回归用例 TC11。
- **吸取的教训**: 无限轮询若吞掉传输错误，会把确定性故障伪装成安静等待；等待器必须有与主传输独立的可验证取件路径。

## FB-2026-06-19-02 · 关键工作节点没有稳定同步到手机会话

- **状态**: CLOSED
- **受理时间**: 2026-06-19T21:47:22+08:00
- **用户反馈**: 「改一下吧，我记得改过呀，就是在关键时刻都要同步手机的呀，你确认一下逻辑」
- **期望行为**: mobile-sync active 时，无论工作由手机还是电脑触发，重要动作前/中/后、阶段切换、关键决策、待确认或阻塞都主动写入手机当前会话。
- **实际行为**: 规则文字已存在，但主动同步缺少统一执行入口；处理手机来信时会更新 `agent-state`，电脑端持续工作期间不保证手机会话收到可见进展消息。
- **初步分诊**: 真缺陷候选。依据 `AGENTS.md`「手机同步常驻义务」和 `skills/mobile-companion/SKILL.md`「常驻同步义务」，当前执行不满足已确认 MUST。
- **当前证据**: `rg` 确认规则已传播到 AGENTS、Cursor/Kiro 基线和中英文 skill；`commands/sandtable-mobile-start.md` 仅明确规定“处理手机消息”时上报，没有为电脑端重要动作提供统一命令或可验证检查。
- **下一步**: 核对 active session 解析、会话消息 API 与脚本层能力，确认执行缺口后修复并做真机回归。
- **根因**: `/mobile-sync/start` 记录配对前的 sessionId；若该 session 在配对前被删除/替换，`/pair/by-code` 会通过 `publishAgentSnapshot` 创建新 session，却继续在配对响应和 `mobile-sync.json` 中保留旧 sessionId。主动同步因此没有可靠目标，只能等手机先发消息后从 inbox 获知新 sessionId。与此同时，规则只有文字要求和 `agent-state` 上报，没有统一的手机会话通知入口。
- **运行时证据**: 真机 `mobile-sync.json.sessionId=sess_LZhq16aZxPsH`，而 `sessions.json` 唯一当前会话为 `sess_vwd-nqlk2Vhv`；失败回归测试确认删除 `sess_stale` 后，旧实现的配对响应仍返回 `sess_stale`。
- **修复**: 配对和 `push-state` 均回写真实 sessionId；新增 `POST /mobile-sync/notify` 与 `scripts/sandtable-mobile-notify.sh`，由 server 每次解析当前 session 并自动修正 stale id。AGENTS、Cursor/Kiro 基线、mobile-companion 中英文 skill 与 start 命令均明确关键节点必须 notify；`agent-state` 仅用于状态灯。
- **验证**: 新回归测试通过；runtime server 9 files / 24 tests、TypeScript 类型检查、shell 语法、镜像一致性与 `git diff --check` 全部通过。热重启后真实运行 `sandtable-mobile-notify.sh` 返回 `sessionId=sess_vwd-nqlk2Vhv`，并将 mobile-sync sessionId 自动修正为该当前会话；完成消息已写入手机会话。
- **待确认**: 开发者确认手机端看到“修复完成”关键节点消息后，方可进入 USER_CONFIRMED/CLOSED。
- **用户确认**: 2026-06-19 22:01 CST，手机消息「确认了」，消息 id `20260619T140119003Z-mobile-dh-JGcnV`。
- **怎么预防**: 主动同步统一走 server-resolved `/mobile-sync/notify`，禁止 agent 猜 sessionId；常驻规则必须给出可执行入口并明确 `agent-state` 不能替代 conversation message；保留 stale-session 回归用例 TC12。
- **吸取的教训**: “关键时刻要同步”只有在目标会话由 server 解析、动作有统一入口、结果能在手机会话验证时才是工程约束，否则只是容易遗忘的文案。
