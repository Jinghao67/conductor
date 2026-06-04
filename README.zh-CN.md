# Conductor

[English](README.md) | [中文](README.zh-CN.md)

![干净主干](https://img.shields.io/badge/master-clean-2ea44f)
![脏解释分支](https://img.shields.io/badge/dirty_sidecar-welcome-f9c74f)
![可交互分支](https://img.shields.io/badge/branches-interactive-3b82f6)
![依赖顺序](https://img.shields.io/badge/order-dependency_aware-f97316)
![显式合并](https://img.shields.io/badge/merge-explicit_only-ef4444)
![Codex + Claude Code](https://img.shields.io/badge/works_with-Codex_%2B_Claude_Code-8b5cf6)

Conductor 是一个用于长周期 AI 工作的上下文卫生和交互式分支编排 skill。它的协议本身不绑定工具；这个仓库提供了 Codex-compatible skill 文件夹，也提供了给 Codex 或 Claude Code 的 one-shot 安装 prompt。

Conductor 把一个长项目当作一支乐队来指挥。你和 master session 站在指挥台前，手里只保留总谱：目标、约束、决策和全局结构。每个分支负责自己的声部；explainer sidecar 像排练室，容纳追问、试错和临时理解；真正值得留下的片段，才会被整理后写回总谱。

它保护的是**干净的 master session**，不是单纯的“干净分支”：主 session 只保留全局目标、约束、决策、分支图和已批准摘要；复杂执行和探索进入可交互分支；用户不懂、想细问、想让 AI 详细解释的内容进入一个刻意预留的**脏解释分支**。分支内容只有在用户确认完成，并批准合并后，才会以 completion report 的形式回到 master session。

## 为什么叫 Conductor

很多 AI 工作流不是输在模型能力，而是输在上下文混杂。所有东西都塞进一个会话后，主 session 很快变成：

- 需求访谈
- 探索分支
- 实现细节
- 失败尝试
- 长篇解释
- review 记录
- 最终过程文档

即使用过 Superpowers 或 grill-me 这类追问工作流，用户也不一定真的完全理解自己的项目。这个很正常。Conductor 专门给这种“不完全理解”预留了位置：一个可以放心提问、补课、反复解释的脏 sidecar，同时让 master session 继续像项目控制台一样清晰。

## 它保护了什么

| 区域 | 会发生什么 | 为什么重要 |
| --- | --- | --- |
| 干净 master | master session 只保存目标、约束、分支 registry、决策、风险和已批准摘要。 | 用户随时能回到全局视图，不会被执行噪声淹没。 |
| 脏解释分支 | 专门吸收长篇解释、背景学习、概念补课和“我这里没懂”的问题。 | 用户可以放心学习，不污染主 session。 |
| 可交互分支 | 子 agent 是用户能进入的 session，不是看不见的一次性后台 worker。 | 用户可以继续追问、纠偏、细化，而不必手动重开 session、手动复制 context。 |
| 自动 branch brief | Conductor 为每个分支准备启动上下文。 | 用户不用反复粘贴项目目标、约束和上下文。 |
| 依赖感知波次 | Conductor 先判断哪些分支现在能并行，哪些必须等前置产物完成。 | 不会把所有子 agent 都默认并行，任务会按正确顺序推进。 |
| 显式合并门 | 分支只有在用户确认完成后才生成 report，只有用户批准后才合并。 | master context 只增长经过筛选的长期知识，不吸收过程噪声。 |
| 可视化 registry | branch map、snapshot 和 Trellis-compatible metadata 记录每个分支在哪里、状态如何。 | 过程更可审计、可恢复，也更容易回退。 |

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
│   ├── conductor.yaml
│   └── trellis-task-meta.json
├── prompts/
│   ├── install-with-claude-code.md
│   └── install-with-codex.md
├── scripts/
│   └── install.sh
└── skills/
    └── conductor/
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
cp -R skills/conductor ~/.codex/skills/conductor
```

也可以在仓库根目录运行安装脚本：

```bash
bash scripts/install.sh
```

然后开启一个新的 Codex session，并这样触发：

```text
Use $conductor to split this complex task into dependency-aware interactive branches, keep the master session clean, and only merge approved completion reports.
```

## 交给 AI 一键安装

你也可以把安装交给 Codex 或 Claude Code：

- [Install with Codex](prompts/install-with-codex.md)
- [Install with Claude Code](prompts/install-with-claude-code.md)

把对应 prompt 整段复制给目标 AI coding agent 即可。prompt 已经指向当前 GitHub 仓库。

## 核心协议

Conductor 遵守几条硬规则：

1. master session 只保存全局上下文。
2. branch session 是用户可进入的交互线程，不是一次性后台 agent。
3. 分支只接收 branch brief、已批准摘要、显式文件引用，以及该分支线程里的用户消息。
4. 分支不能默认全部并行；Conductor 必须先做依赖分析和 wave plan。
5. completion report 只有在用户确认分支完成后才生成。
6. master session 只有在用户明确批准后才合并。
7. explainer branch 默认不合并。
8. 分支里的全局决策必须回到 master session 确认后才生效。

## Trellis 最佳实践

在 Trellis 中，Conductor 可以自然映射到父子任务：

- parent/root task：master session
- child task：interactive branch
- Codex / Claude Code thread：用户真正进入交互的分支会话
- `branch-map.md`：人类可读的分支视图
- `task.json.meta.conductor`：最小机器可读绑定信息
- 依赖字段：`execution_wave`、`depends_on`、`unblocks`、`gate_condition`

Conductor 应优先使用 Trellis task scripts 创建父子任务关系，不应把 `implement.jsonl` 或 `check.jsonl` 当成分支聊天历史的堆放区。

## grill-me + Trellis 工作流

Conductor 特别适合和 grill-me、Trellis 一起用：

| 工具 | 分工 |
| --- | --- |
| `grill-me` | 先把想法问透，澄清目标、非目标、约束和验收标准。 |
| `Conductor` | 判断上下文应该留在干净 master、进入可交互分支、进入脏解释 sidecar，还是进入合并流程。 |
| `Trellis` | 把结构持久化成 parent/child tasks，让分支产物可追踪、可回看。 |

推荐流程：

1. 在 master session 里先用 grill-me 追问需求。
2. 一旦出现多个可独立推进的方向，就启用 Conductor。
3. 打开分支前先做依赖分析：哪些能同一波并行，哪些必须等前置产物、决策或 report。
4. master session 映射成 Trellis parent/root task。
5. 当前 wave 的可交互分支映射成 Trellis child task，并绑定一个用户可进入的 AI coding thread。
6. 后续 wave 的依赖分支先保持 planned 或 blocked，等前置条件完成后再打开。
7. dirty explainer sidecar 默认不建 Trellis child task。
8. 只有用户确认分支完成后，才生成 completion report。
9. 只有用户批准后，才把压缩后的 report 合并回 master session。

可直接复制的启动 prompt：

```text
用 $grill-me 先追问和打磨我的需求，直到目标、非目标、约束和验收标准清楚。过程中一旦出现多个可独立推进的方向，就启用 $conductor。

把当前 session 作为 master session，只保留全局目标、约束、Trellis 分支图、关键决策、风险和批准后的摘要。

打开分支线程前，先做依赖分析。区分哪些分支可以在同一 wave 并行，哪些必须等待前置输出、决策或 completion report。

用 Trellis 持久化结构：master session 映射成 parent/root task；当前 wave 的可交互分支映射成 Trellis child task，并绑定一个用户可进入的 AI coding thread。后续 wave 的分支先保持 planned 或 blocked，等前置条件完成后再打开。

把复杂探索、实现、review、调研拆成可交互分支。另开一个 dirty explainer sidecar，专门让我问不懂的问题，默认不要并入 master session。

每个分支在打开前先生成 branch brief。只有我确认分支完成后，才生成 completion report。然后询问我是否合并回 master session，并且只合并我批准过的压缩摘要。
```

## 状态

初始公开草稿。License 目前刻意保留为 TBD。
