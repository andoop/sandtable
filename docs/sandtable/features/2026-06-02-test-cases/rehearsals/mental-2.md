# 头脑预演 #2 · 防重复职责边界 → ANOMALY_FOUND

**链路:** tests.md 与 PRD §5 / plan TDD 是否真不重叠；映射硬约束是否自洽可执行
**结论:** ANOMALY_FOUND（主 agent 核实：属实，且属方法论级设计问题）

## 核实属实的异常（需开发者决策）
- **A1 映射源措辞冲突**：门禁写"映射回 FR/验收标准"，但本需求自举 tests.md 的 TC2/TC4/TC7/TC8 映射字段写了 MUST/MUST NOT。门禁与示范自相矛盾。〔核实 `prd.md:40` vs `tests.md:16,28,46,52`〕
- **A2 元基础设施需求下 §5 已 operational**：本 repo 的 §5 验收本身就是 grep/bash/json.tool 等可执行条件，导致 TC1/TC3/TC5/TC6/TC8 与 §5 近 1:1 换皮。"§5 抽象 vs tests.md 场景"的立论对文档/方法论类需求不成立。这是本需求价值主张的真实张力。
- **A3 plan 验证步骤 ≈ tests.md**：T9"对齐 TC1-TC8"使 plan 的验证步骤与 tests.md 同命令同预期，构成第三重叠（本需求无典型 TDD 代码测试）。
- **A6 双清单审阅 UX**：§5 八条 + tests.md 八条高度同构，开发者审阅时重复劳动、不知以哪份为准；计划无应对。
- A4/A5 自举覆盖缺口：§5"命名自洽"无对应 TC；TC4 的 Then 未覆盖 §5"writing-tests 含 frontmatter"。

## 主 agent 判断与建议方案
- A1：把合法映射源扩为 **FR / 验收标准 / MUST / MUST NOT**（它们都是"需求"，都值得用例）。低成本、消除矛盾。建议采纳。
- A2：重定位 tests.md 的差异化价值=**"以行为场景检验 AI 理解"**而非单纯"具体 vs 抽象"；并明确：当 §5 已足够 operational 时，tests.md 应聚焦"歧义点/端到端行为/人需读懂的场景"，与 §5 重复处可引用而非复述。是否如此重定位、或只对"行为型需求"启用 tests.md，需开发者拍板。
- A6：在 writing-prd/README 加一句审阅指引——tests.md=理解闸门（先读，判断 AI 懂没懂）、§5=完成闸门（VERIFY 时勾选）。建议采纳。
- TC3：放宽为"位于 OBJECTIVES（或其产物 PRD）之后、PLAN 之前"。
