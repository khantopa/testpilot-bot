# Campaign: Revolve 2026

## Detection

This campaign rule file loads when any of these appear in the Jira ticket:
- Labels: `revolve`, `revolve-2026`, `revolve-campaign`
- Components: `Revolve`
- Description contains: "Revolve", "revolve partnership"

---

## Pre-Setup: Cookie Injection

BEFORE navigating to /join, inject the following cookies in the test environment browser:

```javascript
// Revolve campaign entry cookies (set by CF Worker in production)
// These must be set BEFORE the join flow to simulate campaign entry

const cookieDomain = new URL(TEST_ENV_URL).hostname;

document.cookie = `revolve_campaign=1; domain=.${cookieDomain}; path=/; SameSite=Lax`;
document.cookie = `revolve_ref=revolve.com; domain=.${cookieDomain}; path=/; SameSite=Lax`;
document.cookie = `campaign_source=revolve; domain=.${cookieDomain}; path=/; SameSite=Lax`;
```

> **Note**: Exact cookie names and values must be verified against the Revolve integration Jira tickets or the CF Worker configuration. Update this file if cookie names change.

**Verify cookies are set:**
```javascript
document.cookie // should contain revolve_campaign=1
```

If cookies can't be set (cookie blocked, domain mismatch):
- Note in report: "Campaign cookies could not be injected in test environment"
- Ask user: "Are Revolve campaign cookies settable on <TEST_ENV>? Manual injection may be required."

---

## Entry Point

Instead of `/join`, Revolve campaign users may enter through:
- `/revolve` (campaign landing page)
- `/join?campaign=revolve`
- A redirect from the campaign URL (requires cookies to already be set)

Check the Jira ticket for the correct entry URL. If not specified, use `/join` with cookies pre-set.

---

## Expected Campaign Behaviour

When Revolve campaign cookies are present:
1. Join page may show campaign-branded UI (Revolve-specific copy, branding)
2. Account type pre-selection may differ from standard join flow
3. Tracking events should fire for campaign attribution

Verify these behaviours are present when testing Revolve-specific tickets.

---

## Test User Defaults for Revolve

Override standard defaults when creating Revolve test users:
- **Account Type**: Check ticket — Revolve may target specific account types
- **Nickname prefix**: `revolve_testpilot_<timestamp>`

---

## Report Header

Add to verification report when this campaign is active:

```markdown
**Campaign**: Revolve 2026
**Entry Cookies**: revolve_campaign=1, revolve_ref=revolve.com, campaign_source=revolve
**Entry URL**: <URL used>
```

---

## Last Updated

2026-03-15 — Initial version. Verify cookie names against current CF Worker config before use.
