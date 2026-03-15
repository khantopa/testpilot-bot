# /verify

Run a full pre-release verification for a Jira ticket.

## Usage

```
/verify
/verify SATHREE-41816
/verify SATHREE-41816 https://members-test13.seeking.com
```

## What This Does

Runs all 8 stages of TestPilotBot:
0. Pattern matching
1. Test plan generation (from Jira + Figma + business rules)
2. Environment check
3. Test user setup (register → onboard → admin approve)
4. Visual verification (CSS vs Figma)
5. Business logic verification (AC walk-through)
6. Responsiveness check (standard breakpoints)
7. Verification report
8. Feedback capture + knowledge growth (new feature rules if none existed)

## Required Inputs

If not provided as arguments, the agent will ask:
- Jira ticket ID
- Test environment URL

**Figma URL is auto-discovered** — the agent searches the Jira ticket description, comments,
and linked Confluence pages for figma.com URLs. You will only be asked for a Figma URL if
none can be found automatically.

## Output

Saves report to: `reports/verification-report-<TICKET_ID>-<timestamp>.md`
