# 全局红线 · Constraints

> 全局唯一。任何需求、推演、实现都不得违反。推演中发现违反即为 ANOMALY。

## 绝对必须（MUST）
- [ ] 配套脚本必须零运行时依赖：只用 POSIX sh / bash + 常见 coreutils，不引入 node/python 等。
- [ ] 脚本必须可在 macOS 与 Linux 的 bash 下运行（与现有 `hooks/run-hook.cmd` 一致）。
- [ ] 任何"内容/产物"必须来自 `templates/`，保持单一事实来源；不要在脚本里硬编码模板正文的副本。

## 绝对禁止（MUST NOT）
- [ ] 禁止覆盖/破坏用户已存在的 `docs/sandtable/` 文件（脚手架必须幂等、不毁数据）。
- [ ] 禁止写未被要求的兜底逻辑 / 节外生枝（外科手术式改动）。
- [ ] 禁止引入新的第三方依赖。
- [ ] 禁止改动方法论 skill 的"已调校文本"（Red Flags 表、合理化表、硬门禁）除非本需求明确要求。

## 技术约束
- 语言：bash（`set -euo pipefail` 风格，与 `hooks/session-start` 一致）。
- 风格：与现有 `hooks/` 脚本一致（`SCRIPT_DIR` 解析、注释说明意图）。
- 模板占位符：`<YYYY-MM-DD>`、`<slug>`、`<ISO8601>` 需在初始化时替换为实际值。
