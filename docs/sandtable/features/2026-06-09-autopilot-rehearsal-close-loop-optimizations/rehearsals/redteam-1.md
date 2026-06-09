# REDTEAM 轮 1 · 计划红蓝对抗

**信号:** `BREACH_FOUND`

## 范围

mental-2 闭环后，红军并行攻击当前 `plan.md`：

- T1/T2：自动模式最低覆盖、autopilot/resume 续接、状态模板与恢复语义。
- T3/T4/T7：头脑推演/红蓝对抗真实问题口径、close loop 已选择即执行。
- T5/T6/T8：实现预演完整性闸门、live 执行 TODO 表、镜像验证。

红军交战规则：只接受真实、可复现、与 PRD/tests/plan/code reality 相关的破口；空泛风险、纯猜测、偏题极端场景不算 `BREACH_FOUND`。

## 核实成立的破口与修正

### B1 · `/sandtable-autopilot` 续接会清空进行中进度

- 攻击向量: 回归伏击 / 需求背离。
- 复现: feature 已在 autopilot 且 `completed_rounds={ mental:1, redteam:0, impl:0 }`；用户再次触发 `/sandtable-autopilot`；旧计划未要求区分冷启动与续接，可能重置 `completed_rounds` 并回到 `RECON`。
- 影响: TC2/TC3 失败，同一 feature 续接行为和 `/sandtable-resume` 分裂。
- 修正: T1 步骤2/7 已补“冷启动 vs 续接”语义：仅新建/原始需求启动时初始化；已有 `state.md` 的 autopilot 续接必须保留 `completed_rounds` 与 `phase`。

### B2 · 英文 state bundle 只补 FEEDBACK 分支仍可能保留 `else EVALUATE`

- 攻击向量: 红线渗透 / 镜像伏击。
- 复现: 英文 locale 读 `locales/en/skills/SKILL.md` 或 `locales/en/plugins/sandtable/skills/SKILL.md`；只补 FEEDBACK/DONE 分支但不替换 `else EVALUATE`；三类最低覆盖达成后跳过自主裁决。
- 影响: TC2/TC3/TC18 失败。
- 修正: T2 步骤4 已补：英文 bundle 必须同步步骤3全文，既补 FEEDBACK/DONE，也替换 `else EVALUATE` 为自主裁决。

### B3 · mental 旧“不确定即 anomaly”文本会继续打穿真实问题口径

- 攻击向量: 需求背离 / 红线渗透。
- 复现: 只改 prompt 或主规则，但保留 mental skill / Red Flags 中“不确定本身就是 anomaly”“大概=没确认，要么确认，要么上报”；边缘无关疑问仍触发 anomaly。
- 影响: TC5 失败。
- 修正: T3 步骤3 已补：同步清理与新口径冲突的旧文本和相关 Red Flags，只保留关键且影响决策的不确定点才上报。

### B4 · redteam 旧“唯一使命/往死里打”文本会继续鼓励偏题击溃

- 攻击向量: 需求背离 / 边界突袭。
- 复现: 只改开头或命令铁律，漏掉 red-team skill 的进攻向量段或 prompt 的“攻破任一即 BREACH”旧语义；红军仍构造无现实触发路径的破口。
- 影响: TC7 失败。
- 修正: T4 步骤1/3 已补：全文处理“唯一使命/往死里打”，覆盖进攻向量段，并限定真实、相关、可复现地攻破才算 `BREACH_FOUND`。

### B5 · close loop 只改收尾，无法覆盖下一条确认消息的回合初入口

- 攻击向量: 需求背离。
- 复现: `/sandtable-start` 写完 PRD 停止；用户下一条消息确认“继续写 tests”；如果只改 `closing-the-loop`，agent 回合初未必加载它，仍可能只输出复制命令。
- 影响: TC12/TC13 失败。
- 修正: T7 文件列表和步骤已补 `/sandtable-start`、`/sandtable-objectives` 与 `writing-prd`：确认消息本身授权进入 TESTCASES；无真实阻塞时应直接加载 `writing-tests`。

### B6 · close loop 新规则未写阻塞优先，可能吞掉真实阻塞

- 攻击向量: 红线渗透。
- 复现: `blocked=true` 或存在真实阻塞，同时用户说“继续”；若“已选择路径优先”插入在阻塞判断前，agent 会继续执行。
- 影响: TC15 失败。
- 修正: T7 步骤1 已补：该规则必须排在 `blocked=true` / 真实阻塞判定之后；阻塞时先写 `questions.md`、设置 `blocked=true` 并提问。

### B7 · plan/tests/prd 变更后旧 impl 完成轮次和闸门结论不失效

- 攻击向量: 回归伏击。
- 复现: impl 通过闸门后计入完成；随后 redteam/mental 修正 `plan.md`；resume/autopilot 仍按旧 impl 完成轮次进入评估。
- 影响: TC10/TC11 失败。
- 修正: T5 步骤7 与 T6 步骤3 已补：`prd.md` / `tests.md` / `plan.md` 变更后既有 impl 完成轮次和闸门结论失效，必须重新跑完整性闸门；影响实现路径时重新 live。

### B8 · 完整性闸门只写 prose，不强制修改 dot 图和 Red Flags

- 攻击向量: 需求背离 / 回归伏击。
- 复现: 实现者只加关键词，不改 `implementation-rehearsal` dot 图；后续 agent 仍按图从 `全部 DONE` 直接到 `evaluating-rehearsals`。
- 影响: TC9-TC11 失败。
- 修正: T5 步骤2 已补：dot 图必须改为 `全部 DONE -> 完整性闸门 -> evaluating-rehearsals`，不得保留直接边；相关 Red Flags 也必须同步。

### B9 · 闸门结论落盘位置分裂，debrief 无稳定判定来源

- 攻击向量: 侧翼包抄。
- 复现: 完整性结论只写 journal；debrief 检查 impl 报告；标准不一致。
- 影响: TC11 失败。
- 修正: T5 步骤1 已改为结论必须写入对应 `rehearsals/impl-*.md`；journal 只能摘要。

### B10 · 覆盖矩阵与 live TODO 表冲突时无裁决

- 攻击向量: 需求背离。
- 复现: 覆盖矩阵写 `PLAN T7 -> 已完成`，但 TODO 表中 `PLAN T7/步骤x` 为 `missing`；无规则说明以哪边为准。
- 影响: TC9/TC10 失败。
- 修正: T5 步骤5 已补：若覆盖矩阵与 TODO 表冲突，以更细粒度的 `missing` / `blocked` 为准；任一来源显示未覆盖，候选不得视为 `DONE`。

### B11 · `sandtable-mental` 六镜像不在总文件地图，T8 可能漏检

- 攻击向量: 多镜像侧翼包抄。
- 复现: T3 修改 mental 命令，但顶部文件地图未列；T8 若只按文件地图核对会漏掉 `.cursor` 或 plugin 镜像。
- 影响: TC17 失败。
- 修正: 已把 `sandtable-mental` 六镜像加入顶部文件地图；T8 步骤1 也明确最终核对以所有任务文件列表为准，不只看顶部文件地图。

## 残余风险

- `being-truthful` 的通用“不确定必须弄清”与 mental 新口径存在张力，但当前需求只要求调整推演/红蓝对抗口径，未列为本轮修改目标。
- T1/T5/T6 职责交叉较多，实现时必须按 T8 做最终短语和镜像验证。

## 处理结果

已修正 `plan.md`。本轮 redteam 仍记录为 `BREACH_FOUND`，需要重新运行 mental/redteam 确认修正闭环后再进入 live。
