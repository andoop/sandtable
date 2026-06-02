# 测试用例产物 tests.md · 改动计划

**目标:** 给 Sandtable 增加一等公民产物 `tests.md`（黑盒、场景化、人可读的测试用例），定位在 OBJECTIVES 与 PLAN 之间，检验 AI 理解并给三类推演统一突破点。
**架构:** 新增 1 个模板 + 1 个技能；在状态机插入 phase `TESTCASES`；脚手架多拷一个模板；三类推演 prompt 注入逐条用例；并把闭环图/索引/目录结构/命令编排等所有副本同步自洽。内容单一来源于 `templates/`，外科手术式改动，不动无关已调校文本。
**对应 PRD:** prd.md（FR1-FR6）　**测试用例:** tests.md（TC1-TC8）
**推演要求:** 本计划由头脑预演、红蓝对抗、实现预演子 agent 逐任务推演。重点攻击面：①phase `TESTCASES` 是否在所有副本一致插入且位置正确（README/AGENTS 缩写式 vs .cursor/rules 中文全称式 vs 枚举式三种写法）②tests.md 与 PRD §5 / plan TDD 是否真正职责不重叠（映射硬约束）③init 改动后是否仍幂等、零依赖、不覆盖 ④三类推演 prompt 是否真把用例落到"逐条" ⑤命名 `tests.md`/`writing-tests`/`TESTCASES` 全仓自洽、双命令副本同步 ⑥未破坏现有 json/脚本/无关 skill 文本。

## 文件地图
- 创建 `templates/tests.md` — 测试用例模板（黑盒结构 + 职责边界 + 审阅指引）。
- 创建 `skills/writing-tests/SKILL.md` — 派生/修正测试用例的技能（映射门禁 + 三产物边界 + UX）。
- 修改 `scripts/sandtable-init.sh:77,83` — 拷贝列表加 `tests.md` + 注释 5→6。
- 修改 `skills/state-and-memory/SKILL.md:13-27,38,64` — 目录结构 + phase 枚举 + 回退锚点。
- 修改 `templates/state.md:3` — phase 枚举注释。
- 修改 `skills/using-sandtable/SKILL.md:44,55-70` — dot 图 + 阶段表 + refine 行 + "前五步"。
- 修改 `README.md:23,58,93-116` — 闭环图 + /start 描述 + skills 列表/目录结构。
- 修改 `AGENTS.md:22,43`（=CLAUDE.md 软链） — 闭环序列 + 技能索引。
- 修改 `.cursor/rules/sandtable.mdc:22,36,38-49` — 闭环 + feature 产物清单 + 技能索引。
- 修改 `skills/writing-prd/SKILL.md:15,28-32,42,70` — 内部路由三处 + §5 重定位。
- 修改 `templates/prd.md:18-20` — §5 注释改为"抽象成功定义，具体下沉 tests.md"。
- 修改 `skills/writing-plan/SKILL.md:12-16,68-76` — 前置加 tests.md + 验证引用 TC + 自查表。
- 修改 `skills/mental-rehearsal/mental-rehearsal-prompt.md`、`skills/implementation-rehearsal/implementation-rehearsal-prompt.md`、`skills/red-team-wargame/opfor-prompt.md` — 注入待验证用例块。
- 修改命令（各双副本 `commands/` + `.cursor/commands/`）：`sandtable-start`、`sandtable-objectives`、`sandtable-plan`、`sandtable-resume`、`sandtable-refine`、`sandtable-rehearse`、`sandtable-mental`（写回清单）。
- 修改 `skills/using-sandtable/SKILL.md:88`、`skills/being-truthful/SKILL.md:44` — 异常写回清单加 tests.md（T10）。
- 修改 `skills/writing-prd/SKILL.md:3`、`skills/writing-plan/SKILL.md:3`、`commands/sandtable-start.md:2`(+副本) — frontmatter 描述路由（T10）。
- 修改 `docs/sandtable/project.md:9` — skills 10→11 / templates 7→8 + feature 文件清单加 tests。

---

### 任务 T1: 新增测试用例模板 templates/tests.md
**文件:** 创建 `templates/tests.md`
- [ ] 步骤1: 写入以下内容（黑盒；映射源含 FR/验收/MUST/MUST NOT；含职责边界与审阅指引；尖括号为写作占位，非 init 占位符）：
````markdown
# <需求名> 测试用例 · tests.md

> 黑盒、场景化、人可读。每条用例必须映射回 prd.md 的某条 FR / 验收标准 / MUST / MUST NOT（映射硬约束，见 writing-tests）。
> 职责（边界）：本文件是检验理解的**唯一具体载体**（含可执行检查命令）；PRD §5 只写抽象成功定义；plan 验证步骤引用本文件 TC 编号、不另造预期。三者不重叠。
> 审阅指引：开发者**先读本文件**判断 AI 是否真懂（理解闸门）；§5 留作 VERIFY 勾选（完成闸门）。
> 状态字段：待验证 / 已验证。本文件随 PRD/plan 一起持续完善修正。

---

## TC1 · <一句话场景标题>
- **映射**：FR<编号> / 验收"<可追溯点>" / MUST 或 MUST NOT<条目>
- **Given**：<前置条件/初始状态>
- **When**：<触发的具体操作 + 具体输入>
- **Then**：<可观察的预期输出/结果，写具体值，不写"正确""正常">
- **状态**：待验证

## TC2 · <…>
- **映射**：…
- **Given**：…
- **When**：…
- **Then**：…
- **状态**：待验证
````
- [ ] 步骤2: 验证无编程语言断言/框架名（黑盒，TC7）  运行: `grep -nE "expect\(|assert|pnpm|jest|pytest" templates/tests.md`  预期: 无输出

### 任务 T2: 新增技能 skills/writing-tests/SKILL.md
**文件:** 创建 `skills/writing-tests/SKILL.md`
- [ ] 步骤1: 写入以下内容：
````markdown
---
name: writing-tests
description: Use after the PRD is confirmed and before writing the change plan, to derive concrete, black-box, human-readable test cases that verify whether the AI truly understands the requirement. Each case must map back to a PRD requirement or acceptance criterion. Produces docs/sandtable/features/<id>/tests.md.
---

# 写测试用例 · 检验"AI 真的懂了"的闸门（黑盒、人可读）

测试用例是 PRD 与计划之间的一道**理解对账闸门**。它把抽象的验收标准，具体化成"给定什么→做什么→应当看到什么"的场景；开发者读一眼就能判断 AI 是否真的理解了需求。它也是三类推演的统一**突破点**。

**开始时声明：** "我在用 writing-tests 把需求具体化为测试用例。"

## 硬门禁

<HARD-GATE>
1. 测试用例必须基于**已确认的 prd.md**。
2. **映射约束（防重复）：每条用例必须能追溯映射回某条 功能需求(FR) / 验收标准 / MUST / MUST NOT**；写不出映射的用例不要写。
3. 黑盒：用 Given/When/Then + 具体输入→预期输出表达，**技术栈无关、不含任何代码级断言**（代码级落地属于 plan）。
不确定的需求点回到 being-truthful，不在用例里发明需求。
</HARD-GATE>

## 三产物职责（别重复）

| 产物 | 职责 | 形态 |
|------|------|------|
| PRD §5 验收标准 | 抽象的"成功定义" | 高层、二元条件 |
| **tests.md（本技能）** | 把成功定义**具体化为可演练场景**，是检验理解的**唯一具体载体**（含可执行检查命令） | 黑盒 Given-When-Then + 具体输入/预期 |
| plan 的验证步骤 | 代码/命令级落地，**引用本文件 TC 编号**，不另造预期 | 依附任务/语言 |

> 边界：具体的可执行检查（grep/命令/示例输入）写在这里，不要回填进 §5；§5 保持抽象。这样三者不重叠。

## 开发者审阅指引（写给读 tests.md 的人）

- **tests.md = 理解闸门**：开发者**先读本文件**，逐条看 Given/When/Then，判断"AI 是否真的懂我要什么"。
- **PRD §5 = 完成闸门**：留到 VERIFY 阶段勾选"做完没"。

## 一条用例长什么样

- **编号 + 标题**：TC<N> · 一句话场景。
- **映射**：指向 FR / 验收 / MUST / MUST NOT 之一。
- **Given**：前置条件/初始状态。
- **When**：触发操作 + **具体输入**。
- **Then**：**具体的**预期输出/可观察结果（写真实值，禁止"正确/正常/没问题"）。
- **状态**：待验证 / 已验证。

覆盖正常路径 + 关键边界/异常路径（每条仍须可映射）。

## 自查（写完用新眼睛看一遍）

| 检查 | 修法 |
|------|------|
| 有用例映射不回任何 FR/验收/MUST/MUST NOT？ | 删除或先去补 PRD（不发明需求）|
| Then 写成"正确/正常"？ | 改成具体可观察的值 |
| 出现代码/框架名？ | 改成黑盒表达，代码级落地交给 plan |
| 只有正常路径？ | 补关键边界/异常用例（仍须可映射）|
| §5 里塞了具体命令/输入？ | 把具体的下沉到本文件，§5 只留抽象成功定义 |

## Red Flags

| 念头 | 现实 |
|------|------|
| "把验收标准抄过来就是用例" | §5 是抽象条件，这里要具体化成 Given/When/Then 场景。 |
| "这条用例映射不回需求，但挺有用" | 映射不回就不写——否则是发明需求/范围蔓延。 |
| "顺手写两句断言代码更准" | 这里只黑盒；代码级落地是 plan 的事。 |
| "Then 写'结果正确'就行" | 没有具体预期值的用例无法检验理解。写真实值。 |

完成并经开发者确认后，更新 `state.md`（phase=PLAN），加载 `writing-plan`。tests.md 随后作为三类推演的逐条突破点被注入各预演 prompt。
````
- [ ] 步骤2: 校验 frontmatter 与声明语句风格与其它 skill 一致  运行: `grep -n "name: writing-tests" skills/writing-tests/SKILL.md`  预期: 命中

### 任务 T3: 脚手架拷贝 tests.md
**文件:** 修改 `scripts/sandtable-init.sh:83`
- [ ] 步骤1: 把 feature 模板拷贝循环的列表从 `prd.md plan.md state.md journal.md questions.md` 改为含 `tests.md`：
```bash
	for f in prd.md tests.md plan.md state.md journal.md questions.md; do
		cp "$templates_dir/$f" "$feature_dir/$f"
		created+=("$feature_dir/$f")
	done
```
- [ ] 步骤2: 同步更新脚本内注释（`scripts/sandtable-init.sh:77` 的「feature 目录与 5 个模板」改为「6 个模板」）。
- [ ] 步骤3: 语法检查  运行: `bash -n scripts/sandtable-init.sh`  预期: exit 0
- [ ] 步骤4: 空目录幂等验证（TC1+TC2）  运行: 在 `$(mktemp -d)` 内 `cp -R <repo>/{templates,scripts} . && bash scripts/sandtable-init.sh demo 2026-06-02 && ls docs/sandtable/features/2026-06-02-demo` 然后再次运行同命令  预期: 首次列出 tests.md，二次 exit 1 不覆盖

### 任务 T4: 状态机插入 phase TESTCASES（所有权威副本一致）
**文件:** 6 处权威文本。TESTCASES 一律位于 OBJECTIVES（缩写式副本为其产物 PRD）之后、PLAN 之前；军事隐喻=标定靶标。
- [ ] 步骤1: `skills/state-and-memory/SKILL.md`：①第 38 行枚举改为 `INTAKE|RECON|OBJECTIVES|TESTCASES|PLAN|MENTAL_REHEARSAL|REDTEAM|IMPL_REHEARSAL|EVALUATE|INTEGRATE|VERIFY|DONE`；②目录结构块（13-27）在 `prd.md` 与 `plan.md` 之间加一行 `      tests.md                     # 测试用例 (见 writing-tests)`；③回退锚点 `:64` "把 phase 改回 OBJECTIVES 或 PLAN" 改为 "OBJECTIVES、TESTCASES 或 PLAN"。〔恢复流程 dot(:77-94) 无"读 prd.md"节点，不在此改；接防读 tests.md 由 T7 的 sandtable-resume 命令承载〕
- [ ] 步骤2: `templates/state.md:3` 枚举注释同样插入 `TESTCASES`。
- [ ] 步骤3: `skills/using-sandtable/SKILL.md`：①dot 图（44 行）`OBJ -> PLAN` 改为 `OBJ -> TESTS -> PLAN`，并加节点 `TESTS [shape=box label="TESTCASES\n标定靶标"];`；②异常修正回流 `FIX -> OBJ`(:50) 保持（从 OBJECTIVES 重走会重新经过 TESTCASES，无需改）；③阶段表（55-68）在 OBJECTIVES 与 PLAN 行之间加一行 `| TESTCASES | 标定靶标 | 把成功定义具体化为黑盒用例,检验理解 | writing-tests | （并入 /objectives, /refine 迭代）|`；④第 61 行 refine 行的"writing-prd/writing-plan"补为含 writing-tests；⑤第 70 行"`/sandtable-start` 编排前四步"改为"前五步"。
- [ ] 步骤4: `README.md`：①闭环图 `:23` 统一为 `INTAKE → CLARIFY → PRD → TESTCASES → PLAN → MENTAL_REHEARSAL → …`（保持缩写式）；②`/sandtable-start` 描述 `:58`"侦察→目标→计划"改为"侦察→目标→用例→计划"。
- [ ] 步骤5: `AGENTS.md:22`（=CLAUDE.md）闭环序列插入 `TESTCASES`（缩写式）；技能索引 `:43` 列表加 `writing-tests`。
- [ ] 步骤6: `.cursor/rules/sandtable.mdc`：①闭环 `:22` 在 `OBJECTIVES → ` 后插入 `测试用例 → `；②feature 产物清单 `:36`"含 `prd.md` `plan.md`…"加 `tests.md`；③技能索引（38-49 区）补 `writing-tests`。
- [ ] 步骤7: 验证（TC3）  运行: `grep -rn "TESTCASES" skills/using-sandtable/SKILL.md skills/state-and-memory/SKILL.md templates/state.md README.md AGENTS.md`  预期: 全部命中；`.cursor/rules` 用中文"测试用例"命中（单独 grep）。

### 任务 T5: skills 衔接（PRD→tests→plan）+ §5 重定位（FR7）
**文件:** 修改 `skills/writing-prd/SKILL.md`（:15、:28-32、:42、:70）、`skills/writing-plan/SKILL.md:12-16,68-76`、`templates/prd.md:18-20`
- [ ] 步骤1: writing-prd **内部三处路由全部一致**（TC6）：①HARD-GATE `:15` "PRD 完成后必须请开发者确认才能进入 PLAN" 改为 "…才能进入 TESTCASES"；②dot 图 `:28-32` 末节点 "进入 writing-plan" 改为 "进入 writing-tests"；③结尾 `:70` "phase 为 PLAN，加载 writing-plan" 改为 "phase 为 TESTCASES，加载 writing-tests"。
- [ ] 步骤2: writing-prd §5 指引（`:42`）重定位（Q5=B）：把"验收标准（成功定义）：可验证、可测试…"改为"§5 只写**抽象成功定义**；一切具体可演练场景（含可执行检查命令）下沉 `tests.md`（见 writing-tests）"；并补一句审阅指引"tests.md=理解闸门（先读）、§5=完成闸门（VERIFY 勾选）"。同步把 `templates/prd.md:18-20` 的 §5 注释改为该口径。
- [ ] 步骤3: writing-plan：①前置 HARD-GATE（`:12-16`）补"计划须同时覆盖 `tests.md` 每条用例；验证步骤**引用 TC 编号**、不另造预期"；②自查表（68-76）加一行"tests.md 覆盖：每条 TC 都有对应任务/被某步骤引用验证？"。
- [ ] 步骤4: 验证（TC6）  运行: `grep -n "writing-tests\|TESTCASES" skills/writing-prd/SKILL.md && grep -n "tests.md\|TC 编号" skills/writing-plan/SKILL.md && grep -nc "writing-plan" skills/writing-prd/SKILL.md`  预期: 前两者命中；writing-prd 内不再残留指向 writing-plan 的路由（人工确认 :15/:28-32/:70 三处均已改）。

### 任务 T6: 三类推演 prompt 注入逐条用例突破点
**文件:** 修改 mental/impl/opfor 三个 prompt
- [ ] 步骤1: `skills/mental-rehearsal/mental-rehearsal-prompt.md` 在"相关 PRD 要点"块后新增：
```
    ## 待验证用例清单（来自 tests.md，逐条推演的突破点）
    [粘贴 tests.md 中本链路相关的 TC 全文]
```
并在"工作方式"加一条：逐条推演每个 TC 的 Given→When→Then 是否能闭环成立；任一 TC 推不通即 ANOMALY。
- [ ] 步骤2: `skills/implementation-rehearsal/implementation-rehearsal-prompt.md` 在"PRD 要点 + 验收标准"块后新增同名"待验证用例清单"块；工作方式加一条：实现完成后逐条让每个 TC 的 Then 真实成立（贴证据）。
- [ ] 步骤3: `skills/red-team-wargame/opfor-prompt.md` 在"它声称要满足的"块后新增"待验证用例清单（来自 tests.md）"块；交战规则加一条：尝试对每条 TC 构造使 Then 不成立的反例。
- [ ] 步骤4: 验证（TC5）  运行: `grep -l "待验证用例清单" skills/mental-rehearsal/mental-rehearsal-prompt.md skills/implementation-rehearsal/implementation-rehearsal-prompt.md skills/red-team-wargame/opfor-prompt.md`  预期: 三处全命中；并人工确认新增块落在 prompt 字符串内（4 空格 + `##`），未破坏外层 ``` 代码块。

### 任务 T7: 命令编排衔接（6 个命令 × 双副本同步）
**文件:** 每个命令均改 `commands/<x>.md` 与 `.cursor/commands/<x>.md` 两副本（当前已逐字同源，须保持）。
- [ ] 步骤1: `sandtable-start`：编排步骤在"OBJECTIVES（第4步）"与"PLAN（原第5步）"之间插入新一步"**TESTCASES**：加载 `writing-tests` 产出 `tests.md`（标定靶标，检验理解），可用 /sandtable-refine 迭代"，后续步号顺延；并把末尾"可用 …`/sandtable-plan`…"链路相应更新。
- [ ] 步骤2: `sandtable-objectives`：**第 5 步把 `phase=PLAN`、提示 `/sandtable-plan` 改为 `phase=TESTCASES`、提示 `writing-tests`/产出 tests.md**（消除与 writing-prd 的路由矛盾，TC6）。
- [ ] 步骤3: `sandtable-plan`：第 1 步"读已确认的 prd.md"改为"读已确认的 `prd.md` 与 `tests.md`；验证步骤引用 TC 编号"。
- [ ] 步骤4: `sandtable-resume`：第 5 步"读 prd.md、plan.md…"加入 `tests.md`。
- [ ] 步骤5: `sandtable-refine`：第 2 步的分支加入"改**用例** → 加载 `writing-tests` 更新 `tests.md`"；第 1 步读取清单加 `tests.md`。
- [ ] 步骤6: `sandtable-rehearse`：第 1 步读取清单加 `tests.md`；异常修正回流"修正 prd.md/plan.md"补 `tests.md`。
- [ ] 步骤7: 验证双副本一致（TC9）  运行: `for x in start objectives plan resume refine rehearse; do diff commands/sandtable-$x.md .cursor/commands/sandtable-$x.md && echo "ok $x"; done`  预期: 六个均 `ok`、无差异。

### 任务 T8: 全局文档计数与目录结构
**文件:** 修改 `docs/sandtable/project.md:9`、README 目录结构/skills 列表（已在 T4 步骤4 涉及 README，本步专注非闭环部分）
- [ ] 步骤1: project.md 把"skills/（10 个 skill）"改为 11、"templates/（7 个模板）"改为 8、feature 文件清单 `{prd,plan,state,journal,questions}` 改为含 tests。
- [ ] 步骤2: README"## 目录结构"的 skills 清单加 `writing-tests/` 行、templates 注释（`:104` 的 `project/constraints/prd/plan/state/journal/questions 模板`）加 tests、运行时 `features/<日期-slug>/` 文件清单（`:114` 附近）加 `tests.md`；"三类推演三位一体"问句区不变（用例是输入不是新问句）。
- [ ] 步骤3: 验证  运行: `grep -n "writing-tests" README.md docs/sandtable/project.md`  预期: 均命中

### 任务 T9: 整体验证（逐条对齐 tests.md TC1-TC9，验证步骤=实现预演证据，引用 TC 编号）
- [ ] 步骤1: TC1/TC2（init 幂等）见 T3 步骤4。
- [ ] 步骤2: TC3（TESTCASES 处处一致、位置正确）见 T4 步骤7。
- [ ] 步骤3: TC4（映射门禁 + 三产物边界 + frontmatter）  运行: `grep -n "MUST NOT\|理解闸门\|name: writing-tests" skills/writing-tests/SKILL.md`  预期: 门禁含扩展映射源、含审阅指引、frontmatter 合法。
- [ ] 步骤4: TC5 见 T6 步骤4；TC6 见 T5 步骤4 + T7 步骤2/7；TC7 见 T1 步骤2。
- [ ] 步骤5: TC8 回归  运行: `python3 -m json.tool .claude-plugin/plugin.json >/dev/null && python3 -m json.tool .cursor-plugin/plugin.json >/dev/null && bash -n scripts/sandtable-init.sh && echo OK`  预期: 打印 OK；并人工 diff 确认无关 skill 的 Red Flags/合理化表/硬门禁未动。
- [ ] 步骤6: TC9 命名自洽 + 双副本  运行: `grep -rn "test-cases\|testcase\|writing-test[^s]" skills templates commands .cursor README.md AGENTS.md scripts`（预期无拼写变体）+ T7 步骤7 的六命令 diff。

### 任务 T10: 异常写回清单 + frontmatter 描述统一 + sandtable-mental（mental-2/重演遗漏补全）
**文件:** 把"异常修正后写回 prd/plan"清单与流程 frontmatter 一并补 tests.md，保持"一处改处处改"。
- [ ] 步骤1: 异常写回清单加 `tests.md`：`skills/using-sandtable/SKILL.md:88`（"写回 prd.md/plan.md"→"prd.md/tests.md/plan.md"）、`skills/being-truthful/SKILL.md:44`（同）。
- [ ] 步骤2: `commands/sandtable-mental.md` + `.cursor/` 副本：第 1 步读取清单（:8）加 `tests.md`；第 3 步修正清单（:10）"修正 prd.md/plan.md"加 `tests.md`。
- [ ] 步骤3: `commands/sandtable-rehearse.md` + `.cursor/` 副本第 10 行修正清单 "prd.md/plan.md" 加 `tests.md`（与 T7 步骤6 同文件，合并执行）；`commands/sandtable-redteam.md:11` + 副本"修正 PRD/计划"改为"修正 PRD/用例/计划"。〔live/debrief 用泛指"计划"（实现预演阶段），保持不动〕
- [ ] 步骤4: frontmatter 描述：`commands/sandtable-start.md:2` + `.cursor/` 的"澄清→PRD→计划→预演"改为"澄清→PRD→用例→计划→预演"；`skills/writing-prd/SKILL.md:3` 的"before writing an implementation plan"改为"before writing test cases and the plan"；`skills/writing-plan/SKILL.md:3` 的"have an approved PRD"改为"have an approved PRD and test cases"。
- [ ] 步骤5: 验证  运行: `grep -rn "prd.md`/`plan.md\|prd.md`/`tests.md" skills/using-sandtable/SKILL.md skills/being-truthful/SKILL.md commands/sandtable-mental.md commands/sandtable-rehearse.md`  预期: 写回/修正清单均含 tests.md；`grep -n "用例" commands/sandtable-start.md` 命中。
