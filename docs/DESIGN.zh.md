# Conductor 设计说明

`conductor` 是一个 context isolation + branch registry skill。它负责在复杂工作流里保持主 session 干净，同时把容易污染上下文的探索、实现、调研、审阅、解释拆到用户可进入的交互式分支 session。

它不是 Trellis executor，也不是后台 subagent 管理器。它是分支治理层：决定信息应该留在主干、进入交互分支、进入 explainer sidecar，还是进入合并流程。

## 核心定位

- 主 session 保存全局视图：目标、约束、分支图、全局决策、已批准摘要、风险、下一步。
- 先创建可见 branch card，再创建真实 session；每个 session 必须有稳定 ID、稳定标题、Purpose Card、预期产物和 return condition。
- session 标题必须能在 thread 列表里直接识别用途，例如 `[CD-001][W1][design] API contract`；不要把 `active/done/blocked` 这种会变化的状态写进标题。
- 当“是否开 session、并行还是串行、wave 怎么排”的讨论超过几轮时，使用固定的 `[CD-DISPATCH][routing] Branch planning`，只把最终调度决策回传主 session。
- 子分支是用户可进入、可继续对话的 AI coding thread，例如 Codex 或 Claude Code session，不是一次性后台 worker。
- 子分支只继承 `branch brief`，不继承主 session 原始历史。
- 子分支完成后，只有用户确认完成才生成 `completion report`。
- 主 session 只有在用户明确选择并入后，才读取 completion report 并压缩合并。
- explainer 是学习和解释污染区，默认不并入主 session；它可以按需读取所有 session 的相关上下文来回答问题，但其输出不具备全局决策效力。
- 打开分支前必须先做依赖分析，区分当前可并行 wave、后续依赖 wave 和需要 gate 的任务。

## 状态机

| 状态 | 含义 | 下一步 |
| --- | --- | --- |
| `planned` | 主 session 建议创建，用户尚未确认 | create brief / cancel |
| `brief_ready` | brief 已生成，thread 尚未创建 | create thread / revise brief |
| `active` | 用户可进入交互 | block / park / suggest completion |
| `blocked` | 等待主干决策、用户输入、外部输入或其他分支 | resume / cancel |
| `completion_suggested` | 分支认为可以完成，等待用户确认 | confirm / continue |
| `report_ready` | 用户确认完成，completion report 已生成 | request merge / archive |
| `merge_pending` | 主 session 等待用户决定是否并入 | merge / reject / defer |
| `merged` | 主 session 已写入批准后的压缩记录 | archive |
| `rejected` | 用户选择不并入 | archive |
| `archived` | 不再活跃展示 | reopen |

默认 active interactive branch 上限为 2。固定 explainer sidecar 和可选 dispatch session 不计入该上限。创建第 3 个 active branch 前，应建议用户先 park、完成或归档一个现有分支。

## Session 命名与调度室

固定命名格式：

```text
[CD-MAIN][master] Project control room
[CD-DISPATCH][routing] Branch planning
[CD-E01][sidecar][explainer] Dirty questions
[CD-001][W1][design] API contract
[CD-002][W1][review] Risk check
[CD-003][W2][implement] Prototype implementation
```

`CD-DISPATCH` 默认不开；当候选分支超过 3 个、依赖顺序不清楚、或者分支规划讨论超过 2-3 轮时再打开。它只讨论是否开 session、哪些并行/串行、每个 session 的 purpose/output/return condition，不做实现、调研、review 或长篇解释。

## 依赖分析与 Wave Plan

Conductor 不应默认所有子分支都能并行。创建 thread 或 Trellis child task 前，必须先判断：

- 哪些分支能基于当前 master snapshot 同时开始
- 哪些分支必须等待前置分支的产物、决策或 completion report
- 哪些节点是 gate，例如用户确认、review、merge 或全局决策
- 哪些是 optional，不在关键路径上
- explainer 是否只是 sidecar，还是被用户明确设为 blocking

推荐用 wave 表达执行顺序：

| Wave | 分支 | 前置条件 | 解锁下一波的 gate |
| --- | --- | --- | --- |
| 0 | master decisions | none | scope confirmed |
| 1 | 可立即并行的分支 | current snapshot | completion reports reviewed |
| 2 | 依赖 Wave 1 的分支 | Wave 1 outputs | merge or user decision |

只有当前 wave 的分支默认进入 active。后续分支先保持 `planned`，如果用户提前启动，则标记为 `blocked` 并说明缺少哪个前置条件。

## Trellis 映射

在 Trellis 工作流中：

- 父任务或根任务对应 master session。
- dispatch 是 sidecar routing thread，默认不创建 Trellis child task。
- child task 对应 interactive branch。
- AI coding thread 对应用户实际进入交互的分支 session。
- explainer 是 context-rich sidecar thread，默认不创建 Trellis child task。
- `branch-map.md` 放在父任务目录，给用户看全局分叉图。
- `task.json.meta.conductor` 保存最小机器可读绑定信息。
- 依赖字段建议包含 `execution_wave`、`depends_on`、`unblocks`、`start_policy`、`gate_condition`。

推荐结构：

```text
.trellis/tasks/<parent-task>/
  task.json
  prd.md
  branch-map.md
  conductor.yaml        # optional

.trellis/tasks/<child-task>/
  task.json
  prd.md
  branch-brief.md
  completion-report.md     # 用户确认完成后才生成
  conductor.md          # optional
```

父子关系应优先通过 Trellis 脚本创建，例如 `task.py create --parent` 或 `task.py add-subtask`。`conductor` 不应手写 `parent` / `children`，除非脚本不可用或失败。

## JSONL 污染边界

`conductor` 默认不把 branch brief、completion report、原始对话摘要写入 `implement.jsonl` 或 `check.jsonl`。

只有当用户明确进入 Trellis implementation/check 阶段，并确认某个分支产物是执行或检查必须读取的上下文时，才允许把相应文件加入 JSONL。

## Snapshot / Staleness

主 session 应在关键事件后生成短快照：

- 创建分支
- 完成分支
- 合并分支
- 归档分支
- 确认全局决策

每个 branch brief 记录 `based_on_snapshot_id` 和 `brief_version`。如果主干目标、验收标准或关键约束变化，active 分支应标记 stale，并询问用户是否刷新 brief。

## 非 Trellis 降级

没有 Trellis 时，使用：

- `conductor.yaml` 作为机器可读 registry
- `branch-map.md` 作为用户可读快照
- Mermaid 图表示分叉关系

语义应与 Trellis 映射保持一致。
