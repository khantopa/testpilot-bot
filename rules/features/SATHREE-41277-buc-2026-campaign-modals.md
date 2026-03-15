# BUC 2026 Campaign Modals — Feature Rules

**Linked ticket**: SATHREE-41277
**Campaign key**: `breakup_campaign_2026`
**FE module**: `resources/react-app/modules/Campaign/`
**Verified**: 2026-03-15

---

## Feature Description

The Break Up Campaign 2026 (BUC) enrolls users who arrive from the BUC landing page.
New users who register with the campaign cookie get a free gift (attractive: 90-day Gold;
generous: 3 boosts). A set of 7 Redux-driven modals communicate the offer status.

---

## Enrollment — `_join_inputValues` Cookie

Set BEFORE visiting `/join` for the first time. Payload is base64-encoded JSON.

**Source**: `FE_REPO/resources/react-app/components/auth/utils.tsx` lines 276–417

### Minimal cookie (enrollment + modal testing only)

```js
const payload = btoa(JSON.stringify({ submission_uid: crypto.randomUUID() }));
document.cookie = `_join_inputValues=${payload}; domain=.members-testqa.seeking.com; path=/`;
```

### Full cookie — Attractive user (female, Sugar Baby)

```js
const payload = btoa(JSON.stringify({
  submission_uid: crypto.randomUUID(),
  sex: "4",                              // "4"=Female = Attractive (Sugar Baby)
  gender_preference: ["248", "249"],     // Looking for male — API preference IDs (array)
  email: "testpilot_<timestamp>@seeking-test.com",  // MUST be a fresh email, never registered before
  dob: 946684800,                        // Unix timestamp (seconds) — e.g. 2000-01-01
  account_type: "2"                      // "2"=Attractive — auto-derived from sex:"4"
}));
document.cookie = `_join_inputValues=${payload}; domain=.members-testqa.seeking.com; path=/`;
```

### Full cookie — Generous user (male, Sugar Daddy)

```js
const payload = btoa(JSON.stringify({
  submission_uid: crypto.randomUUID(),
  sex: "3",                              // "3"=Male = Generous (Sugar Daddy)
  gender_preference: ["248", "249"],     // Looking for female — API preference IDs (array)
  email: "testpilot_<timestamp>@seeking-test.com",  // MUST be a fresh email, never registered before
  dob: 946684800,                        // Unix timestamp (seconds) — e.g. 2000-01-01
  account_type: "1"                      // "1"=Generous — auto-derived from sex:"3"
}));
document.cookie = `_join_inputValues=${payload}; domain=.members-testqa.seeking.com; path=/`;
```

### User type mapping (CRITICAL)
- `sex: "3"` → Male → `account_type: "1"` → **Generous** → gift = 3 boosts
- `sex: "4"` → Female → `account_type: "2"` → **Attractive** → gift = 90-day Gold
- Always use `testpilot_<timestamp>@seeking-test.com` — NEVER reuse a `khan+attr/gen<id>` email that may already exist in testqa (causes `not_eligible` cache key to fire)

### Cookie rules
- `submission_uid` MUST be a real UUID — `Str::isUuid()` validated in BE
- `sex` values: `"3"` = Male/Generous, `"4"` = Female/Attractive (NOT "male"/"female" — API attribute IDs)
- `dob` must be Unix timestamp (seconds) or `"MM/DD/YYYY"` / `"DD/MM/YYYY"` — ISO string `"1999-03-15"` is **invalid**
- Cookie is removed by FE after parsing on `/join` page load (not on modal detection)
- For `not_eligible` only: minimal cookie with `submission_uid` is sufficient

### Form auto-population behaviour (Req.4)
When full cookie is set and `/join` is loaded fresh:
- Valid `sex` + `gender_preference` → Step 1 pre-selected, FE skips to Step 2
- Valid `dob` or `bdayDay/Month/Year` → Step 2 pre-filled, FE skips to Step 3
- Valid `email` → Step 3 email field pre-filled
- If all valid → form opens directly at Step 3 (email)

**To verify**: after setting full cookie on a non-join page and navigating to `/join`, the form should open at Step 3 (not Step 1).

---

## Test Scenarios

### Scenario 1 — Attractive User Full Flow (covers 4 modals in one user)

This single scenario covers: `CampaignInfoModal` → `profile_completed` → `offer_pending_approval` → `gold_redemption_successful`.

**Steps:**

1. Set `_join_inputValues` cookie (valid UUID payload)
2. Register as **attractive** user → complete IPCF
   - **Verify**: `CampaignInfoModal` (`data-testid="campaign-notice-modal"`) appears mid-IPCF after "Tell us about yourself"
3. Complete IPCF → click **"View members"** on IPCF last page
   - **Verify**: `profile_completed` modal appears ("Thank you for completing your profile!")
   - This fires on profile completion (pending approval state) — before admin approval
4. Navigate to `/billing/memberships`
   - **Verify**: `offer_pending_approval` modal appears ("Your Gold offer is pending")
   - Note: route-restricted to `/billing/memberships` only
5. Simulate liveness FIRST: `POST /v3/liveness/qa-callback?is_metadata=0` with `{ uid, recommendation: "APPROVE" }`
6. Force-approve: `GET /v3/users/<uid>/force-approve-profile`
7. Refresh page or logout → login
   - **Verify**: `gold_redemption_successful` modal appears

### Scenario 2 — Generous User Full Flow (covers 3 modals in one user)

This single scenario covers: `CampaignInfoModal` → `profile_completed` → `boost_redemption_successful`.

**Steps:**

1. Set `_join_inputValues` cookie (valid UUID payload)
2. Register as **generous** user → complete IPCF
   - **Verify**: `CampaignInfoModal` appears mid-IPCF
3. Complete IPCF → click **"View members"** on IPCF last page
   - **Verify**: `profile_completed` modal appears (pending approval state — before admin approval)
4. Simulate liveness FIRST: `POST /v3/liveness/qa-callback?is_metadata=0` with `{ uid, recommendation: "APPROVE" }`
5. Force-approve: `GET /v3/users/<uid>/force-approve-profile`
6. Refresh page or logout → login
   - **Verify**: `boost_redemption_successful` modal appears with 3 boosts

### Scenario 3 — Existing Member (covers `not_eligible`)

1. Log in as standing account `khan+gdad@incube8.sg` (generous male, approved)
2. Set `_join_inputValues` cookie (minimal — `submission_uid` only)
3. Navigate to `/member`
   - **Verify**: `not_eligible` modal ("Not eligible for this offer") appears
   - **Note**: "View members" button does NOT appear here — that is IPCF-only for new users

### Scenario 4 — Attractive User 2: `gold_redemption_extended` (separate user)

This scenario requires a **second** attractive user. Covers: `CampaignInfoModal` → `profile_completed` → `gold_redemption_extended`.

The trigger is purchasing Gold **while still pending approval** — before the BUC gift is issued.

**Steps:**

1. Set `_join_inputValues` cookie (valid UUID payload)
2. Register as **attractive** user → complete IPCF
   - **Verify**: `CampaignInfoModal` appears mid-IPCF
3. Complete IPCF → click **"View members"**
   - **Verify**: `profile_completed` modal appears (pending approval state)
4. Navigate to `/billing/memberships` → purchase a Gold subscription manually
5. Simulate liveness FIRST: `POST /v3/liveness/qa-callback?is_metadata=0` with `{ uid, recommendation: "APPROVE" }`
6. Force-approve: `GET /v3/users/<uid>/force-approve-profile`
7. Refresh page or logout → login
   - **Verify**: `gold_redemption_extended` modal appears ("Gold Already Purchased")

### `not_eligible` appearing for newly enrolled user — Root Causes

Two independent mechanisms can trigger `not_eligible`:

1. **BE cache key** `buc2026_email_exists:{profile_id}` — set when email already exists at join time. Fires `onEmailAlreadyExistsDuringJoin`, cached for 1 hour. Fix: **always use a fresh email** that has never been registered.
2. **FE cookie hook** `useBUCModalDetection` — fires if `_join_inputValues` cookie is still present on load. Fix: cookie is consumed on `/join` page load (normal flow).

### Not Testable on testqa

- `offer_expired`: no QA endpoint to expire a `MembershipOffer` record

---

## Modal Names (from `CAMPAIGN_MODAL_NAMES` constant)

```ts
NOT_ELIGIBLE: 'not_eligible'                       // Invalid offer — cookie-triggered
BOOST_REDEMPTION_SUCCESSFUL: 'boost_redemption_successful' // Boost redemption success
OFFER_PENDING_APPROVAL: 'offer_pending_approval'   // Billing page promotion
GOLD_REDEMPTION_SUCCESSFUL: 'gold_redemption_successful'   // Gold welcome
GOLD_REDEMPTION_EXTENDED: 'gold_redemption_extended'       // Already has Gold package
OFFER_EXPIRED: 'offer_expired'                     // Expired offer error
PROFILE_COMPLETED: 'profile_completed'             // Profile completed (pending approval)
```

> There is no `boost_redemption_extended` modal.

## `determineModal()` Priority (highest to lowest)

1. `profile_completed` — IPCF complete, **before** admin approval
2. `gold_redemption_successful` — attractive, approved + liveness, gift issued
3. `gold_redemption_extended` — attractive, approved + liveness, Gold already purchased while pending
4. `boost_redemption_successful` — generous, approved + liveness, boosts issued
5. `offer_pending_approval` — approved + liveness, gift pending; **only on `/billing/memberships`**

> `profile_completed` fires on profile completion (pending state), NOT on approval.
> Redemption modals (`gold_*`, `boost_*`) fire AFTER approval + liveness.

## Test Users Required (4 total)

| # | Type | Covers |
|---|------|--------|
| Attractive 1 | Attractive, no prior Gold | `CampaignInfoModal` → `profile_completed` → `offer_pending_approval` → `gold_redemption_successful` |
| Attractive 2 | Attractive, purchases Gold while pending | `CampaignInfoModal` → `profile_completed` → `gold_redemption_extended` |
| Generous 1 | Generous | `CampaignInfoModal` → `profile_completed` → `boost_redemption_successful` |
| Existing Member | Any approved member | `not_eligible` |

## `canRedeemFreeGift()` Conditions

Rules engine rule ID 706: `rule.profile.buc2026.canRedeemFreeGift`
Requires BOTH:
- `profile.isApproved == true`
- `livenessVerification.status == 'approved'`

---

## Setup Rules

**Liveness → Approval order**: Simulate liveness FIRST, then force-approve.
Wrong order (approve → liveness) causes gift not to be issued.

**Viewing first modal after approval**: Click "View members" on IPCF last page.
Do NOT navigate/refresh to `/member` separately.

**`offer_pending_approval` route guard**: FE-enforced — only shows on `/billing/memberships`.

---

## Selfie / Liveness QA Simulation

```
POST /v3/liveness/qa-callback?is_metadata=0
Body: { "uid": "<user_uid>", "recommendation": "APPROVE" }
```

- `recommendation` must be uppercase `"APPROVE"`
- This is the ONLY method that fires the Pusher event (`selfie_verification_completed`)
- `simulate-screen` and `qa-set-trusted-member` set profile flags only — do NOT fire Pusher

---

## Gift Configuration (from seeder)

| User type | Gift |
|-----------|------|
| Attractive | 90-day premium Gold subscription |
| Generous | 3 boosts |

---

## CampaignInfoModal

- testid: `campaign-notice-modal`
- Title: "Your offer is just steps away"
- Body: "Finish onboarding and get approved to unlock your offer."
- Generic campaign checkpoint — expected for all campaigns using this enrollment flow
- Verify as part of Scenario 1/3, not as a standalone test

---

## Known Limitations

- `offer_expired`: no QA endpoint to expire a `MembershipOffer` — not testable on testqa
- `BillingPageBanner`: requirement removed from SATHREE-41277 scope — not implemented
- `markAsRedeemed()` auto-dismisses `offer_pending_approval` when Gold is successfully redeemed
