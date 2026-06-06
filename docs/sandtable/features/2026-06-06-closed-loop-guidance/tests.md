# 测试用例 · 回合收尾与下一步引导

> tests.md = 理解闸门（先读）。PRD §5 = 完成闸门（VERIFY 勾选）。

## TC1 · PLAN 完成后手动模式给出可复制推演模版

- **映射**: FR1, FR2, FR6；验收「手动模式可复制继续」
- **Given**: 某 feature 的 `state.md` 为 `phase=PLAN`、`blocked=false`、`autonomy.mode=manual`；主 agent 刚写完 `plan.md`。
- **When**: 主 agent 结束本回合回复。
- **Then**: 回复末尾出现固定结构收尾区块：战况含 `PLAN`/`manual`；推荐下一步为进入推演；至少有一个 fenced code block，内含**完整**可复制用户消息，正文以 `/sandtable-rehearse` 或 `/sandtable-mental` 开头并带当前 feature 上下文占位；另有一个备选模版提及 `/sandtable-autopilot` 或 `/sandtable-refine`。
- **状态**: 待验证

## TC2 · 多分支时调用 AskQuestion

- **映射**: FR3；验收「手动模式多分支用 AskQuestion」
- **Given**: `phase=PLAN`、`autonomy.mode=manual`、`blocked=false`；存在至少两条合理下一步（联合推演 vs autopilot）。
- **When**: 主 agent 结束本回合。
- **Then**: 主 agent 调用 AskQuestion，选项覆盖「只跑推演」「autopilot 全流程」「先 refine」等互斥路径；用户选定后，下条可复制模版与所选路径一致。若环境无 AskQuestion 工具，则须在收尾区块用编号列表代替，并声明「请复制对应编号模版」。
- **状态**: 待验证

## TC3 · autopilot 非阻塞时不弹 AskQuestion 且自动续跑

- **映射**: FR4, MUST「autopilot 不弹是否继续」；验收「autopilot 不被打断」
- **Given**: `state.md` 为 `autonomy.mode=autopilot`、`blocked=false`、`phase=PLAN`，且 `autonomy.completed_rounds.mental=0`。
- **When**: `/sandtable-autopilot` 刚完成 PLAN 阶段输出。
- **Then**: 主 agent **不**调用 AskQuestion 问「是否继续」；在同一命令执行内进入 `MENTAL_REHEARSAL`；输出**战报收尾** profile（战况 + `last_decision` + 续跑声明），**不含**完整可复制模版块；不要求用户点击继续。
- **状态**: 待验证

## TC4 · blocked 时收尾指向 questions.md

- **映射**: FR5；验收「blocked 可恢复」
- **Given**: `state.md` 为 `blocked=true`、`phase=OBJECTIVES`，`questions.md` 有一条状态为「待答复」的阻塞问题 Qx。
- **When**: 主 agent 结束本回合。
- **Then**: 收尾区块战况含 `blocked=true`；推荐下一步说明需先答复 Qx；可复制模版为针对 Qx 的澄清答复或 `/sandtable-resume`；AskQuestion 选项含「我已答复，续跑」类选项（manual 模式下）。
- **状态**: 待验证

## TC5 · phase 映射与 using-sandtable 状态机一致

- **映射**: FR6, 验收「映射表一致」
- **Given**: 开发者抽查 `skills/closing-the-loop/SKILL.md` 中的 phase 表。
- **When**: 对照 `skills/using-sandtable/SKILL.md` 阶段表与 `skills/state-and-memory/SKILL.md` 的 phase 枚举。
- **Then**: 每个 phase（含 INTAKE…DONE 及异常回退到 OBJECTIVES/MENTAL 等）都有默认下一步命令；不存在 using-sandtable 有而 closing-the-loop 缺的 phase；命令名与 using-sandtable 表一致（如 `/sandtable-rehearse` 不负责 intake）。
- **状态**: 待验证

## TC6 · 接入点索引可发现 closing-the-loop

- **映射**: FR7；验收「单一事实来源可发现」
- **Given**: 用户项目已安装 sandtable 插件，仅读 `skills/using-sandtable/SKILL.md`、`.cursor/rules/sandtable.mdc`、`commands/sandtable-start.md`。
- **When**: 开发者查找「回合收尾」「下一步模版」相关指令。
- **Then**: 上述文件均引用 `closing-the-loop` skill；`sandtable-start` **步骤 4**（OBJECTIVES 待确认）与**步骤 7**（PLAN 完成）均要求完整收尾；rules 的技能索引含 `closing-the-loop`。
- **状态**: 待验证

## TC7 · 英文安装后收尾区块为英文

- **映射**: FR7, MUST「同步 en 镜像」
- **Given**: 用户用英文官方安装提示词安装；`locales/en/skills/closing-the-loop/SKILL.md` 存在。
- **When**: 主 agent 在英文技能环境下完成 `phase=PLAN` 收尾。
- **Then**: 收尾区块标题与模版正文为英文；slash 命令名仍为 `/sandtable-*`；语义与中文版等义。
- **状态**: 待验证

## TC8 · Sandtable 工作步结束且需确认时必须收尾

- **映射**: FR8；开发者「要结束、要确认就走流程」
- **Given**: 主 agent 刚写完 `prd.md` 并更新 `state.md` 为 `phase=OBJECTIVES`，判断需要开发者确认 PRD。
- **When**: 主 agent 准备结束本回合。
- **Then**: **必须**输出 closing-the-loop 四段结构 + AskQuestion 或可复制「确认/修改」模版；不得仅用一句「请确认」而无战况与模版；**不得**在 PRD 待确认时推荐「直接进入 TESTCASES」类可复制文案（须为确认/修改语义）。

## TC8b · 非 Sandtable 对话不强制收尾

- **映射**: FR8 边界, MUST NOT「普通 coding 不强加」
- **Given**: 用户要求「修 README 一个 typo」，本回合**非 Sandtable 工作步**（即使 agent 读过 `docs/sandtable/` 也不得因此触发收尾）。
- **When**: 主 agent 完成修改。
- **Then**: 回复**不包含** Sandtable 回合收尾四段结构。
- **状态**: 待验证

## TC10 · autopilot 命令完全结束时完整收尾

- **映射**: FR2 完整 profile、FR4 终局、MUST「可复制模版」
- **Given**: `/sandtable-autopilot` 已跑完全部配额并完成 debrief；`state.md` 为 `phase=EVALUATE` 或 `DONE`、`autonomy.mode=autopilot`、`blocked=false`。
- **When**: autopilot 命令即将结束（无下一自动阶段）。
- **Then**: 输出**完整收尾**四段（含 `📋 复制即用` fenced 模版，如确认落地或 `/sandtable-status`）；不得仅用 `sandtable-autopilot` 原步骤7式散文报告代替。
- **状态**: 待验证

## TC9 · /sandtable-status 只读仍给模版

- **映射**: FR1, FR2；验收 status 命令增强
- **Given**: 用户执行 `/sandtable-status`，主 agent 只读不改文件。
- **When**: 汇报战况结束。
- **Then**: 在只读约束下仍输出推荐下一步 + 可复制模版（与 closing-the-loop 一致）；明确标注「本次未改任何文件」。
- **状态**: 待验证
