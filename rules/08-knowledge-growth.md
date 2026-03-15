# Stage 8 (Post-Feedback): Knowledge Growth

Run this stage AFTER Stage 8 (Feedback Capture) when no feature rules existed at the start of the run.

This stage answers: **"What did we learn, and how do we preserve it for next time?"**

---

## 8.1 — Knowledge Sources (Priority Order)

When loading business rules at Stage 1, check these sources in order — highest priority first:

### Priority 1: TestPilotBot Feature Rules (`rules/features/`)
- Generated from previous verification runs by this agent
- Actively growing — check here first
- Match by: ticket ID, feature name, or related keywords in filename/content

### Priority 2: QA Business Rules (`QA_REPO/.cursor/business-rules/`)
- 30 legacy files — read-only baseline, not actively maintained
- **Do NOT load the full directory** — scan filenames and first 10 lines of each file
- Select 2–4 most relevant files based on the feature being tested; load only those

### Priority 3: Jira AC + Figma + Confluence
- Always authoritative for new features
- Used when no rules exist, or to supplement incomplete rules

---

## 8.2 — Lookup Protocol (Stage 1)

```
1. Scan rules/features/ for files matching:
   - Ticket ID (e.g., SATHREE-41816 in filename or content)
   - Feature name from Jira summary
   - Related keywords (e.g., "registration", "premium", "campaign")

2. IF match found in rules/features/:
   → Load as primary business rules context
   → Note: "Loaded feature rules from rules/features/<filename>"
   → Still cross-reference against Jira AC for any new AC points

3. IF no match in rules/features/:
   → Scan QA_REPO/.cursor/business-rules/ filenames
   → Read first 10 lines of candidate files
   → Select 2-4 most relevant and load them
   → Note: "No TestPilotBot feature rules found. Using QA baseline: <files>"

4. IF still insufficient coverage after steps 1-3:
   → Flag to user: "No existing business rules fully cover this feature.
     After verification, I'll draft a new feature rules file."
   → Continue — use Jira AC as sole source of truth for business logic
   → Set flag: DRAFT_FEATURE_RULES = true
```

---

## 8.3 — Feature Rules Generation (After Stage 8)

This runs only when `DRAFT_FEATURE_RULES = true` (no prior feature rules existed).

### What to include

Generate a draft feature rules file containing:

- **Feature description** — what the feature is and its purpose in the product
- **Key flows** — the main user journeys exercised during verification
- **Decision logic** — branching conditions discovered during testing (e.g., "if user is premium, X; otherwise Y")
- **Expected behaviors** — outcomes confirmed passing during this run
- **Edge cases discovered** — unexpected states or inputs encountered
- **Known limitations** — what could not be verified and why
- **Linked ticket** — the Jira ticket that prompted this rules file

### Format

Follow the same markdown format as QA's existing business rules files:
- Use `##` headings for sections
- Use numbered lists for sequential steps
- Use `**bold**` for field names and key terms
- Include code blocks for URLs, formats, and example values

### File naming

```
rules/features/<ticket-id>-<feature-name-kebab-case>.md

Examples:
  rules/features/SATHREE-41816-premium-profile-upgrade.md
  rules/features/SATHREE-39200-revolve-campaign-join.md
```

---

## 8.4 — Review Gate

Before saving, present the draft to the user:

```
📚 Knowledge Growth — New Feature Rules Draft

I've drafted a feature rules file from this verification run:
  rules/features/<filename>

Key sections:
- <list top 3-4 sections>

[Present full draft]

Review options:
(A) Save as-is — commit to rules/features/
(B) Edit first — [user specifies changes, regenerate, re-present]
(C) Skip — don't save this run's learnings
```

Wait for user selection before writing the file.

**If user selects (A) or after (B) edits are accepted:**
1. Write the file to `rules/features/<filename>`
2. Log in `memory/MEMORY.md`:
   ```
   - Created feature rules: <filename> from <ticket-id> (<date>)
   ```

---

## 8.5 — Updating Existing Feature Rules

When a feature rules file already exists and new learnings contradict or extend it:

```
IF during verification you discover:
  - A behavior that contradicts existing rules
  - New edge cases not covered by existing rules
  - AC points that expand the known behavior

→ Note the discrepancy in the verification report
→ After Stage 8, present a diff to the user:
  "The existing rules for <feature> may need updating based on this run.
   Here's what changed: [diff]"
→ Ask: "(A) Update the rules file, (B) Leave as-is"
```

---

## Output

- (If new rules created) A new file at `rules/features/<ticket-id>-<feature-name>.md`
- (If existing rules updated) Updated file with changelog comment
- Memory log entry in `memory/MEMORY.md`
