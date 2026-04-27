# Campaign Skill: Revolve Festival 2026

## Detection

This skill loads when any of these appear in the Jira ticket or AC file:

- Keywords: `revolve`, `revolve_festival_2026`, `revolve-2026`
- Components: `Revolve`
- Description contains: "Revolve Festival", "revolve campaign"
- AC file reference: `ac-revolve-festival-2026-combined.md`

**Supersedes**: `rules/campaigns/revolve-2026.md` (v1 skeleton — cookie names were guessed)

---

## Campaign Identity

| Field                     | Value                                                          |
| ------------------------- | -------------------------------------------------------------- |
| Campaign key              | `revolve_festival_2026`                                        |
| `user.profile_campaign`   | `'revolve_festival_2026'`                                      |
| Cookie name               | `_join_inputValues` (base64-encoded JSON)                      |
| Cookie TTL (production)   | 5 minutes (`300000ms`)                                         |
| Cookie flags (production) | `Secure; SameSite=Strict`                                      |
| FE module                 | `resources/react-app/modules/Campaign/`                        |
| FE cookie detector        | `detectCampaignCookie()` (refactored from `detectBUCCookie()`) |

---

## Cookie Payload (Production Shape)

The CF Worker decrypts the email from Acoustic before writing the cookie.
The FE receives both plaintext and encrypted values — **no crypto on FE side**.

```typescript
interface RevolveJoinCookiePayload {
  submission_uid: string; // UUID — MUST be crypto.randomUUID(), NOT Date.now()
  campaign: string; // 'revolve_festival_2026'
  email: string; // decrypted plaintext (e.g. "user@example.com")
  hashed_email: string; // original AES-GCM encrypted value (base64url-encoded)
  source: string; // 'revolve'
  sex: '3' | '4'; // '3' = Male (Generous), '4' = Female (Attractive)
  gender_preference: string[]; // ['248'] or ['249'] — API preference IDs
  dob: number; // Unix timestamp (seconds) — NOT ISO string
  account_type: '1' | '2'; // '1' = Generous, '2' = Attractive
}
```

### Cookie Injection for Test Environments

```javascript
// Step 1: Extract root domain
const parts = new URL(TEST_ENV_URL).hostname.split('.');
const cookieDomain = '.' + parts.slice(-2).join('.');

// Step 2: Build payload per user type
function buildRevolveCookie(userType, email) {
  const isAttractive = userType === 'attractive';
  return {
    submission_uid: crypto.randomUUID(),
    campaign: 'revolve_festival_2026',
    email: email,
    hashed_email: 'test_hashed_' + Date.now(), // any non-empty string for test
    source: 'revolve',
    sex: isAttractive ? '4' : '3',
    gender_preference: isAttractive ? ['248', '249'] : ['248', '249'],
    dob: 946684800, // 2000-01-01 (25+ years old)
    account_type: isAttractive ? '2' : '1',
  };
}

// Step 3: Set cookie — use longer TTL for testing (production is 5 min)
const payload = btoa(
  JSON.stringify(
    buildRevolveCookie(
      'attractive',
      'khan+revolve' + Date.now() + '@incube8.sg',
    ),
  ),
);
const expires = new Date(Date.now() + 3600000).toUTCString(); // 1 hour for test
document.cookie = `_join_inputValues=${payload}; expires=${expires}; domain=${cookieDomain}; path=/; SameSite=Lax`;
```

### Critical Cookie Rules

1. **Set BEFORE visiting `/join`** — cookie detection fires on page load only
2. **`submission_uid` MUST be a real UUID** — `Str::isUuid()` on BE rejects non-UUID values
3. **DOB as Unix timestamp** — ISO string `"1999-03-15"` causes spinbutton format error
4. **`sex` is `"3"` or `"4"`** — NOT `"male"` / `"female"`
5. **Cookie is consumed on `/join` load** — FE removes it after parsing (`removeCookie('_join_inputValues', 1, 's')`)
6. **Fresh email every time** — BE caches `email_exists:{profile_id}` for 1 hour; reused email triggers `not_eligible`
7. **No additional campaign cookies needed** — unlike the v1 skeleton, the `_join_inputValues` cookie is the ONLY cookie required. The `revolve_campaign`, `revolve_ref`, and `campaign_source` cookies from v1 were guesses and are NOT part of the production CF Worker.

---

## Revolve Modal Names

```typescript
const REVOLVE_MODAL_NAMES = {
  WELCOME: 'welcome', // New member — offer redeemed
  WELCOME_EXTENSION: 'welcome_extension', // Existing member — package extended
  NOT_ELIGIBLE: 'not_eligible', // Diamond member or expired offer
  PROFILE_COMPLETED: 'profile_completed', // IPCF done, pending approval
  OFFER_PENDING_APPROVAL: 'offer_pending_approval', // On /billing/memberships only
} as const;
```

### BUC vs Revolve Modal Mapping

| BUC Modal                     | Revolve Equivalent       | Key Difference                                                      |
| ----------------------------- | ------------------------ | ------------------------------------------------------------------- |
| `gold_redemption_successful`  | `welcome`                | Revolve uses package_name (gold/platinum) instead of hardcoded gold |
| `gold_redemption_extended`    | `welcome_extension`      | Same concept — existing member gets extension                       |
| `boost_redemption_successful` | `welcome` (Generous)     | Revolve gives Platinum to Generous, not boosts                      |
| `not_eligible`                | `not_eligible`           | Same behaviour                                                      |
| `profile_completed`           | `profile_completed`      | Same behaviour                                                      |
| `offer_pending_approval`      | `offer_pending_approval` | Same behaviour, split by Gold/Platinum                              |
| `offer_expired`               | N/A                      | Not in Revolve scope (controlled by BE)                             |

---

## Gift Configuration (Revolve vs BUC)

### BUC Gifts (for reference)

| User Type  | Gift                             |
| ---------- | -------------------------------- |
| Attractive | 90-day premium Gold subscription |
| Generous   | 3 boosts                         |

### Revolve Gifts

| User Type  | Lock-in Window                 | Package  | Duration                  |
| ---------- | ------------------------------ | -------- | ------------------------- |
| Attractive | Apr 11 00:00 – Apr 12 23:59 PT | Gold     | Lifetime (`duration: -1`) |
| Attractive | After Apr 12 23:59 PT          | Gold     | 1 Year (`duration: 365`)  |
| Generous   | Apr 11 00:00 – Apr 12 23:59 PT | Platinum | 1 Year (`duration: 365`)  |
| Generous   | After Apr 12 23:59 PT          | Platinum | 3 Months (`duration: 90`) |

> FE does NOT decide the tier — BE returns `duration` and `package_name` in `campaign_modal`. FE just renders what it receives.

---

## Enrollment Payload (FE → BE)

When the `/campaign` route mounts for authenticated users:

```typescript
// CampaignEnrollPage reads cookie and calls BE
const cookieData = detectCampaignCookie();
enrollUserInCampaign({
  source: cookieData.source, // 'revolve'
  submission_uid: cookieData.submission_uid, // UUID from cookie
  email: cookieData.email, // plaintext email from cookie
  hashed_email: cookieData.hashed_email, // encrypted email from cookie
});
```

---

## Verification Table

### Stage 5 — Business Logic Verification

| AC    | Modal                    | User Type             | Package  | Duration | Precondition               | Trigger                          | Test Method   | Figma        |
| ----- | ------------------------ | --------------------- | -------- | -------- | -------------------------- | -------------------------------- | ------------- | ------------ |
| AC-5  | `welcome`                | Attractive            | Gold     | Lifetime | New, approved + liveness   | Page load after approval         | Full UI       | `2199-18163` |
| AC-6  | `welcome`                | Attractive            | Gold     | 1 Year   | New, approved + liveness   | Page load after approval         | Factory       | `2378-17574` |
| AC-7  | `welcome`                | Generous              | Platinum | 1 Year   | New, approved + liveness   | Page load after approval         | Factory       | `2199-18163` |
| AC-8  | `welcome`                | Generous              | Platinum | 3 Months | New, approved + liveness   | Page load after approval         | Full UI       | `2378-17686` |
| AC-9  | `welcome_extension`      | Attractive            | Gold     | Lifetime | Existing, has Gold         | Login via Revolve CTA            | Existing user | `2378-17630` |
| AC-10 | `welcome_extension`      | Attractive            | Gold     | 1 Year   | Existing, has Gold         | Login via Revolve CTA            | Factory       | `2453-13934` |
| AC-11 | `welcome_extension`      | Generous              | Platinum | 1 Year   | Existing, has Platinum     | Login via Revolve CTA            | Factory       | `2378-17743` |
| AC-12 | `welcome_extension`      | Generous              | Platinum | 3 Months | Existing, has Platinum     | Login via Revolve CTA            | Factory       | `2378-17800` |
| AC-13 | `offer_pending_approval` | Attractive            | Gold     | —        | Enrolled, pending          | `/billing/memberships`           | Factory       | `2742-12568` |
| AC-14 | `offer_pending_approval` | Generous              | Platinum | —        | Enrolled, pending          | `/billing/memberships`           | Factory       | `2742-12666` |
| AC-15 | `not_eligible`           | Any (Diamond/expired) | —        | —        | Diamond member or expired  | Cookie + `/member`               | Existing user | `2179-11372` |
| AC-16 | `profile_completed`      | Any enrolled          | —        | —        | IPCF done, pending         | "View members" on IPCF last page | Full UI       | `2736-12343` |
| AC-17 | `CampaignInfoModal`      | Any new enrolled      | —        | —        | Cookie before registration | Appears during IPCF              | Full UI       | `2736-12447` |
| AC-18 | Thank you page           | Any enrolled          | —        | —        | Liveness/selfie complete   | After verification               | Full UI       | `2749-10732` |

---

## Test User Matrix

### Full UI Flow (3 users)

| #   | Email Pattern                                            | Type             | Sex | Account Type | Covers                    |
| --- | -------------------------------------------------------- | ---------------- | --- | ------------ | ------------------------- |
| 1   | `khan+revolve_attr_<ts>@incube8.sg`                      | Attractive (new) | `4` | `2`          | AC-5, AC-16, AC-17, AC-18 |
| 2   | `khan+revolve_gen_<ts>@incube8.sg`                       | Generous (new)   | `3` | `1`          | AC-8, AC-16, AC-17, AC-18 |
| 3   | Standing account or `khan+revolve_exist_<ts>@incube8.sg` | Existing (any)   | —   | —            | AC-9, AC-15               |

### Factory Users (7 users — skip onboarding)

| #   | Type                              | State Required                     | Covers |
| --- | --------------------------------- | ---------------------------------- | ------ |
| 4   | Attractive, approved + liveness   | Enrolled, Gold offer (365 day)     | AC-6   |
| 5   | Generous, approved + liveness     | Enrolled, Platinum offer (365 day) | AC-7   |
| 6   | Attractive, existing + Gold sub   | Enrolled, Gold extension           | AC-10  |
| 7   | Generous, existing + Platinum sub | Enrolled, Platinum extension (365) | AC-11  |
| 8   | Generous, existing + Platinum sub | Enrolled, Platinum extension (90)  | AC-12  |
| 9   | Attractive, enrolled, pending     | On `/billing/memberships`          | AC-13  |
| 10  | Generous, enrolled, pending       | On `/billing/memberships`          | AC-14  |

---

## Factory Protocol (API-based user creation)

> Use this for factory-marked ACs. Full UI flow users MUST go through registration (Stage 3 setup protocol).

### Step 1: Register user via API (or use standing account)

For new users that need enrollment:

```
1. Navigate to /login (set cookie domain)
2. Set _join_inputValues cookie with full Revolve payload
3. Navigate to /join — complete registration (this is the ONE UI registration per type)
4. After registration, subsequent factory users for the same type can reuse the standing account pattern
```

For existing users that need a subscription:

```
1. Use standing account or create via full flow once
2. Use QA API to create subscription:
   GET /v3/users/{uid}/create-grandfathered-subscription
   (coordinate with BE on subscription type/duration params)
3. Set _join_inputValues cookie
4. Enroll via /campaign route or direct API
```

### Step 2: Advance to required state

```javascript
// Simulate liveness FIRST (mandatory order)
// POST /v3/liveness/qa-callback?is_metadata=0
// Body: { uid: "<uid>", recommendation: "APPROVE" }

// THEN force-approve
// GET /v3/users/<uid>/force-approve-profile

// Wait 5 seconds — BE processes asynchronously
// Refresh page — modals fire on next authenticated page load
```

### Step 3: Verify modal

Navigate to the correct route for the target modal:

- `welcome` / `welcome_extension` / `profile_completed` → `/member` (or click "View members" from IPCF)
- `offer_pending_approval` → `/billing/memberships`
- `not_eligible` → `/member` (with cookie set)

---

## Setup Rules (inherited from BUC, confirmed for Revolve)

1. **Liveness → Approval order**: Simulate liveness FIRST, then force-approve. Wrong order prevents gift issuance.
2. **"View members" navigation**: Click "View members" on IPCF last page for first modal. Do NOT hard-navigate to `/member`.
3. **`offer_pending_approval` route guard**: FE-enforced — only renders on `/billing/memberships`.
4. **`force_verify_email` bypass**: After registration, remove `localStorage.removeItem('force_verify_email')` before checking modals.
5. **Cookie refresh**: After setting cookie via `document.cookie`, refresh the page before proceeding.
6. **Scenario isolation**: Clear ALL cookies, localStorage, sessionStorage at start of EVERY scenario.

---

## Figma Node-ID Quick Reference

| Modal                  | Variant                  | Node ID      |
| ---------------------- | ------------------------ | ------------ |
| welcome                | Attractive Gold Lifetime | `2199-18163` |
| welcome                | Attractive Gold 1yr      | `2378-17574` |
| welcome                | Generous Platinum 1yr    | `2199-18163` |
| welcome                | Generous Platinum 3mo    | `2378-17686` |
| welcome_extension      | Attractive Gold Lifetime | `2378-17630` |
| welcome_extension      | Attractive Gold 1yr      | `2453-13934` |
| welcome_extension      | Generous Platinum 1yr    | `2378-17743` |
| welcome_extension      | Generous Platinum 3mo    | `2378-17800` |
| offer_pending_approval | Attractive Gold          | `2742-12568` |
| offer_pending_approval | Generous Platinum        | `2742-12666` |
| not_eligible           | Any                      | `2179-11372` |
| profile_completed      | Any                      | `2736-12343` |
| CampaignInfoModal      | Any                      | `2736-12447` |
| Thank you page         | Any                      | `2749-10732` |

---

## Report Header

When this campaign is active, add to verification report:

```markdown
**Campaign**: Revolve Festival 2026
**Campaign Key**: `revolve_festival_2026`
**Cookie**: `_join_inputValues` (base64 JSON with `campaign`, `email`, `hashed_email`, `source`, `submission_uid`)
**Entry URL**: <URL used>
**Skill Version**: 2026-03-25
```

---

## Known Limitations

- `offer_expired`: No QA endpoint to expire a `MembershipOffer` — not testable on testqa (same as BUC)
- Time-window testing (Lifetime vs 1yr): FE cannot control this — BE decides based on `locked_in_at` timestamp. To test both tiers, BE must set the appropriate `duration` in the `campaign_modal` payload.
- Diamond member `not_eligible`: Requires a user with active Diamond subscription. Use `create-grandfathered-subscription` QA endpoint to set up.

---

## Changelog

| Date       | Version | Changes                                                                                                                                                                                                       |
| ---------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-03-25 | v2      | Full rewrite. Production cookie shape with `hashed_email`. Revolve modal names. Verification table. Factory protocol. Removed v1 guessed cookie names (`revolve_campaign`, `revolve_ref`, `campaign_source`). |
| 2026-03-15 | v1      | Initial skeleton. Cookie names guessed from Confluence.                                                                                                                                                       |
