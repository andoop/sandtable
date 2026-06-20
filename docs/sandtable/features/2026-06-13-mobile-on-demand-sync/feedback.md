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

## FB-2026-06-19-03 · 主 agent 处理手机消息时仍显示空闲

- **状态**: VERIFYING
- **受理时间**: 2026-06-19T22:50:16+08:00
- **用户反馈**: 「我怎么感觉主agent的状态一直是空闲，明明它在处理中，手机上也是空闲」
- **期望行为**: waiter 交付手机消息后，手机立即显示 main agent 为 working；处理、回复、ack 完成后才切回 idle。
- **实际行为**: wait 脚本只上报 waiter=processing；main=working 完全依赖主 agent 手工调用 `/mobile-sync/agent-state`，漏调用时状态从 idle 直接回到 idle。
- **初步分诊**: 真缺陷。依据 `commands/sandtable-mobile-start.md` 第 5 步和 `skills/mobile-companion/SKILL.md` 的运行态约定，当前手机状态与真实处理阶段不符。
- **运行时证据**: 用户在主 agent 正处理消息时观察到 idle；同一轮中 main agent 确实未在处理开始前调用 working，只在处理结束后写 idle。代码路径 `/mailbox/inbox` 返回消息时不会更新 main 状态。
- **下一步**: 添加回归测试，要求 inbox GET 返回非空消息时 server 自动设置 main=working，消除手工上报单点失败。
- **根因**: 运行协议要求 main 手工上报 working/idle，但没有统一脚本，也没有把“wait 返回后的第一动作”和“处理完成的最后动作”设为硬顺序，导致 agent 容易漏报。waiter=processing 与 main=working 是两个不同阶段，server 无法根据 inbox GET 真实推导 main 是否已恢复执行。
- **被否决方案**: 曾尝试在 `GET /mailbox/inbox` 返回非空时由 server 自动设置 main=working；开发者指出这不是真实状态。该方案已撤回，并新增测试确保 inbox GET 不改变 main 状态。
- **最终修复**: 新增零依赖 `scripts/sandtable-mobile-main-state.sh`；mobile-companion、start 命令和常驻 AGENTS/Cursor/Kiro 基线规定：wait 返回后 main 的第一动作报 working，回复/ack/文档/推送全部完成后的最后动作报 idle。server 仅保存明确上报，不猜状态。
- **验证**: runtime server 9 files / 25 tests、typecheck、shell 语法与镜像一致性全部通过。测试确认 inbox GET 后 main 仍保持 idle，只有显式 state 上报才变 working。热重启后 live helper 返回 main=working，时间和 detail 与主 agent 实际开始处理动作一致。
- **待确认**: 开发者再发送一条消息，确认手机状态按“waiter processing → main working → main idle”真实切换后，方可进入 USER_CONFIRMED/CLOSED。

## FB-2026-06-20-04 · 手机可见消息缺少强制格式规范

- **状态**: CLOSED
- **受理时间**: 2026-06-20T08:30:14+08:00
- **用户反馈**: 「我的意思是如果不添加明确的要求，agent就会不遵循，你看看设计一下」
- **分诊**: 漏需求。App 的 chat bubble 已使用 `MarkdownBody`，但原 PRD、AGENTS 和 mobile-companion 没有规定 agent 必须采用何种格式；统一 notify 脚本还拒绝换行，导致多行 Markdown 无法通过标准入口发送。
- **确认记录**: 本条手机消息明确要求把格式化变成 agent MUST，作为 FR6 的开发者确认依据。
- **补充需求**: `status/phase` 保持单行纯文本；多事实进展、决策、测试、阻塞和问题必须用 `chat/question` Markdown；统一模板覆盖开始、进展、完成、问题、错误；禁止裸 JSON、终端噪声和无结构长段落。
- **实现方向**: notify 脚本支持 stdin/多行 Markdown并安全编码 JSON；格式契约写入 AGENTS、mobile-companion 和 start 命令的中英文真源与镜像。
- **实现**: `sandtable-mobile-notify.sh <kind> -` 支持 stdin 多行文本，使用 POSIX `sed/awk` 安全编码 JSON；`status/phase` 强制单行，`chat/question` 允许多行 Markdown。AGENTS、Cursor/Kiro 基线、mobile-companion 与 start 命令的中英文真源和镜像均加入 MUST、固定标题、模板和禁用项。
- **验证**: runtime server 25/25 tests、typecheck、shell 语法、镜像一致性与 diff check 通过；live script 将 Markdown 原样写入 conversation，多行 status 返回错误 `status messages must be a single line`。
- **待确认**: 开发者确认手机端示例显示为粗体标题、列表和行内代码后关闭。
- **用户确认**: 2026-06-20 08:36 CST，手机回复「格式正常」，消息 id `20260620T003637693Z-mobile-7KGreO0e`。
- **根因**: Markdown 渲染能力已存在，但需求只描述“同步消息”，没有定义 agent 输出格式；标准 notify 入口又拒绝换行，导致规则与工具都不足以约束多事实消息。
- **怎么预防**: 任何要求 agent 长期遵循的展示行为必须同时具备 PRD MUST、常驻基线、具体模板、可执行工具和端到端视觉用例，不能只依赖“agent 自觉”。
- **吸取的教训**: Agent 行为规范若没有模板和工具约束，会随轮次退化；把格式要求写成可执行契约，才能稳定保持用户体验。
