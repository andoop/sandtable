# 实现预演报告 · impl-1（分支 sandtable/post-landing-loop · 单一实现）

> 开发者选"单一实现"，本报告即真实落地的自评（主 agent 抽查 diff + 红线核对）。
> 结论：**DONE**（T1–T8 全部实现，TC1–TC28 结构性校验通过）。

## 落地清单（我新增/修改的文件）
- 新 skill（中文源 + 3 镜像 = 4 根）：`triaging-feedback/SKILL.md`、`bugfix-with-evidence/SKILL.md`(+`investigator-prompt.md`)。
- 新命令（6 根）：`sandtable-bug.md`、`sandtable-bugfix.md`。
- 新模板：`templates/feedback.md`、`templates/lessons.md`。
- init 脚本（中英）：全局循环加 `lessons.md`（幂等），`bash -n` 通过。
- FEEDBACK 阶段写入：`state-and-memory`、`using-sandtable`、`closing-the-loop`(zh 映射表)、`.cursor/rules`、`AGENTS.md`、`templates/state.md`、`README.md`（中英对应处）。
- M2 修复：state-and-memory 恢复分支加 1.5（DONE/FEEDBACK 按 phase 恢复）。
- 教训反哺交叉引用（中英）：`gathering-intel`、`red-team-wargame`、`writing-prd`。

## 自评（evaluating-rehearsals 评分维度）
- 需求符合度：FR-PHASE/FEEDBACK-SKILL/BUGFIX-SKILL/COLLECT/SQUAD/GATE/ARTIFACT/LIFECYCLE/LESSONS/FEEDFORWARD/CMD/INDEX/MIRROR 全部落地。✅
- 红线符合度（一票否决项）：交付物仅 markdown + init 脚本各加一词；未捆绑 server/采集脚本；日志落仓库外、不入库、不改用户 .gitignore；未擅改 constraints 红线；无关 skill 仅追加交叉引用（gathering-intel/red-team/writing-prd 的 Red Flags/硬门禁未动）。✅
- 正确性证据：TC1–TC28 结构性校验脚本全绿（skill 4 根、命令 6 根、模板、FEEDBACK×各源、lessons 交叉引用、init lessons.md、bash -n）。✅
- 极简/外科性：每文件改动可追溯到 FR；无越界。✅

## 抽查/残余
- `plugins/sandtable/skills/SKILL.md`、`locales/en/skills/SKILL.md` 等"裸 SKILL.md"为既有打包产物（非本需求引入），未触碰。
- 工作树原有未提交改动（closing-the-loop 等，全部 13 命令的 M）随分支带入，非本实现产物；INTEGRATE 时需开发者区分。
- R1/R2（redteam-2 残余）：仓库外日志非持久（feedback.md 摘录兜底）；自动建 feature 复用 init 幂等——均已在 skill 文字体现。
