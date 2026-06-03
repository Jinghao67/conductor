# 一键交给 Codex / Claude Code 安装

这个项目提供两份 one-shot prompt。整段发给 Codex 或 Claude Code，它们就可以从 GitHub 安装这个 skill。

- 给 Codex：[`prompts/install-with-codex.md`](../prompts/install-with-codex.md)
- 给 Claude Code：[`prompts/install-with-claude-code.md`](../prompts/install-with-claude-code.md)

## 设计原则

prompt 负责告诉 AI 要做什么，`scripts/install.sh` 负责稳定执行安装。

这样可以避免 AI 每次重新发明复制流程，也能自动备份已有版本。

## 安装脚本做什么

`scripts/install.sh` 会：

1. 找到 repo 里的 `skills/conductor`
2. 创建 `${CODEX_HOME:-~/.codex}/skills`
3. 如果已有 `conductor`，移动到带时间戳的备份目录
4. 复制新版 skill
5. 检查必需文件
6. 如果本机有 Codex skill validator，就运行校验

## 当前仓库地址

https://github.com/Jinghao67/conductor
