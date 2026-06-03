# Clean Branch

[English](README.md) | [中文](README.zh-CN.md)

Clean Branch 是一个用于上下文卫生和交互式分支编排的 skill。

它让主 session 保持干净，把探索、实现、调研、审阅、解释这类容易污染上下文的工作放进独立的、用户可进入的交互式分支 session。分支只有在用户确认完成后，才生成 completion report；只有在用户明确批准后，才把压缩记录合并回主 session。

## 为什么需要它

长周期 AI 工作流很容易挤进一个过载的上下文里：

- 需求讨论
- 探索分支
- 实现细节
- 失败尝试
- 长篇解释
- review 记录
- 最终过程文档

Clean Branch 把这些内容拆成可见的分支结构：

- **master session**：项目总览、决策、分支 registry、已批准摘要
- **interactive branches**：用户可以进入的 Codex / Claude Code 分支会话，用来处理复杂细节
- **explainer sidecar**：高污染学习线程，默认几乎不合并
- **completion reports**：只有用户确认分支完成后才生成的短报告

它的目标不是制造后台 worker，而是让多 session 工作可审计、可恢复、可理解。

## 仓库结构

```text
.
├── README.md
├── README.zh-CN.md
├── docs/
│   ├── AI_INSTALL.zh.md
│   ├── DESIGN.zh.md
│   └── REVIEW_CHECKLIST.zh.md
├── examples/
│   ├── branch-map.md
│   ├── clean-branch.yaml
│   └── trellis-task-meta.json
├── prompts/
│   ├── install-with-claude-code.md
│   └── install-with-codex.md
├── scripts/
│   └── install.sh
└── skills/
    └── clean-branch/
        ├── SKILL.md
        ├── agents/openai.yaml
        └── references/
            ├── branch-brief-template.md
            ├── branch-map-template.md
            └── completion-report-template.md
```

## 安装

把 skill 文件夹复制到 Codex skills 目录：

```bash
cp -R skills/clean-branch ~/.codex/skills/clean-branch
```

也可以在仓库根目录运行安装脚本：

```bash
bash scripts/install.sh
```

然后开启一个新的 Codex session，并这样触发：

```text
Use $clean-branch to split this complex task into interactive branches, keep the master session clean, and only merge approved completion reports.
```

## 交给 AI 一键安装

你也可以把安装交给 Codex 或 Claude Code：

- [Install with Codex](prompts/install-with-codex.md)
- [Install with Claude Code](prompts/install-with-claude-code.md)

把对应 prompt 整段复制给目标 AI coding agent 即可。prompt 已经指向当前 GitHub 仓库。

## 核心协议

Clean Branch 遵守几条硬规则：

1. master session 只保存全局上下文。
2. branch session 是用户可进入的交互线程，不是一次性后台 agent。
3. 分支只接收 branch brief、已批准摘要、显式文件引用，以及该分支线程里的用户消息。
4. completion report 只有在用户确认分支完成后才生成。
5. master session 只有在用户明确批准后才合并。
6. explainer branch 默认不合并。
7. 分支里的全局决策必须回到 master session 确认后才生效。

## Trellis 最佳实践

在 Trellis 中，Clean Branch 可以自然映射到父子任务：

- parent/root task：master session
- child task：interactive branch
- Codex thread：用户真正进入交互的分支会话
- `branch-map.md`：人类可读的分支视图
- `task.json.meta.clean_branch`：最小机器可读绑定信息

Clean Branch 应优先使用 Trellis task scripts 创建父子任务关系，不应把 `implement.jsonl` 或 `check.jsonl` 当成分支聊天历史的堆放区。

## 状态

初始公开草稿。License 目前刻意保留为 TBD。
