# Multi-Agent Verification Protocol

## When to Use

Use multi-agent verification when the test plan identifies 3+ independent verification targets (modals, pages, components) that:
- Share the same test user(s) but verify different UI elements
- Each have their own Figma frames
- Can be tested independently of each other

## Architecture

```
Orchestrator (main agent)
  ├── Stage 0-3: Sequential (plan, env check, user setup)
  │   └── All test users created and ready
  ├── Stage 4-6: Fan out to subagents
  │   ├── Subagent 1: <Component A> (visual + logic + responsive)
  │   ├── Subagent 2: <Component B> (visual + logic + responsive)
  │   └── Subagent N: <Component N> (visual + logic + responsive)
  └── Stage 7-8: Sequential (merge results → report → feedback)
```

## Subagent Task Format

Each subagent receives a scoped task:

```markdown
## Subagent Task: Verify <Component Name>

**Test user session**: <logged in as user X on TEST_ENV_URL>
**Figma frames**:
- Mobile: <figma_url_mobile>
- Desktop: <figma_url_desktop>

**AC points to verify**:
- AC #N: <specific AC text>

**Selectors**: Load from memory/selectors.md, section: <relevant section>

**Steps**:
1. Navigate to the state where <component> appears
2. Visual verification against Figma (both mobile + desktop)
3. Business logic verification for assigned AC points
4. Responsiveness check at 375px, 768px, 1280px

**Output**: Return structured results as:
```json
{
  "component": "<name>",
  "visual_checks": [...],
  "logic_checks": [...],
  "responsive_checks": [...],
  "screenshots": [...]
}
```
```

## Orchestrator Responsibilities

1. Parse test plan to identify independent verification targets
2. Create subagent tasks with scoped context (not full repo)
3. Launch subagents using Claude Code's Agent tool
4. Collect results from all subagents
5. Merge into single verification report
6. Run feedback capture on merged results

## When NOT to Use

- Single-component tickets (1-2 verification targets) → standard sequential flow
- Components that depend on each other's state (e.g., modal A must be dismissed before modal B appears)
- When test users can't be shared (each component needs a unique user state)
