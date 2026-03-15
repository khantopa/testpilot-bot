# Stage 1: Test Plan Generation

Run this stage AFTER the pattern engine (Stage 0) and BEFORE environment check.

This stage answers: **"What exactly are we testing, and how?"**

---

## 1.1 — Collect Inputs

Before generating anything, confirm you have at minimum:

```
[ ] Jira ticket ID (e.g., SATHREE-41816)
[ ] Test environment URL (e.g., https://members-test13.seeking.com)
```

Figma URL is **auto-discovered** from Jira and Confluence — do not ask for it upfront.

If Jira ticket ID or test environment URL is missing, ask the user before proceeding. Do not generate a test plan with assumed inputs.

---

## 1.2 — Read the Jira Ticket

Use the Atlassian MCP to fetch the Jira issue:

```
mcp__claude_ai_Atlassian__getJiraIssue(issueIdOrKey: "<TICKET_ID>")
```

Extract and record:
- **Summary** — one-line feature description
- **Description** — full context and background
- **Acceptance Criteria** — every AC bullet point, numbered sequentially
- **Labels / Components** — determine if campaign-specific (e.g., Revolve)
- **Linked issues** — related tickets that may affect scope
- **Linked Confluence pages** — note all remote links for Figma discovery
- **Reporter / Assignee** — for escalation if needed
- **Status** — confirm ticket is in "Ready for QA" or equivalent state

**If AC is missing or vague:**
- Note exactly which AC points are unclear
- Add them to the test plan as `INCONCLUSIVE` checks with a note to clarify with the reporter
- Do NOT invent acceptance criteria

---

## 1.2a — Discover Figma URL

After reading the Jira ticket, search for the Figma URL automatically. Check these sources in order:

**Source 1: Jira ticket description**
- Scan the description text for any `figma.com` URLs (design files, prototypes, or board links)

**Source 2: Jira ticket comments**
```
mcp__claude_ai_Atlassian__fetchAtlassian(url: "<jira_api_url>/issue/<TICKET_ID>/comment")
```
- Scan all comment bodies for `figma.com` URLs

**Source 3: Linked Confluence pages**
```
mcp__claude_ai_Atlassian__getJiraIssueRemoteIssueLinks(issueIdOrKey: "<TICKET_ID>")
```
- For each linked Confluence page, fetch it via MCP and search the body for `figma.com` URLs:
```
mcp__claude_ai_Atlassian__getConfluencePage(pageId: "<page_id>")
```

**URL parsing — extract fileKey and nodeId:**
- Design file format: `https://figma.com/design/:fileKey/:fileName?node-id=:nodeId`
- Board format: `https://figma.com/board/:fileKey/:fileName?node-id=:nodeId`
- The nodeId uses `-` in URLs but `:` in API calls — convert `1-2` → `1:2`

**Decision logic:**
```
IF multiple Figma URLs found:
  → Present them to the user: "I found X Figma URLs — which one is the design spec?"
  → Wait for user to select before proceeding to 1.3

IF exactly 1 Figma URL found:
  → Use it automatically, note where it was found

IF no Figma URL found anywhere:
  → Ask the user: "I couldn't find a Figma URL in the Jira ticket, comments, or linked
    Confluence pages. Can you provide the Figma design URL?"
  → If user cannot provide one: note in test plan, mark all visual checks as
    INCONCLUSIVE — No Figma URL available
```

---

## 1.3 — Read the Figma Design

Use the Figma MCP to fetch design context:

```
mcp__claude_ai_Figma__get_design_context(fileKey: "<key>", nodeId: "<nodeId>")
mcp__claude_ai_Figma__get_screenshot(fileKey: "<key>", nodeId: "<nodeId>")
```

Extract and record for each relevant frame:
- **Frame name** — identifies which screen/state
- **Typography** — font-family, font-size, font-weight, line-height, color
- **Spacing** — padding, margin, gap values (check auto-layout settings)
- **Colors** — exact hex values or design token names
- **Component structure** — which components are used and how they're arranged
- **Responsive frames** — check for mobile (375px), tablet (768px), desktop (1280px) frames
- **States** — default, hover, active, disabled, error states

**If Figma URL is a full file URL (not a specific frame):**
- Ask the user which frame/component to focus on
- Do not attempt to verify the entire file

**If Figma returns no data:**
- Note the failure in the test plan
- Proceed with Jira AC only; mark all visual checks as `INCONCLUSIVE — No Figma data`

---

## 1.4 — Read Business Rules

Use the priority-based knowledge lookup defined in `rules/08-knowledge-growth.md`:

**Priority 1 — TestPilotBot feature rules** (`rules/features/`)
- Scan for files matching this ticket ID, feature name, or related keywords
- If found: load as primary context alongside Jira AC

**Priority 2 — QA business rules** (`QA_REPO/.cursor/business-rules/`)
- Read filenames and first 10 lines of each file
- Select 2–4 most relevant files based on the feature being tested
- Load only those files (not the full directory)

**Priority 3 — Jira AC + Figma + Confluence**
- Always authoritative for new features where no rules exist yet

Cross-reference AC against loaded business rules:
- Does the AC contradict any established business rule?
- Are there edge cases in the business rules not covered by the AC?
- Note any discrepancies for reporting

**If no rules cover this feature:**
- Flag to user: "No existing business rules fully cover this feature. After verification, I'll draft a new feature rules file."
- Continue with Jira AC as sole source of truth for business logic

---

## 1.5 — Identify Required Test Users

Based on the feature being tested, determine what user types are needed:

| User Type | When Needed |
|-----------|------------|
| **New unverified user** | Testing join/registration flow |
| **IPCF-complete, pending approval** | Testing PAS queue, approval flows |
| **Approved standard member** | Testing member features |
| **Approved premium member** | Testing subscription features |
| **Admin user** | For approval workflows |

For each required user type:
- Note the setup steps needed (see `rules/02-setup-protocol.md`)
- Estimate setup time (allow 5–10 min per user in test environment)

---

## 1.6 — Generate the Test Plan

Structure the test plan as:

```markdown
## Test Plan: <Feature Name> (<Ticket ID>)

### Inputs
- Jira: <ticket ID> — <summary>
- Figma: <URL>
- Test Env: <URL>

### Test Users Required
| # | Type | Purpose |
|---|------|---------|
| 1 | <type> | <what this user tests> |

### Visual Checks
| # | Element | Expected (Figma) | CSS Properties to Verify |
|---|---------|-----------------|--------------------------|
| 1 | <element> | <Figma value> | font-size, color, padding |

### Business Logic Checks (from AC)
| # | AC Point | Test Scenario | Expected Outcome |
|---|----------|---------------|-----------------|
| 1 | AC #1: <text> | <how to trigger> | <expected result> |

### Responsiveness Checks
| # | Breakpoint | Element | Expected Behavior |
|---|-----------|---------|------------------|
| 1 | 375px | <element> | <behavior> |

### Regression Risks
- <list of adjacent features that could be affected>
- <areas of the codebase touched by this change based on Jira>

### Blockers / Unclear Items
- <list anything that's ambiguous or missing>
```

---

## 1.7 — Decision Gates

**Gate: Is the ticket Ready for QA?**
```
IF ticket status != "Ready for QA" (or equivalent):
  → Warn the user: "Ticket is in <status> state. Proceed anyway?"
  → If user says no: stop here, do not set up test data
  → If user says yes: continue with a warning in the report
```

**Gate: Does Figma have enough detail?**
```
IF Figma returns < 3 CSS properties for the main component:
  → Note "Limited Figma data" in test plan
  → Visual checks will be LOW confidence
  → Ask: "Do you have a more specific Figma frame URL?"
```

**Gate: Are there AC points?**
```
IF no acceptance criteria found in Jira:
  → Do NOT invent AC
  → Ask user: "No AC found in JIRA. Can you provide acceptance criteria to test against?"
  → Pause until AC received
```

---

## 1.8 — Campaign Detection

Before finalising the test plan, check Jira labels, components, and description for campaign keywords:
- "Revolve", "revolve-2026"
- Any partnership or campaign name

```
IF campaign detected:
  → Load rules/campaigns/<campaign>.md
  → Add campaign-specific cookie setup to Stage 3 (before user creation)
  → Note campaign in report header
```

---

## Output

A structured test plan presented to the user for confirmation before proceeding to Stage 2.

Say:
```
📋 Test Plan Ready

I've generated a test plan for <Feature>. Here's what I'll verify:
- X visual checks
- X business logic checks (AC points)
- X responsiveness breakpoints
- X test users to create

[Present the full test plan]

Does this look correct? Anything to add or remove before I start?
(A) Looks good — proceed to environment check
(B) Edit — [user specifies changes]
(C) Stop — abort verification
```

Wait for user confirmation before proceeding to Stage 2.
