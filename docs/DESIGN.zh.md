# Clean Branch 设计说明

`clean-branch` 是一个 context isolation + branch registry skill。它负责在复杂工作流里保持主 session 干净，同时把容易污染上下文的探索、实现、调研、审阅、解释拆到用户可进入的交互式分支 session。

它不是 Trellis executor，也不是后台 subagent 管理器。它是分支治理层：决定信息应该留在主干、进入交互分支、进入 explainer sidecar，还是进入合并流程。

## 核心定位

- 主 session 保存全局视图：目标、约束、分支图、全局决策、已批准摘要、风险、下一步。
- 子分支是用户可进入、可继续对话的 Codex thread，不是一次性后台 worker。
- 子分支只继承 `branch brief`，不继承主 session 原始历史。
- 子分支完成后，只有用户确认完成才生成 `completion report`。
- 主 session 只有在用户明确选择并入后，才读取 completion report 并压缩合并。
- explainer 是学习和解释污染区，默认不并入主 session。

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

默认 active 分支上限为 3。创建第 4 个 active 分支前，应建议用户先 park、完成或归档一个现有分支。

## Trellis 映射

在 Trellis 工作流中：

- 父任务或根任务对应 master session。
- child task 对应 interactive branch。
- Codex thread 对应用户实际进入交互的分支 session。
- explainer 是 sidecar thread，默认不创建 Trellis child task。
- `branch-map.md` 放在父任务目录，给用户看全局分叉图。
- `task.json.meta.clean_branch` 保存最小机器可读绑定信息。

推荐结构：

```text
.trellis/tasks/<parent-task>/
  task.json
  prd.md
  branch-map.md
  clean-branch.yaml        # optional

.trellis/tasks/<child-task>/
  task.json
  prd.md
  branch-brief.md
  completion-report.md     # 用户确认完成后才生成
  clean-branch.md          # optional
```

父子关系应优先通过 Trellis 脚本创建，例如 `task.py create --parent` 或 `task.py add-subtask`。`clean-branch` 不应手写 `parent` / `children`，除非脚本不可用或失败。

## JSONL 污染边界

`clean-branch` 默认不把 branch brief、completion report、原始对话摘要写入 `implement.jsonl` 或 `check.jsonl`。

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

- `clean-branch.yaml` 作为机器可读 registry
- `branch-map.md` 作为用户可读快照
- Mermaid 图表示分叉关系

语义应与 Trellis 映射保持一致。
