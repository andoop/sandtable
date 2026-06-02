# 头脑预演 #1 · 状态机/流程闭环一致性 → ANOMALY_FOUND

**链路:** phase TESTCASES 插入与流程闭环（计划 T4/T5/T7/T8）
**结论:** ANOMALY_FOUND（主 agent 已亲自核实，属实）

## 核实属实的异常
1. **路由矛盾（致命）**：`commands/sandtable-objectives.md:16` 与 `.cursor/commands/…:16` 写死"确认后 phase=PLAN，提示 /sandtable-plan"，会覆盖 T5 给 writing-prd 设的"phase=TESTCASES→writing-tests"。〔已核实 `sandtable-objectives.md:16`〕
2. **writing-prd 内部多处旧路由**：除 `:70` 外，HARD-GATE(`:15`)、dot 图(`:28-32`)仍指向 PLAN/writing-plan，T5 仅改 `:70` 不自洽。
3. **计划遗漏的命令副本**：`sandtable-plan.md:8`（只读 prd）、`sandtable-resume.md:12`（读 prd/plan 无 tests）、`sandtable-refine.md:9-11`（只分支 writing-prd/plan）、`sandtable-rehearse.md:8,10,16`（读/修 prd/plan）均含流程引用但未列入 T7。〔已核实五个命令文件〕
4. **遗漏的索引/产物清单副本**：`AGENTS.md:43` 技能索引无 writing-tests；`.cursor/rules/sandtable.mdc:36` feature 产物清单 `prd plan state journal questions` 无 tests、技能索引无 writing-tests；`using-sandtable:61,70,88`（refine 行、"编排前四步"、异常修正 FIX→OBJ）；`README:58`（/start 描述"侦察→目标→计划"）；`state-and-memory:64`（回退锚点仅 OBJECTIVES/PLAN）。
5. **T4 锚点不存在**：计划写"恢复流程(86-93)的'读 prd.md'处补读 tests.md"，但 state-and-memory 的恢复 dot(`:77-94`)无"读 prd.md"节点；真实读 prd 在 `sandtable-resume.md:12`。
6. **TC3 锚点冲突**：tests.md TC3 要求"TESTCASES 紧跟 OBJECTIVES 之后"，但 README/AGENTS 用 PRD 而非 OBJECTIVES（缩写式），字面不满足。

## 已确认正确的部分
- 命令双副本（start/objectives）当前同源同内容，T7 的 diff 验证假设成立。
- 枚举式/中文全称式插入点明确。

## 需要的修正方向
扩大 FR6/T4/T7 范围覆盖上述全部副本；统一 writing-prd 内部路由；改 sandtable-objectives 第5步为 TESTCASES；明确 tests.md 产出方（start 第5步 vs objectives）；放宽 TC3 锚点措辞。
