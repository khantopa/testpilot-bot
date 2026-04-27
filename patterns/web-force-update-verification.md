# Pattern: Web Force Update Verification

## Trigger

**Keywords** (must appear in feature name, ticket, or description):
- web_force_update
- forceVersionUpdate
- force page refresh
- force page reload
- force version update

**Conditions** (any of these):
- Feature modifies pages/routes to call `forceVersionUpdate()`
- Feature changes the `WEB-TIMESTAMP` header or version comparison logic
- Feature extends the existing force-update mechanism to new pages/entry points

**Confidence Threshold**: 4

## Protocol

When this pattern is matched, execute these steps instead of the standard flow:

1. **Identify target pages** — Read the diff to find which pages/routes now call `forceVersionUpdate()` or watch `web_force_update` state.

2. **Identify the API endpoint** — The global Axios interceptor in `shared/utils/sdk.ts` checks `response.data.metadata.web_force_update` on all API responses. Find which endpoint the target page calls that returns metadata (typically `profile-attributes` with `is_metadata` not set to 0).

3. **Test natural BE trigger first** — Set up Playwright route interception to modify the outgoing `WEB-TIMESTAMP` header to an old value (e.g. `1700000000`) on the target API endpoint. Navigate to the target page. Capture the response to confirm BE returns `metadata.web_force_update: true`.

4. **Test via response injection** — If natural trigger doesn't work or for cleaner isolation: intercept the API response and inject `metadata.web_force_update: true` into the first response only. Let subsequent requests pass through normally.

5. **Verify reload** — Detect page reload via Playwright `page.on('load')` event or console log cycles (e.g. repeated GTM-INIT entries). Confirm page reloads within ~2 seconds of the API response.

6. **Verify no infinite loop** — After the reload, the page should settle. The `forceVersionUpdate()` function dispatches `toggleForceVersionUpdate()` (sets flag to `false`) before calling `window.location.reload()`. On the second load, the normal API response should NOT contain `web_force_update: true`, so no re-trigger.

7. **Repeat for each target page** — Run steps 3-6 for every page in scope.

## Termination Conditions

| If | Then |
|----|------|
| Page reloads once after `web_force_update: true` and settles | PASS |
| Page does not reload when `web_force_update: true` is in response | FAIL — useEffect or interceptor not wired correctly |
| Page reloads infinitely | FAIL — `toggleForceVersionUpdate()` not resetting flag before reload |
| BE does not return `web_force_update: true` with old `WEB-TIMESTAMP` | INCONCLUSIVE — BE mechanism may not be deployed; fall back to response injection |

## Key Architecture Notes

- `forceVersionUpdate()` is in `shared/utils/routeHelper.ts` — reads `store.getState().user.web_force_update` directly
- The global interceptor is in `shared/utils/sdk.ts` (`interceptResponse`) — dispatches `toggleForceVersionUpdate` action when `metadata.web_force_update` is truthy
- The `is_metadata` throttle in `sdk.ts` suppresses metadata on GET requests within 5 seconds — first request on page load should NOT be throttled
- Login page uses `[user.web_force_update]` useEffect dependency (connected to Redux)
- Join page uses `[]` mount-only useEffect (reads store directly, no Redux connect)
- Member routes use `onEnter={forceVersionUpdate}` callbacks in `App.tsx`

## Known Instances

| Date | Ticket | Outcome | Notes |
|------|--------|---------|-------|
| 2026-03-26 | SATHREE-41764 | PASS (4/4) | Login + Join pages. Natural BE trigger confirmed. No infinite loop. |
