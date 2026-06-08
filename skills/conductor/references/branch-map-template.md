# Conductor Map: <project>

## Snapshot

- Snapshot id:
- Updated at:
- Master session:
- Dispatch session:
- Explainer sidecar:
- Active interactive branch limit: 2
- Current global goal:
- Current wave:

## Session Naming Rules

- Master: `[CD-MAIN][master] <project>`
- Dispatch: `[CD-DISPATCH][routing] Branch planning`
- Explainer: `[CD-E01][sidecar][explainer] Dirty questions`
- Branch: `[CD-001][W1][role] <short purpose>`
- Never put mutable status such as active/done/blocked in the session title.

## Today View

### Active Now

- ...

### Planned, Not Opened

- ...

### Blocked / Waiting

- ...

### Merge Pending

- ...

## Wave Plan

| Wave | Branches | Prerequisites | Gate to unlock next wave |
| --- | --- | --- | --- |
| 0 | CD-MAIN | none | scope confirmed |

## Branch Registry

| Branch | Stable title | Type | Interaction mode | Status | Wave | Depends on | Thread | Task dir | Return condition | Merge policy |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CD-MAIN | `[CD-MAIN][master] <project>` | master | n/a | active | 0 | none |  |  | project control | approved summaries only |
| CD-DISPATCH | `[CD-DISPATCH][routing] Branch planning` | dispatch | n/a | optional | sidecar | none |  | none | dispatch decision ready | final decisions only |
| CD-E01 | `[CD-E01][sidecar][explainer] Dirty questions` | explainer | n/a | active | sidecar | none |  | none | question answered | no merge by default |

## Visualization

```mermaid
flowchart TD
  ROOT["CD-MAIN Master session"]
  DISPATCH["CD-DISPATCH Branch planning"]
  EXPLAIN["CD-E01 Dirty explainer"]
  ROOT -. routing .-> DISPATCH
  ROOT -. explainer .-> EXPLAIN
```

## Proposed Global Decisions

- ...

## Staleness Warnings

- ...

## Next Recommended Step

- ...
