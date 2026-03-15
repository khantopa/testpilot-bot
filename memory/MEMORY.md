# TestPilotBot Memory

## Repository Paths

```
FE_REPO=/Users/khantopa/dev/sa-v3
BE_REPO=/Users/khantopa/dev/seeking
QA_REPO=/Users/khantopa/dev/sa-ui-automation
```

## Key Paths

- Business rules: `/Users/khantopa/dev/sa-ui-automation/.cursor/business-rules/`
- Onboarding rules: `02-user-registration-onboarding-workflows.md`
- Test photo: `testpilot-bot/testdata/profile-photo-test.jpg`
- Default user profile: `testpilot-bot/defaults/user-profile.json`

## Test Environment Conventions

- Admin URL pattern: `<TEST_ENV_URL>/login` (or `/admin`)
- OTP in test environments: `000000`
- Test email format (generic): `testpilot_<timestamp>@seeking-test.com`
- Test email format (attractive): `khan+attr<id>@incube8.sg`
- Test email format (generous): `khan+gen<id>@incube8.sg`
- See: `memory/feedback_test_user_email_format.md`
- Test nickname format: `testpilot_<timestamp>`

## Campaign Cookie Protocol — Key Rules

- Cookie field names for `_join_inputValues` must be read from FE source, NOT guessed from Confluence. See: `memory/feedback_cookie_field_names.md`
- Modal click timing: use `browser_wait_for` + immediate `browser_evaluate` click — do NOT snapshot first. See: `memory/feedback_modal_playwright_timing.md`

## Campaign Cookie Protocol

- After setting `_join_inputValues` cookie, always **refresh the page** before proceeding — cookie detection is not reactive, only fires on page load
- See: `memory/feedback_cookie_set_refresh.md`

## User Preferences

- Default test environment: `https://members-testqa.seeking.com` — use automatically when no env URL provided
- See: `memory/feedback_default_test_env.md`

## Standing Test Accounts

- `khan+gdad@incube8.sg` — Generous male, existing approved member on testqa. Use for `not_eligible`, existing user scenarios. See: `memory/user_standing_accounts.md`

## Selfie / Liveness Bypass (IPCF)

- Append `?qaSimulateLiveness=APPROVE` to URL at the selfie step
- Works at any point during IPCF, not just initial /join
- See: `memory/feedback_selfie_bypass.md`

## Scenario Isolation

- Clear cookies + localStorage + sessionStorage at the start of EVERY scenario (simulates incognito)
- See: `memory/feedback_scenario_isolation.md`

## SPA Navigation Rule

- Use in-app buttons/links for route changes — NOT `browser_navigate`/`goto()` (resets React state)
- Exception: after QA API calls that mutate BE state, hard navigation is acceptable
- See: `memory/feedback_spa_navigation.md`

## Known Test Environment Quirks

- **force-approve timing**: After `GET /v3/users/{uid}/force-approve-profile`, wait 5 seconds then refresh — BE processes approval asynchronously; redemption modals won't fire until processing completes.
- **Female /join crash (2026-03-15)**: `CONTINUE_WITH_EMAIL_V2` event key missing from deployed bundle caused app unmount for Female users. Could not reproduce manually — likely environment fluke. Monitor on next run.

## Default Test User Settings

- **Location**: Singapore (always — not Sydney, not California)

## Reference Docs

- QA API endpoints: `memory/reference_qa_endpoints.md` — all non-prod endpoints for test data manipulation (force-approve, delete-member, OTP, subscriptions, liveness, etc.)

## Tools Available

- Playwright MCP: `npx @playwright/mcp@latest` — for browser automation (Stage 3 user setup, Stage 4 visual verification)
- See: `memory/user_playwright_mcp.md`

## Patterns Library Status

- Current patterns: 1
- Last pattern promotion: 2026-03-15 (`campaign-cookie-enrollment`)
- Feedback runs completed: 1

## Feature Rules Created

- `rules/features/SATHREE-41277-buc-2026-campaign-modals.md` — BUC 2026 campaign modals, all 7 modals, single-scenario test flows (2026-03-15)

## User Pool Strategy (future optimization)

For repeat verification runs on the same campaign:
- Maintain pre-approved users per account type on testqa
- Reset state via QA API (force-approve, delete-member, re-enroll)
- Skip IPCF entirely when user doesn't need to test onboarding flow
- Standing accounts in `memory/standing-accounts.json` serve this purpose
- Add more standing accounts as they're created during runs
