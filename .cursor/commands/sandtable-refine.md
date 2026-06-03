---
description: 调整部署 · 我读完目标/计划后，让 AI 据我的反馈修改、补充或重制，反复迭代直到我满意。
---

根据我接下来的反馈完善当前需求的想法/目标/计划；读取并遵循 `skills/using-sandtable/SKILL.md`。

执行：
1. 先读本需求的 `prd.md`、`tests.md`、`plan.md`、`state.md`、`journal.md`，搞清现状。
2. 针对我的反馈判断要改哪一层：
   - 改**想法/范围/目标** → 加载 `writing-prd` 更新 `prd.md`（必要时回 `gathering-intel` 补情报）。
   - 改**用例** → 加载 `writing-tests` 更新 `tests.md`。
   - 改**计划/任务/实现路径** → 加载 `writing-plan` 更新 `plan.md`。
3. 我的反馈里若含不确定/需决策的点：不猜，按 `being-truthful` 读代码/文档或写入 `questions.md` 问我。
4. 改动要**外科手术式**：只改我指出的与其直接牵连的部分，不顺手重写无关内容。
5. 在 `journal.md` 追加一条"调整记录"（改了什么、为什么、依据），更新 `state.md`（如已预演过，相应把预演计数视为失效，需重演）。
6. 把修改点摘要给我，等我确认或继续提反馈。

可反复触发本命令，直到我说"就这样"。重大改动后记得重新预演。
