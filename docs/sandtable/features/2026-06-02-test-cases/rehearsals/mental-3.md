# 头脑预演 #3 · 脚手架与推演 prompt 机制 → LOGIC_CLOSED

**链路:** sandtable-init.sh 拷贝 tests.md（T3）+ 三类推演 prompt 注入（T6）
**结论:** LOGIC_CLOSED（主 agent 抽查引用，认可）

## 闭环要点
- init 幂等门禁 `:57-60` 在整个 feature 目录创建前检查，tests.md 与 prd/plan 同等受保护（TC2 成立）。
- tests.md 模板仅含写作型尖括号 `<需求名>`，无 init 级占位符（`<YYYY-MM-DD>/<slug>/<ISO8601>` 仅在 state.md）；sed 仅作用于 state.md，不误伤 tests.md。
- 拷贝顺序不影响行为；created 报告含 tests.md。
- 三 prompt 注入落在 prompt 字符串内部、4 空格 + `##` 同级，不破坏外层代码块；三类要求（推闭环/让 Then 成立/找反例）均可执行。
- 红线逐条核对通过：零依赖、macOS/Linux bash、单一来源、不覆盖、不改无关 skill 已调校文本。

## 残余风险（非异常，纳入修正）
- `sandtable-init.sh:77` 注释"5 个模板"未随 T3 更新（文档漂移）。
- T9 对"prompt 注入结构/无关文本未动"验证偏弱：建议加 `grep -n "待验证用例清单"` 三文件 + 限定 prompt 文件的 diff。
- 派发纪律：mental/impl 须按链路裁剪粘贴 TC，避免对 out-of-scope TC 误报。
