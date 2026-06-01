# 实现预演 #1（分支 sandtable/rehearse/easy-install-1）

- 工作区：隔离 worktree `../sandtable-rehearsal-1`。
- 返回：DONE，提交 SHA `02d5e47`。
- 改动：仅 3 文件——新建 `.claude-plugin/marketplace.json`、新建 `INSTALL.md`、改 `README.md` 安装节（+134 / -10）。

## 主 agent 亲自核实（不轻信 DONE）
- `git show --stat HEAD`：确认仅 3 文件，README 仅替换「## 安装 / 接入」节、相邻节未动。
- `python3 -m json.tool .claude-plugin/marketplace.json` → 合法；plugin 名 = `sandtable`（与 plugin.json 一致）。
- INSTALL.md 引用的 10 个路径在本仓全部 `ok`；含 bash 守卫逐字与计划一致（symlink 守卫、mktemp 清理、跳过清单硬规则、步骤5 分组校验）。
- 未创建 `.cursor-plugin/marketplace.json`；现有两个 plugin.json + `bash -n sandtable-init.sh` 均通过；README 无"四个命令"。
- 越界检查：无。单一事实来源遵守（只指路、不复制正文）。

## 评分/择优
内容确定唯一、无竞争变体，本实现即选定方案（红线零违反、需求全覆盖、极简、外科手术式）。selected_impl = impl-1-easy-install.md。

## 集成
fast-forward 合并到 master（`a29f427..02d5e47`），master 上复跑验收全绿。worktree 与分支已清理。
