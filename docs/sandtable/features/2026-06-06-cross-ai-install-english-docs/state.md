---
feature: 2026-06-06-cross-ai-install-english-docs
phase: DONE
blocked: false
updated: 2026-06-06T02:12:00+08:00
tasks:
  - id: T1
    title: Define bilingual install prompts and prompt-language selection contract
    status: completed
  - id: T2
    title: Create the English local asset pack for installable docs and skills
    status: completed
  - id: T3
    title: Specify localized-vs-shared install asset mapping
    status: completed
  - id: T4
    title: Consistency and verification sweep
    status: completed
rehearsals:
  mental:  { runs: 9, last: closed }
  redteam: { runs: 2, last: held }
  impl:    { runs: 1, last: done }
autonomy:
  mode: manual
  min_rounds: { mental: 3, redteam: 3, impl: 2 }
  min_agents_per_round: { mental: 3, redteam: 3, impl: 2 }
  completed_rounds: { mental: 0, redteam: 0, impl: 0 }
  last_decision: none
selected_impl: rehearsals/impl-1-sandtable-rehearse-cross-ai-install-english-docs.md
---

## 当前进展
已完成本轮增量需求的 RECON、范围确认、PRD、tests、plan、头脑预演、红蓝对抗、实现预演、主工作区集成与验证。本 feature 当前已进入 `DONE`：已选中的实现预演方案已回落主工作区，主 agent 复核了 diff、资产布局、脚本语法与 lint，未见新的异常。

## 关键决策（最近）
- 这是一项新 feature，不复用已 `DONE` 的 `2026-06-02-easy-install` 作为当前状态机。
- 新目标已从“英文主文”回退并重定向为“按用户复制给 AI 的提示词语言安装本地资产”。
- 首期只支持中文与英文；语言由 AI 读取用户实际贴过去的话自行判断，不用额外 flag。
- 本地语言切换范围包含 `skills/`，且必须继续遵守“不覆盖已有文件”的安装红线。
- 头脑预演已收口：本地双语资产范围现覆盖 `AGENTS`、rules、commands、skills、templates、`scripts/sandtable-init.sh`、`hooks/run-hook.cmd`、`hooks/session-start`，且 `scripts/test-sandtable-init.sh` 已被明确排除在安装面外。
- 红蓝对抗已收口：语言自动判断仅在“整条官方提示词正文精确命中”时成立；语言相关资产必须先做 locale-pack 预检；`templates/` 保持单一模板根，英文模板位于 `templates/en/`。
- 实现预演 #1 已完成并被选定；开发者确认后，方案已集成回主工作区。
- 主工作区验证通过：`README.md`、`INSTALL.md`、根 `hooks/` 中文源、`locales/en/**`、`templates/en/*.md` 已落地，相关 bash 语法检查与 lint 通过。
