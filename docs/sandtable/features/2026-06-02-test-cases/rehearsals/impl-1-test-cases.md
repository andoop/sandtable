# 实现预演 #1 · test-cases → DONE（主 agent 已亲自核实）

**分支:** sandtable/rehearse/test-cases-1（隔离 worktree ../sandtable-rehearsal-1）
**结论:** DONE。子 agent 7 个提交覆盖 T1-T10；主 agent 亲自跑 TC1-TC9 全绿，抽查 diff 确认外科手术式、无越界。

## 实现（对照 T1-T10）
- 7 commits：b18c89f(T1/T2/T3) → 2154f14(T4) → 6551da6(T5) → 2735a6e(T6) → 5d4d751(T7) → 150d8af(T8) → 963d2e4(T10)。
- 新增 `templates/tests.md`、`skills/writing-tests/SKILL.md`；改 init 拷贝列表+注释；phase TESTCASES 入全部权威副本；PRD→TESTCASES→PLAN 路由；三 prompt 注入用例块；7 命令双副本同步；project.md/README；异常写回清单+frontmatter。

## TC1-TC9 主 agent 复核结果（全绿）
- TC1 ✓ init 生成 6 文件含 tests.md，清单列出，exit 0。
- TC2 ✓ 幂等守卫 `sandtable-init.sh:56-60` 未动（exit 1 不覆盖）+ TC1 已证生成；代码审查确认。
- TC3 ✓ `TESTCASES` 命中 using-sandtable(dot+表)、state-and-memory(枚举+回退)、templates/state.md、README、AGENTS；.cursor/rules 用"测试用例"，均位于 OBJECTIVES/PRD 与 PLAN 之间。
- TC4 ✓ writing-tests 有 frontmatter(name: writing-tests)、映射门禁含 FR/验收/MUST/MUST NOT、三产物边界、理解闸门指引；模板含映射+状态字段。
- TC5 ✓ 三 prompt 均含"待验证用例清单"。
- TC6 ✓ writing-prd 三处路由(:15/:28-32/:70)一致指向 TESTCASES/writing-tests，无残留旧路由；objectives 命令 phase=TESTCASES；sandtable-plan 读 prd+tests 引用 TC；writing-tests 结尾→PLAN/writing-plan。
- TC7 ✓ templates/tests.md 无代码/框架名（黑盒）。
- TC8 ✓ 两 plugin.json 合法、`bash -n` 通过；diff 范围仅计划点名文件；being-truthful 仅改写回行；mental/redteam/impl 三 SKILL 正文(Red Flags 表)未动，仅其 *-prompt.md 各 +4 行。
- TC9 ✓ 无拼写变体；7 命令双副本 diff 无差异。

## 自查
- 完整、无 TODO/占位；外科手术式、无越界、无未要求兜底；红线（零依赖/单一来源/不覆盖/不擅改无关已调校文本）全部满足。
