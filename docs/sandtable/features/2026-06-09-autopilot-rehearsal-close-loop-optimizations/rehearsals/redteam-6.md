# Redteam 6 Report

**Status:** `BREACH_FOUND`

## Scope

mental-11 闭环后复攻 `plan.md`，重点检查：

- T1/T2/T5/T6: 结构化核对基准、历史 `min_rounds` 保留、续接与 live 完整性闸门。
- T3/T4/T7/T8: session-start 注入层、behavior baseline、真实问题口径、close loop 已选择路径续跑与镜像同步。

本轮只接受真实、可复现、会打穿 PRD/tests/plan 的问题；空泛风险、偏题脑洞和无触发路径的猜测不计入 breach。

## Result

3 个红军子 agent 返回：

- 2 个指出 `prd.md` 独立验收标准章节未进入结构化基准和覆盖矩阵。
- 1 个指出 T3 任务级文件清单缺少 `using-sandtable` 四镜像，导致 session-start 注入层旧推演铁律可逃逸。

主 agent 核实后确认两者均为真实可复现破口，已修正 `plan.md`。

## Breaches

### R6-B34: T3 文件清单缺少 `using-sandtable` 四镜像

**复现路径:**

1. implementation 子 agent 按 T3 的任务级文件清单做外科手术式编辑。
2. T3 步骤3.6 要求收窄 `using-sandtable` 的推演铁律、异常修正和 Red Flags，但 `using-sandtable` 四镜像不在 T3 文件清单中。
3. T4/T7 虽然也列出 `using-sandtable`，但各自只负责红蓝一句和 close loop 一句，不能替代 T3.6。
4. T8 以任务文件列表为最终同步检查依据，且旧 blanket 搜索词不完整。
5. `hooks/session-start` 继续注入未收窄的 `using-sandtable/SKILL.md`，把无关边缘意外升级成 anomaly。

**打穿:** TC5、TC6、TC20、FR4。

**修正:**

- T3 文件清单补入 `skills/using-sandtable/SKILL.md`、`plugins/sandtable/skills/using-sandtable/SKILL.md`、`locales/en/skills/using-sandtable/SKILL.md`、`locales/en/plugins/sandtable/skills/using-sandtable/SKILL.md`。
- T8 搜索短语补入 `意料之外`、`意外`、`unexpected`、`surprise`、`anomaly or unexpected`、`immediately report`、`顺手修`。

### R6-B35: `prd.md` 独立验收标准未进入闸门基准

**复现路径:**

1. impl 候选通过完整性闸门，报告记录 FR/MUST/MUST NOT、TC、PLAN checkbox 的结构化基准。
2. 之后仅修改 `prd.md` §6 验收标准中的某条 bullet，不改变 FR/MUST/MUST NOT、TC 或 PLAN checkbox。
3. `/sandtable-autopilot`、`/sandtable-resume`、`/sandtable-rehearse` 或 `/sandtable-debrief` 比对旧基准时，因基准未包含 §6 独立验收标准，误判未过期。
4. 旧实现可在不满足新版验收标准的情况下进入 debrief。

**打穿:** TC9、TC10、TC11、FR6。

**修正:**

- T5 结构化核对基准补入 `prd.md` 独立验收标准稳定键 `PRD-AC1...PRD-ACn` 及每条 bullet 正文 hash。
- implementation `DONE` 覆盖矩阵新增 `PRD 验收标准覆盖: PRD-AC1 ... PRD-ACn`。
- live TODO 表允许并要求追踪 `PRD-ACx`。
- evaluating/debrief 过期检查和键集合校验纳入 `PRD-AC`。
- T5/T6 验证新增“仅修改 `prd.md` 独立验收标准，FR/MUST/TC/PLAN 标识不变”场景。

## Held

- B30 同 ID 正文 hash: FR/TC/PLAN checkbox 正文变化已进入基准。
- B31 历史 `min_rounds` / `min_agents_per_round`: 续接与 manual→autopilot 不覆盖历史配额。
- B28/B29 文档部分缺失与 manual→autopilot: 已按“有状态或文档即续接”处理。
- B33 close loop 已选择路径: HARD-GATE 已为本回合明确选择路径加例外，阻塞仍优先。
- redteam 真实攻破口径: T4 计划已要求可复现、相关、有证据，不鼓励偏题击溃。

## Next

已修正 `plan.md`。按 Sandtable 铁律，重新运行 mental，闭环后再跑 redteam；全部守住后进入 implementation rehearsal。
