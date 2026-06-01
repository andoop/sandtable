---
feature: 2026-06-02-init-script
phase: DONE              # INTAKE|RECON|OBJECTIVES|PLAN|MENTAL_REHEARSAL|REDTEAM|IMPL_REHEARSAL|EVALUATE|INTEGRATE|VERIFY|DONE
blocked: false
updated: 2026-06-02T00:43:00+08:00
tasks:
  - id: T1
    title: 实现 sandtable-init.sh
    status: done
  - id: T2
    title: 黑盒验证脚本 test-sandtable-init.sh
    status: done
  - id: T3
    title: README 增补用法
    status: done
rehearsals:
  mental:  { runs: 1, last: anomaly }  # 缺参/set-u 冲突 → 已修计划
  redteam: { runs: 1, last: breach }   # sed&、|分隔符、/与..、%z时区、:YAML 等 → 已收口为 slug 白名单
  impl:    { runs: 2, last: done }      # A、B 均 DONE，主 agent 重跑+中立探针均通过
selected_impl: B
---

## 当前进展
完成。胜出实现 B 已落地 `scripts/sandtable-init.sh` + `scripts/test-sandtable-init.sh`，README 增补用法。真实仓库验证：`bash -n` ok、`ALL TESTS PASSED`、中立探针对全部红军破绽输入均 exit 2/0 残留。闭环达成。

## 关键决策（最近）
- 择优：B 胜出（报告准确 + 更健壮 + 无子进程 + 兼容 bash 3.2）。
- 自举演示：用 Sandtable 流程改进 Sandtable 自身。
- 环境据实调整：本仓非 git 仓库，实兵推演用隔离临时目录替代 git worktree（见 journal）。
- slug 限定 kebab-case（Q1 采用推荐默认 A，待开发者最终确认）。
