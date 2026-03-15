---
name: Cookie field names must come from FE source
description: Exact _join_inputValues field names and formats sourced from FE — never guess from Confluence
type: feedback
---

Always use these verified field names when setting `_join_inputValues` for form auto-population tests.

**Why:** Confluence Req.4 lists conceptual names. Actual JS field names differ. Guessing caused a false FAIL on form auto-population.

**Source**: `FE_REPO/resources/react-app/components/auth/utils.tsx` lines 276–417 (`validateBUCCookie`)

## Correct Field Names

| Field | Type | Valid Values |
|-------|------|-------------|
| `submission_uid` | string | Real UUID (`crypto.randomUUID()`) |
| `sex` | string | `"3"` = Male, `"4"` = Female (API attribute ID — NOT "male"/"female") |
| `gender_preference` | string[] | Array of API preference IDs, or `"999"` for Everyone |
| `email` | string | RFC email format |
| `dob` | number | Unix timestamp in seconds (e.g. `946684800` for 2000-01-01) |
| `bdayDay` | string | `"1"`–`"31"` (fallback if `dob` absent) |
| `bdayMonth` | string | `"1"`–`"12"` (fallback if `dob` absent) |
| `bdayYear` | string | 4-digit year (fallback if `dob` absent) |
| `account_type` | string | `"1"` or `"2"` — auto-derived from `sex` if omitted |

## DOB Format
- ✅ Unix timestamp (seconds): `946684800`
- ✅ `"MM/DD/YYYY"` or `"DD/MM/YYYY"` (format depends on IP country)
- ❌ ISO string `"1999-03-15"` — rejected by FE spinbutton with format error

## Auto-Population Behaviour
Full cookie on `/join` first load → FE skips steps with valid data → form opens at Step 3 (email) if all fields valid.

**How to apply:** Before testing Req.4 form pre-population, use the field names above. Do not derive field names from Confluence spec alone.
