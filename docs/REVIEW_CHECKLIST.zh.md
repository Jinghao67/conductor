# 审核清单

发布到 GitHub 前，建议重点审核这些点。

## 产品定位

- [ ] `conductor` 是否清楚表达为分支治理层，而不是 Trellis executor？
- [ ] 是否清楚区分 master session、interactive branch、explainer sidecar？
- [ ] 是否避免把子分支描述成一次性后台 agent？

## Context Hygiene

- [ ] 主 session 是否默认不读取子 thread 原始历史？
- [ ] completion report 是否只在用户确认分支完成后生成？
- [ ] 合并是否只在用户明确确认后发生？
- [ ] explainer 是否默认不合并？

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
