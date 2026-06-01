# 安装/上手像 superpowers 一样方便 PRD

> 对应 project.md 北极星 / 继承 constraints.md 红线。实现细节见 plan.md。

## 1. 目标
让用户用 superpowers 同款"插件市场一行安装"接入 Sandtable，取代当前"手工拷贝目录"的接入方式，做到装好即生效、可一键更新。

## 2. 背景与现状
- 当前接入靠手工：`README.md:27-44` 让用户把 `.cursor/`、`skills/`、`templates/` 或整个 `sandtable/` 目录拷进项目根——易错、无更新机制。
- 已有 `.claude-plugin/plugin.json`（完整：skills/commands/hooks 指向）、`.cursor-plugin/plugin.json`；`skills/ commands/ hooks/` 均在仓库根。
- **缺 `.claude-plugin/marketplace.json`**，故无法被 `/plugin marketplace add` 识别 —— 这是与 superpowers 体验的唯一关键差距（Claude Code 侧）。
- git remote = `git@github.com:andoop/sandtable.git`。

## 3. 用户故事 / 场景
- 作为 Claude Code 用户，我希望两行命令装好 Sandtable（`/plugin marketplace add andoop/sandtable` + `/plugin install sandtable@sandtable`），并能 `/plugin update` 升级，无需手工拷贝任何文件。
- 作为只读 README 的新用户，我希望安装小节第一眼就是这一行式安装，而不是"把目录拷进项目根"。

## 4. 功能需求
- FR1: 新增 `.claude-plugin/marketplace.json`，列出插件 `sandtable`，`source` 用 github 源指向本仓自身（`{source:"github", repo:"andoop/sandtable"}`），使 `/plugin marketplace add andoop/sandtable` 可识别、`/plugin install sandtable@sandtable` 可安装。〔已确认机制：官方文档〕
- FR2:（已取消）不交付 `.cursor-plugin/marketplace.json`。理由：仓库根布局下 `source:"."` 官方零示例 + 社区报告 Cursor 2.6+ 静默拒绝根级 source，而唯一更稳写法需把目录搬进 `plugins/sandtable/`（违反"不重构目录"红线）。Cursor 改由 FR4 的本地 symlink + 官方市场提交 + FR3 的 AI 自助安装支持。〔开发者 2026-06-02 决策：drop〕
- FR3: 新增**面向 AI 的自助安装说明**（`INSTALL.md`，仓库根）：用户把它丢给任意 coding agent，agent 读后能把 Sandtable 装进当前项目（识别 harness → 放置正确文件 → 验证），全程不覆盖用户已有文件。〔开发者明确要求〕
- FR4: 重写 `README.md` 安装小节，并列四条路径：①Claude Code 市场一行装 ②Cursor（本地 symlink 可靠 + 官方市场提交说明）③让 AI 读 `INSTALL.md` 自助安装 ④手工拷贝（最后兜底）。修正现存"四个命令"过时描述。〔已确认〕

## 5. 验收标准（成功定义，可验证）
- [ ] `.claude-plugin/marketplace.json` 为合法 JSON（`python3 -m json.tool` 解析通过），字段符合官方 schema；若本机有 `claude` CLI 则 `claude plugin validate .` 通过，否则在 journal 如实记录验证方式。
- [ ] `.claude-plugin/marketplace.json`：marketplace 名与 plugin 名均为 `sandtable`，plugin `source` 指向 `andoop/sandtable`，且 plugin 名与 `.claude-plugin/plugin.json` 的 `name` 一致。
- [ ] `INSTALL.md` 存在且自洽：指令引用的所有路径（skills/、commands/、templates/、scripts/、AGENTS.md、.cursor/rules/sandtable.mdc、.cursor/commands/、hooks/、scripts/sandtable-init.sh、skills/using-sandtable/SKILL.md）在本仓真实存在；不含内容占位符；所有写入均带"存在即跳过"守卫、不破坏用户已有文件；步骤6清理仅针对临时 clone。
- [ ] README 安装小节四条路径齐备，命令字面与 marketplace 名/plugin 名/文件名自洽；无"四个命令"等过时描述。
- [ ] 不破坏现有任何文件的有效性（两个 plugin.json、hooks、commands、skills 原样可用）。

## 6. MUST（绝对要做）
- 单一事实来源：插件内容仍来自现有 `skills/ commands/ hooks/ templates/`，marketplace.json 只做"指路"，不复制内容正文。
- 安装命令与文件中的名字（marketplace 名、plugin 名）严格自洽，README 与 json 一致。

## 7. MUST NOT（绝对不能做）
- 不做未被要求的兜底逻辑 / 不节外生枝（继承 constraints.md）。
- 不为了加市场而把 `skills/ commands/ hooks/` 搬进子目录（会破坏现有 Cursor `.cursor/` 接入与手工拷贝路径，越界）。
- 不夸大 Cursor 能力：不把 Cursor 写成"免审核一行装"。
- 不引入第三方依赖、不改方法论 skill 的已调校文本。

## 8. 非目标 / 暂不做（YAGNI）
- 不新建独立的 marketplace 仓库（superpowers 用独立仓；本需求单仓即可满足，避免多仓维护）。
- 不实现 curl|bash 自动安装脚本——以 `INSTALL.md`（让 AI 自助安装）替代该角色。
- 不替 Cursor 走官方市场提交流程（属仓库外的人工流程，仅在 README 注明入口）。
- 不重构现有目录结构（不把 skills/commands/hooks 搬进子目录）。

## 9. 未决问题
见 questions.md：Q1（仓库是否公开）、Q2（harness 范围）、Q3（市场名/命令默认）。
