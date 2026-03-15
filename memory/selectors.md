# Page Selectors & Navigation Map

> This file is loaded before any browser interaction. Use these selectors instead of scanning the FE codebase.
> Updated automatically from verification runs. Manual corrections welcome.

## How This File Works

1. Before interacting with any page element, check this file first
2. If the selector exists here, use it directly — do NOT scan FE source
3. If the selector is NOT here, scan FE source, find it, use it, then ADD it to this file
4. For default values: if a field already has a valid selection and the test plan doesn't require a specific value, click Continue immediately without interacting with the field

## Join Page (/join)

| Element | Selector | Default Value | Notes |
|---------|----------|---------------|-------|
| Gender - Man | `[data-testid="gender-man"]` or button containing "Man" | — | Click to select |
| Gender - Woman | `[data-testid="gender-woman"]` or button containing "Woman" | — | Click to select |
| Interest - Women | button containing "Women" | — | |
| Interest - Men | button containing "Men" | — | |
| Continue button | `[data-testid="join-continue"]` or button containing "Continue" | — | Disabled until selections made |
| DOB Month | date picker month input | — | |
| DOB Day | date picker day input | — | |
| DOB Year | date picker year input | — | |
| Email input | `input[name="email"]` or `[data-testid="email-input"]` | — | |
| OTP input | `input[name="otp"]` or OTP digit inputs | "000000" | Test env mock code |

## IPCF Steps

| Step | Element | Selector | Default Action | Notes |
|------|---------|----------|----------------|-------|
| Nickname | Text input | `input[name="nickname"]` | Enter testpilot_<ts> | Must be unique |
| Location | Autocomplete input | `input[name="location"]` or location search input | Type "Sydney", select first | Wait for dropdown |
| Height | Dropdown | height select/dropdown | **FAST PATH**: if any value selected → Continue | Any value works |
| Weight | Dropdown | weight select/dropdown | **FAST PATH**: if any value selected → Continue | Any value works |
| Ethnicity | Dropdown | ethnicity select | **FAST PATH**: if any value selected → Continue | Any value works |
| Education | Dropdown | education select | **FAST PATH**: if any value selected → Continue | Any value works |
| Relationship | Dropdown | relationship select | Select "Single" | Specific value needed |
| Children | Dropdown | children select | **FAST PATH**: if any value selected → Continue | Any value works |
| Smoking | Dropdown | smoking select | **FAST PATH**: if any value selected → Continue | Any value works |
| Drinking | Dropdown | drinking select | **FAST PATH**: if any value selected → Continue | Any value works |
| Tags | Tag buttons | `.tag-option` or tag button elements | Click first available tag | Min 1 required |
| Looking For | Textarea | `textarea[name="lookingFor"]` | Skip if possible, else enter 50+ chars | |
| Photo Upload | File input | `input[type="file"]` | Upload testdata/profile-photo-test.jpg | |
| Heading | Text input | `input[name="heading"]` | "TestPilot Verification Account" | 4-50 chars |
| About Me | Textarea | `textarea[name="aboutMe"]` | 50+ char placeholder | |
| Selfie | — | — | **URL BYPASS**: append `?qaSimulateLiveness=APPROVE` to current URL at selfie step | No camera interaction needed |
| Continue (generic) | Button | button containing "Continue" or "Next" | — | Present on most steps |

## Admin Panel

| Element | Selector | Notes |
|---------|----------|-------|
| Login email | `input[name="email"]` or `#email` | |
| Login password | `input[name="password"]` or `#password` | |
| Login button | `button[type="submit"]` or button containing "Login" | |
| User search | search input in user management | |
| Approve button | button containing "Approve" or approve action | |

## Campaign Modals

| Modal | testid | Heading Text | Dismiss Action |
|-------|--------|-------------|----------------|
| CampaignInfoModal | `campaign-notice-modal` | "Your offer is just steps away" | Click Continue |
| not_eligible | — | "Not eligible for this offer" | Click Continue (removes cookie) |
| profile_completed | — | varies by campaign | Click action button |
| offer_pending_approval | — | varies | FE route guard: /billing/memberships only |

## QA API Endpoints (frequently used)

| Action | Method | Endpoint |
|--------|--------|----------|
| Force approve | GET | `v3/users/{uid}/force-approve-profile` |
| Delete member | DELETE | `v3/users/{uid}` |
| Simulate liveness | POST | `v3/liveness/qa-callback?is_metadata=0` |
| Clear liveness | POST | `v3/liveness/qa-delete-all-association?is_metadata=0` |
| Set trusted | POST | `v3/liveness/qa-set-trusted-member` |

## Known Working Email Domains

| Format | Use For | Notes |
|--------|---------|-------|
| `khan+attr<timestamp>@incube8.sg` | Attractive (Female) users | Verified working on testqa |
| `khan+gen<timestamp>@incube8.sg` | Generous (Male) users | Verified working on testqa |
| `testpilot_<timestamp>@seeking-test.com` | Generic users | ⚠️ Returns 400 on testqa — DO NOT USE for campaign tests |

> **NOTE**: All selectors above are initial best guesses from the first verification runs.
> After each run, update any incorrect selectors. Mark selectors as VERIFIED after confirmation.
> Selectors marked with "FAST PATH" mean: if a value is already selected, skip interaction and click Continue.
