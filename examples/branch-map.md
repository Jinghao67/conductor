# Clean Branch Map: Example Project

## Snapshot

- Snapshot id: `snap-2026-06-03-001`
- Updated at: 2026-06-03
- Master session: `CB-ROOT`
- Active branch limit: 3
- Current global goal: Keep the master session clean while interactive branches do detailed work.

## Branch Registry

| Branch | Type | Status | Thread | Task dir | Based on snapshot | Merge policy |
| --- | --- | --- | --- | --- | --- | --- |
| CB-ROOT | master | active | current | .trellis/tasks/root | snap-2026-06-03-001 | approved summaries only |
| CB-001 | interactive | active | thr_example_api_contract | .trellis/tasks/api-contract | snap-2026-06-03-001 | explicit user confirm |
| CB-E01 | explainer | active | thr_example_explainer | none | snap-2026-06-03-001 | no merge by default |

## Visualization

```mermaid
flowchart TD
  ROOT["CB-ROOT Main session / root task"]
  B1["CB-001 API contract exploration<br/>active / interactive"]
  E1["CB-E01 Trellis JSONL explainer<br/>active / no-merge default"]

  ROOT --> B1
  ROOT -. explainer .-> E1
```

## Active Branches

- CB-001: Explore the API contract and produce a completion report after user-confirmed completion.
- CB-E01: Explain Trellis JSONL context. Default no merge.

## Merge Pending

- None.

## Proposed Global Decisions

- None.

## Staleness Warnings

- None.

## Next Recommended Step

- Continue CB-001 or create one additional planned branch.
