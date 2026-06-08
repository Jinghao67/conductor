# 审核清单

发布到 GitHub 前，建议重点审核这些点。

## 产品定位

- [ ] `conductor` 是否清楚表达为分支治理层，而不是 Trellis executor？
- [ ] 是否清楚区分 master session、interactive branch、explainer sidecar？
- [ ] 是否清楚区分 dispatch session 和 master session？
- [ ] 是否避免把子分支描述成一次性后台 agent？

## Context Hygiene

- [ ] 主 session 是否默认不读取子 thread 原始历史？
- [ ] completion report 是否只在用户确认分支完成后生成？
- [ ] 合并是否只在用户明确确认后发生？
- [ ] explainer 是否默认不合并？
- [ ] explainer 是否可以按需读取所有 session 的相关上下文，同时明确其回答不具备全局决策效力？
- [ ] 是否明确禁止默认把所有分支并行启动？
- [ ] 是否强制先创建 branch card，再创建真实 session？
- [ ] 是否强制稳定 session 命名，且不把 active/done/blocked 写进标题？

## 依赖与顺序

- [ ] 是否在创建分支前先做 dependency pass？
- [ ] 是否能区分当前可并行 wave 和后续依赖 wave？
- [ ] dispatch session 是否只处理开 session、并行/串行、wave plan，不做实现/调研/解释？
- [ ] blocked/planned 分支是否清楚记录前置条件？
- [ ] branch brief 是否包含 `depends_on`、`execution_wave`、`gate_condition`？
- [ ] Trellis metadata 是否能表达依赖和解锁关系？

## Trellis 集成

- [ ] Trellis 映射是否符合你的实际工作流？
- [ ] `task.json.meta.conductor` 字段是否足够但不过度？
- [ ] 是否应该保留 `conductor.yaml` 作为可选 source of truth？
- [ ] 是否应在 README 中加入更具体的 Trellis 命令示例？

## 模板

- [ ] `branch-brief-template.md` 是否足够短？
- [ ] `completion-report-template.md` 是否能防止报告本身变成污染源？
- [ ] `branch-map-template.md` 是否适合你想要的可视化分叉视图？

## 发布前决策

- [ ] GitHub repo 名称是否使用 `conductor`？
- [ ] 是否添加开源许可证？如果添加，选择 MIT / Apache-2.0 / 其他？
- [ ] README 是否需要中文版本？
- [ ] 是否需要 GitHub Actions 校验 skill 格式？
