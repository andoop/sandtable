# sandtable-init 脚手架脚本 PRD

> 对应 project.md 北极星 / 继承 constraints.md 红线。实现细节见 plan.md。

## 1. 目标
提供 `scripts/sandtable-init.sh`：在任意目标项目里，从本插件 `templates/` 一键脚手架出 Sandtable 运行时目录（全局文件 + 一个 feature 目录），消除手工拷贝易错的问题。

## 2. 背景与现状
- 模板在 `templates/`（7 个），占位符仅 `state.md` 有 `<YYYY-MM-DD>-<slug>` 与 `<ISO8601>`。〔已确认: journal RECON 简报〕
- 运行时目录结构由 `skills/state-and-memory/SKILL.md` 定义。〔已确认: 该 skill〕

## 3. 用户故事 / 场景
- 作为使用本插件的开发者，我在项目根运行 `scripts/sandtable-init.sh "用户登录"`，立即得到 `docs/sandtable/project.md`、`constraints.md` 和 `docs/sandtable/features/2026-06-02-用户登录/` 下的 5 个文件，且 `state.md` 已填好 feature 名与时间，可直接开始 RECON。

## 4. 功能需求
- FR1: 脚本接受一个 feature 描述参数（slug）；可选第二参数指定日期，缺省取今天 `date +%F`。
  - **slug 仅允许 `[A-Za-z0-9-]`（kebab-case）**；为空、缺参或含非法字符（空格/`/`/`:`/`&`/`|`/`.`/中文等）→ 打印用法并 `exit 2`。〔决策 Q1-A，见 questions.md；修复红蓝对抗 #1#2#3#5#6〕
- FR2: 在**目标项目当前工作目录**（运行 `pwd`）下创建 `docs/sandtable/`；全局 `project.md`、`constraints.md` 从模板复制，**已存在则跳过并提示**。〔继承 MUST-NOT 不覆盖〕
- FR3: 创建 `docs/sandtable/features/<date>-<slug>/`，复制 prd/plan/state/journal/questions 五个模板；并建空 `rehearsals/` 子目录。
- FR4: 对复制后的 `state.md` 做占位替换：`feature` → `<date>-<slug>`，`updated` → 当前 ISO8601 时间戳，**时区带冒号（如 `+08:00`）以与方法论示例一致**。〔修复 #4：macOS `%z` 默认输出 `+0800`〕
- FR5: feature 目录或同名文件**已存在（`-e`）则报错退出**（避免覆盖已有需求的过程文件），退出码非 0。〔修复 #8〕
- FR6: 结束时打印创建了哪些文件与"下一步建议"（运行 `/sandtable-recon`）。
- FR7: 模板目录定位相对脚本自身（`SCRIPT_DIR/../templates`，用 `BASH_SOURCE[0]`），不依赖调用时的 cwd。
- FR8: 若 `TEMPLATES` 目录不存在则清晰报错并 `exit 1`（提示"请从插件仓库内运行"）。〔缓解 #7 符号链接误用，属明确前置校验非兜底〕

## 5. 验收标准（可验证）
- [ ] 在空临时目录运行 `sandtable-init.sh demo` → 生成 `docs/sandtable/{project.md,constraints.md}` 与 `docs/sandtable/features/<today>-demo/{prd,plan,state,journal,questions}.md` + `rehearsals/`。
- [ ] 生成的 `state.md` 中 `feature:` 等于 `<today>-demo`，`updated:` 是带冒号时区的合法 ISO8601（匹配 `+\d\d:\d\d` 结尾），且**不含** `<YYYY-MM-DD>`/`<ISO8601>` 字样。
- [ ] 再次对同一项目用**不同** slug 运行 → 复用已存在的 `project.md`/`constraints.md`（不覆盖、有跳过提示），新建第二个 feature 目录。
- [ ] 对**相同** `<date>-<slug>` 再次运行 → 报错退出（退出码非 0），不改动已存在的 feature 文件。
- [ ] 非法 slug（`a/b`、`a&b`、`a|b`、`a:b`、`..`、含空格）与空 slug、无参 → 一律 `exit 2`，**不创建任何 feature 目录**。
- [ ] `bash -n scripts/sandtable-init.sh` 通过；`shellcheck`（若可用）无 error 级问题。
- [ ] 全程不修改 `templates/` 与任何 skill 文件。

## 6. MUST（绝对要做）
- 幂等且不毁数据：全局文件已存在跳过，feature 目录已存在报错。
- 仅 bash + coreutils，零第三方依赖。
- 内容全部来自 `templates/`（单一事实来源）。
- slug 校验为 kebab-case 白名单；非法输入在创建任何文件**之前**就报错退出。

## 7. MUST NOT（绝对不能做）
- 不覆盖用户已存在的 `docs/sandtable/` 文件。
- 不在脚本里硬编码模板正文副本。
- 不做未要求的兜底/选项（如交互式向导、--force 删除等），不节外生枝。
- 不替换 state.md 以外模板里的"内容骨架"占位符。

## 8. 非目标 / 暂不做（YAGNI）
- 不做卸载/重置命令。
- 不做多 feature 批量初始化。
- 不做 Windows .cmd 版本（现有 hooks 已统一用 bash 启动）。

## 9. 未决问题
无阻塞项。
