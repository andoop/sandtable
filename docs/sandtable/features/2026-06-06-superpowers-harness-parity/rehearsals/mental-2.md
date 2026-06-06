# 头脑预演 #2 · Superpowers 式多 harness 安装对齐

**信号：** `LOGIC_CLOSED`（交叉验证轮；经 1 处 verification-gap 修正后收口）

## 推演目的
在 mental-1 已收口的前提下，对修正后的 `plan.md` / `tests.md` 做交叉验证，重点攻击：
1. mental-1 的 Copilot marketplace 修正是否被 verification 层接住
2. OpenCode plugin 导出约定是否与 superpowers 一致
3. README/INSTALL 叙事切换是否仍有隐藏断点

## 第 1 轮发现 · ANOMALY_FOUND（已亲自核实并修正）

**偏差：** `plan.md` T5 步骤 2 的定点 `rg` 检查未包含对 `obra/superpowers-marketplace` / `superpowers@superpowers-marketplace` 的负向扫描，而 mental-1 已在 T1 步骤 4b 与 TC7 加了禁止误抄规则——verification 层与 guard 层不对齐。

**位置：** `plan.md` T5 步骤 2

**为什么是问题：** 若实现者在 README 误抄 superpowers 命令，T5 现有检查可能仍判“矩阵完整”而通过，TC7 无法在实现阶段被机械复核。

**处置：** T5 步骤 2 新增负向 `rg`，预期 README/INSTALL 不得出现 superpowers 专有 marketplace 标识。

## 第 2 轮 · 交叉验证结论

### OpenCode 导出约定
- `superpowers/.opencode/plugins/superpowers.js:55` 导出 `SuperpowersPlugin`；计划 T2 使用 `SandtablePlugin`，命名模式一致。
- `package.json` 的 `main` 指向 plugin 文件，与 `superpowers/package.json:1-6` 同构 → 链路闭环。

### Claude / Codex 双 tier 结构
- `superpowers/README.md` 的 Claude 有 Official + Developer marketplace 两节；Sandtable 仓内仅有 `.claude-plugin/marketplace.json`（`andoop/sandtable`），无官方上架承诺（Q3=A）。
- 计划 T1 步骤 2/4b 要求诚实措辞；实现时可写“Official Marketplace：发布后可用”+“Repo marketplace：andoop/sandtable”，但不强制复制 superpowers 双小节结构。
- **残余风险**，不构成 anomaly。

### README ↔ INSTALL 优先级切换
- 当前 `README.md:10-20`、`INSTALL.md:1-17` 仍以 AI-first 开头；T1/T4 会在实现阶段改写。计划已明确 INSTALL 降为次级 → 无逻辑断点。

### 四条主链路（复验 mental-1）
- README harness-first + 8 对象 + Kiro/通用 agent：T1 步骤 1/5 → OK
- OpenCode 三文件：T2 → OK
- Gemini 两文件：T3 → OK
- 现有 Claude/Cursor/Codex 资产保留：T1 步骤 3 + TC6 → OK

## TC 全量复验
| TC | 结论 |
|----|------|
| TC1 | T1 覆盖 |
| TC2 | T1 步骤 1/5 + T4 步骤 4 |
| TC3 | T1 步骤 5 + T4 |
| TC4 | T2 |
| TC5 | T3 |
| TC6 | T1 步骤 3 |
| TC7 | T1 步骤 4b + **T5 负向 rg（修正后）** |
| TC8 | T4 步骤 5 |
| TC9 | T1/T2/T3/T4/T5 联动 |

## 红线核对
全部与 mental-1 一致；无新增 MUST/MUST-NOT 冲突。

## 残余风险（不构成 anomaly）
- OpenCode/Gemini 默认中文 bootstrap
- Copilot/Droid/Cursor 平台侧上架未实测
- Claude Official Marketplace 小节是否镜像 superpowers 版式，由实现者按 T1 步骤 2 诚实措辞决定
