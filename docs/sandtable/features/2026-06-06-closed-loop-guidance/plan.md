# 回合收尾与下一步引导 · 改动计划

**目标:** 新增 `closing-the-loop` skill，让每次 Sandtable 回合结束都有战况 + 可复制模版 +（手动多分支时）AskQuestion；autopilot 自动续跑不打断。

**架构:** 单一 skill 维护 phase/block/autonomy 决策表；`using-sandtable`、rules、`AGENTS.md`、13 个 commands、`autonomous-orchestration` 交叉引用；中英与 `plugins/sandtable` 镜像同步。不写入用户 `templates/`。

**对应 PRD:** prd.md  
**推演要求:** 本计划将由头脑预演、红蓝对抗、实现预演子 agent 逐任务推演。

## 文件地图

| 文件 | 职责 |
|------|------|
| `skills/closing-the-loop/SKILL.md` | **新建** · 收尾纪律、phase 映射表、模版样例、AskQuestion 规则 |
| `skills/using-sandtable/SKILL.md` | 追加「回合收尾」节 + 技能索引项 |
| `skills/autonomous-orchestration/SKILL.md` | 追加与 closing-the-loop 的交叉引用（autopilot 不 AskQuestion） |
| `skills/state-and-memory/SKILL.md` | 技能索引追加 `closing-the-loop`（一行） |
| `.cursor/rules/sandtable.mdc` | 技能索引 + FR8 正负触发（非 Sandtable/未触达 docs 不收尾） |
| `AGENTS.md` | 同 rules 索引 |
| `commands/sandtable-*.md`（13 个） | 各命令末尾加「完成后加载 closing-the-loop」 |
| `.cursor/commands/sandtable-*.md` | 与 commands 同步 |
| `plugins/sandtable/skills/**` | 与 `skills/**` 同步 |
| `locales/en/skills/**` + `locales/en/plugins/**` | 英文等义镜像 |
| `locales/en/.cursor/rules/sandtable.mdc` + `locales/en/AGENTS.md` | 英文 rules |

---

### 任务 T1: 新建 `closing-the-loop` skill（中文源）

**文件:**
- 创建: `skills/closing-the-loop/SKILL.md`

- [ ] 步骤1: 写入 skill frontmatter 与硬门禁

```markdown
---
name: closing-the-loop
description: Use at the end of every Sandtable work turn—after a slash command or phase artifact update—to report status, offer copy-paste next-message templates, and invoke AskQuestion in manual mode when multiple valid branches exist. In autopilot, auto-continue without asking.
---

# 回合收尾 · 让沙盘机制可被感知

**开始时声明：** "我在用 closing-the-loop 做回合收尾。"

<HARD-GATE>
1. **触发条件（正）**：本回合已读写 `docs/sandtable/`，且完成 Sandtable 阶段动作或需用户确认/选下一步 → 必须输出收尾（见两种 profile）。
2. **触发条件（负）**：本回合**非 Sandtable 工作步** → **禁止**收尾（含第三态：即使已读写 `docs/sandtable/` 也不得触发，TC8b）。
3. **触发条件（负）**：与 Sandtable 无关 → **禁止**收尾（无论是否触达 `docs/sandtable/`）。
4. `autonomy.mode=manual` 且 ≥2 条合理下一步 → **必须**调用 AskQuestion（工具可用时）。
5. `autonomy.mode=autopilot` 且 `blocked=false` → **禁止** AskQuestion 问「是否继续」；按 autonomous-orchestration 同命令内续跑。`blocked=true` 时走完整收尾 + FR5 AskQuestion（阻塞优先）。
6. 有活跃 feature 时先读其 `state.md`；无活跃战役时仅给 `/sandtable-start` 模版（**不得**为 typo 等非 Sandtable 任务主动读盘以触发收尾）。
</HARD-GATE>

## 两种收尾 profile

| profile | 何时用 | 结构 |
|---------|--------|------|
| **完整收尾** | manual；命令边界结束；blocked；需开发者确认（含 OBJECTIVES 待确认 PRD） | 四段：战况 / 推荐 / 可复制模版 / 其他路径 |
| **战报收尾** | autopilot 非阻塞阶段切换；链式命令（rehearse/autopilot）**中间**阶段切换 | 战况 + `autonomy.last_decision` +「已自动续跑至 \<phase\>」；**省略** AskQuestion 与完整模版/分支 |
```

- [ ] 步骤2: 写入收尾区块四段结构（战况 / 推荐 / 可复制模版 / 分支）

```markdown
## 回合收尾区块（固定结构）

### 🧭 战况
- feature: `<id>`
- phase: `<PHASE>` · blocked: `<true|false>` · mode: `<manual|autopilot>`

### ➡️ 推荐下一步
（一句话，与 phase 映射表一致）

### 📋 复制即用
​```text
（完整下一条用户消息，含 slash + 必要上下文）
​```

### 🔀 其他路径（可选）
​```text
（备选模版，每条独立 fenced block）
​```
```

- [ ] 步骤3: 写入 phase → 默认下一步映射表（核心行）

| phase | 默认下一步 | 主推 slash |
|-------|-----------|------------|
| INTAKE / RECON | 定目标 | `/sandtable-objectives` 或继续 `/sandtable-start` |
| OBJECTIVES · PRD 待确认 | 请开发者确认 PRD（**不得**推荐进入 TESTCASES；遵守 `writing-prd` 硬门禁） | AskQuestion + 确认/修改模版；备选 `/sandtable-refine` |
| OBJECTIVES · PRD 已确认 | 写用例 | `/sandtable-plan` 前置为 tests：`/sandtable-refine` 或进入 TESTCASES 写 `tests.md` |
| TESTCASES | 写计划 | `/sandtable-plan` |
| PLAN | 进入推演 | `/sandtable-rehearse` |
| MENTAL_REHEARSAL | 继续 mental 或 redteam | `/sandtable-mental` / `/sandtable-redteam` |
| REDTEAM | 继续 redteam 或 impl | `/sandtable-redteam` / `/sandtable-live` |
| IMPL_REHEARSAL | 继续 impl 或复盘 | `/sandtable-live` / `/sandtable-debrief` |
| EVALUATE | 落地 / 择优后确认 | 可复制「确认合并选定实现」或 `/sandtable-status` 查战报 |
| INTEGRATE | 验证 | VERIFY 清单 |
| VERIFY / DONE | 战报 / 新需求 | `/sandtable-status` / `/sandtable-start` |
| blocked=true | 解阻塞 | 答复 `questions.md` 或 `/sandtable-resume` |
| 异常回退 | 重演 | 依 `autonomy.last_decision` 指向 OBJECTIVES / mental / redteam / plan（对齐 `using-sandtable` FIX→OBJ） |

- [ ] 步骤4: 写入 OBJECTIVES·PRD待确认 与 PLAN 阶段可复制模版样例

```markdown
### 样例 · phase=OBJECTIVES, PRD 待确认, manual

​```text
PRD 方向认可。请把 state.phase 更新为 TESTCASES 并继续写 tests.md。
​```
（注：模版措辞不得写成「直接进入 TESTCASES」而无确认语义；未确认前 phase 保持 OBJECTIVES。）

​```text
/sandtable-refine

先改 PRD：\<具体修改点\>
​```
```

（交叉引用 `writing-prd`：未确认前 `state.phase` 保持 OBJECTIVES。）

### 样例 · phase=PLAN, manual

```markdown
### 样例 · phase=PLAN, manual

​```text
/sandtable-rehearse

对 feature `2026-06-06-closed-loop-guidance` 执行联合预演（mental → redteam → impl → debrief）。
​```

​```text
/sandtable-autopilot

从当前 feature 续跑自动模式，完成推演链路与复盘择优。
​```
```

- [ ] 步骤5: 写入 AskQuestion 与 autopilot 纪律 + Red Flags 表

- [ ] 步骤6: 验证步骤引用 `TC1` `TC2` `TC3` `TC4` `TC5`：人工读 skill，核对映射表覆盖全部 phase、结构与样例齐全。

---

### 任务 T2: 接入主入口与 rules

**文件:**
- 修改: `skills/using-sandtable/SKILL.md`（在「触发规则」前插入「回合收尾」节）
- 修改: `skills/state-and-memory/SKILL.md`（文末「恢复流程」前追加「相关技能」索引段，含 `closing-the-loop` 一行；不改 Red Flags 表）
- 修改: `.cursor/rules/sandtable.mdc`（技能索引 + FR8 正负触发明文，禁止裸「每回合收尾」）
- 修改: `AGENTS.md`（同 rules）

- [ ] 步骤1: 在 `using-sandtable` 追加：

```markdown
## 回合收尾（Sandtable 工作步结束时）

仅当本回合为 **Sandtable 工作步**（正触发见 `closing-the-loop` FR8）时，加载 `skills/closing-the-loop/SKILL.md` 并输出收尾。非 Sandtable 任务（如修 typo）**禁止**收尾，即使读过 `docs/sandtable/`。手动多分支用 AskQuestion；autopilot 非阻塞用战报收尾并同命令续跑。
```

- [ ] 步骤2: 三处技能索引追加 `- closing-the-loop — 回合收尾：战况、可复制模版、AskQuestion 纪律`

- [ ] 步骤3: 验证步骤引用 `TC6`：`rg -n "closing-the-loop" skills/using-sandtable/SKILL.md .cursor/rules/sandtable.mdc AGENTS.md commands/sandtable-start.md`

---

### 任务 T3: 更新 commands 与 autonomous-orchestration

**文件:**
- 修改: `skills/autonomous-orchestration/SKILL.md`
- 修改: `commands/sandtable-*.md`（13 个）
- 修改: `.cursor/commands/sandtable-*.md`（13 个）
- 修改: `plugins/sandtable/commands/sandtable-*.md`（13 个，与 commands 同步）

- [ ] 步骤1: 在 `autonomous-orchestration` 「自动流程」第 3 点后追加：

```markdown
3.5 自动阶段**切换时**加载 `closing-the-loop` 的**战报收尾** profile（非完整四段）；不 AskQuestion；**同一 `/sandtable-autopilot` 命令内**立即执行下一合法阶段。命令完全结束或 `blocked=true` 时输出**完整收尾**（若 manual 切换回则走完整 profile）。
```

- [ ] 步骤2a: **重写 `sandtable-start.md` 结构**（对齐 TC6/TC8；消除 1→7 单条消息矛盾）：
  - 步骤1–3：INTAKE → RECON（同现稿）。
  - 步骤4 OBJECTIVES：写完 `prd.md` 后加载 closing-the-loop → **完整收尾** → **命令在此结束**；正文写明「不得在本命令内继续步骤5–6；待开发者确认后另发消息续跑」。
  - 步骤5–6：标注为「确认 PRD **之后**的续跑步骤」（可由用户确认消息或 `/sandtable-refine` 触发，非 start 单次执行）。
  - 步骤7（PLAN 完成后）：完整收尾，**替换**原步骤7自然语言列表；「其他路径」保留 `/sandtable-refine`、说明 `/sandtable-rehearse`=四步合一。
- [ ] 步骤2b: **`sandtable-rehearse.md` 专项**：链内 mental→redteam→impl→debrief **中间切换**仅**战报收尾**（禁止省略）；命令结束/阻塞/异常停时完整收尾；**替换**步骤7「等我确认」为 closing-the-loop 完整收尾。
- [ ] 步骤2c: 其余 **9** 个 command 末尾追加：

```markdown
N. 完成后加载 `skills/closing-the-loop/SKILL.md`，读 `state.md`，输出收尾（本命令已列出的链内后续步骤除外；链内切换用战报 profile）。不得越权执行**本命令未列出**的下一阶段（`/sandtable-autopilot`、`/sandtable-rehearse` 除外）。
```

- [ ] 步骤3: `sandtable-status.md` 步骤 6 改为：

```markdown
6. 给出「下一步建议动作」**并**按 closing-the-loop 输出可复制模版；本次只读，不改任何文件。
```

- [ ] 步骤4: **替换** `sandtable-autopilot.md` 原步骤7，合并为：

```markdown
7. 各阶段之间不等待用户确认；阶段切换时更新 state、输出**战报收尾** profile，并在同一命令内继续执行。全部配额达标并完成复盘择优后，加载 closing-the-loop 输出**完整收尾**（含可复制模版）。`blocked=true` 时输出**完整收尾**并可用 AskQuestion（FR5 优先于 autopilot 静默纪律）。
```

- [ ] 步骤5: 验证步骤引用 `TC9`：读 `commands/sandtable-status.md` 含 closing-the-loop 与只读声明。

---

### 任务 T4: 同步镜像与英文 locale

**文件:**
- 复制/翻译: `plugins/sandtable/skills/closing-the-loop/SKILL.md`
- 复制/翻译: `locales/en/skills/closing-the-loop/SKILL.md`
- 复制/翻译: `locales/en/plugins/sandtable/skills/closing-the-loop/SKILL.md`
- 同步: 所有 T2/T3 改动到 `plugins/sandtable/` 与 `locales/en/` 对应路径（**不需改** `hooks/session-start`；经 `using-sandtable` 注入间接覆盖）

- [ ] 步骤1: `cp skills/closing-the-loop/SKILL.md plugins/sandtable/skills/closing-the-loop/SKILL.md`

- [ ] 步骤2: 撰写 `locales/en/skills/closing-the-loop/SKILL.md` 与 `locales/en/plugins/sandtable/skills/closing-the-loop/SKILL.md`（英文等义）

- [ ] 步骤3: 同步 **中文** `plugins/sandtable/skills/`（using-sandtable、state-and-memory、autonomous-orchestration、closing-the-loop）与 **中文** `plugins/sandtable/commands/`（13，与 `commands/` 一致）
- [ ] 步骤3b: 同步 **en** 双 skill 树 + `locales/en/AGENTS.md` + `locales/en/.cursor/rules/sandtable.mdc`（含 FR8 第三态）；以及 **39 个 en command 文件**

- [ ] 步骤4: 验证步骤引用 `TC7` `TC6`：
  - `test -f locales/en/skills/closing-the-loop/SKILL.md`
  - `find locales/en/commands locales/en/.cursor/commands locales/en/plugins/sandtable/commands -name 'sandtable-*.md' | wc -l` 预期 **39**
  - `rg -L "closing-the-loop" locales/en/commands locales/en/.cursor/commands locales/en/plugins/sandtable/commands` 预期 **无输出**
  - `rg -n "Full close|Status bulletin" locales/en/skills/closing-the-loop/SKILL.md` 预期命中

---

## 全局验证（VERIFY 阶段）

- [ ] `rg -n "closing-the-loop" skills commands .cursor/commands plugins/sandtable/commands plugins/sandtable/skills AGENTS.md .cursor/rules locales/en` 覆盖全部接入点
- [ ] `diff -qr commands plugins/sandtable/commands` 预期无差异（中文 command 镜像一致）
- [ ] 对照 `tests.md` TC1–TC10 与 TC8b 逐条人工核对（实现后）
- [ ] 确认未修改 `templates/`、未新增 node/python 依赖
