---
name: QA API Endpoints
description: All QA-only (non-production) API endpoints available on test environments for test data manipulation
type: reference
---

Source: `BE_REPO/routes/api/generated/qa-endpoints.php`

All endpoints are prefixed with the test environment base URL, e.g. `https://members-test13.seeking.com/`.
Most require `env.notProduction` middleware — not available on production.

---

## Profile Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `v3/users/{user_uid}/force-approve-profile` | Force-approve a pending profile (skips moderation) |
| GET | `v3/users/{user_uid}/force-activate-account` | Force-activate account (auth.qaAccess:1,email,1) |
| GET | `v3/users/{user_uid}/force-upgrade-profile` | Force-upgrade profile tier |
| GET | `v3/profile/deleteMember/{email}` | Delete a QA whitelisted member by email (auth.qaAccess:1,password) |
| GET | `v3/users/{profileUid}/deactivate-email` | Deactivate a user's email |
| GET | `v3/users/{profileUid}/force-logout` | Force logout a user by profileUid |
| GET | `v3/users/{profile_uid}/profile/update-created-at` | Update profile `created_at` timestamp |
| POST | `v3/users/{profile_uid}/profile/update-profile-flag` | Update a profile flag value |
| POST | `v3/clear-profile-content` | Clear all profile content |

## OTP / Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `v3/email/generate-otp` | Generate a new OTP for email verification |
| POST | `v3/sms/generate-otp` | Generate a new OTP for SMS verification |
| GET | `v3/auth/sms/get-verify-code` | Get current SMS verify code |
| POST | `v3/expire-otp-code` | Expire an OTP code |
| POST | `v3/last-activity` | Change last activity by email address |
| PUT | `v3/auth/save-password` | Save password (non-prod) |
| POST | `v3/forced-password-reset` | Force a password reset |
| GET | `v3/auth/testGetNewIpAuthenticationCode` | Get new IP authentication code |
| POST | `v3/sms/unbind-phonenumber` | Unbind phone number from account |

## Subscription Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `v3/users/{user_uid}/unsubscribe` | Unsubscribe (delete subscription) |
| GET | `v3/users/{user_uid}/changesubscriptiondate` | Change subscription date |
| POST | `v3/users/{user_uid}/create-grandfathered-subscription` | Create grandfathered subscription |
| GET | `v3/autorenew/set-renew-date-to-past-and-autocharge/{uid}` | Set renew date to past and force charge |
| GET | `v3/autorenew/expire-profile-after-auto-renew-force-charge/{uid}` | Expire profile after auto-renew force charge |
| GET | `v3/use2pay-recurring/qa-manual-control-sync` | Manual control sync for Use2Pay recurring |

## Suspension / Stick Warning

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `v3/users/{user_uid}/changesuspensiondate` | Change suspension date |
| GET | `v3/users/{user_uid}/stick-warning/change-suspension-expiry` | Change stick warning suspension expiry |

## Liveness / Selfie Verification

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `v3/liveness/qa-callback` | Simulate liveness callback |
| POST | `v3/liveness/qa-pas-requeue` | Requeue liveness for PAS |
| POST | `v3/liveness/qa-delete-association` | Delete a liveness association |
| POST | `v3/liveness/qa-delete-all-association` | Delete all liveness associations |
| POST | `v3/users/{userUid}/liveness/reset-modal-count` | Reset liveness modal count |
| POST | `v3/users/{userUid}/liveness/simulate-screen` | Simulate a liveness screen |
| POST | `v3/users/{userUid}/liveness/modify-last-modal-dismissal-time` | Modify last modal dismissal time |
| POST | `v3/liveness/qa-reset-voluntary-attempt` | Reset voluntary liveness attempt |
| POST | `v3/liveness/qa-set-trusted-member` | Set user as trusted member |
| POST | `v3/liveness/qa-update-expired-date` | Update liveness expired date |
| POST | `v3/liveness/qa-unsuspend-all-association` | Unsuspend all liveness associations |

## Photos

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `v3/delete-photos/profile/{profileid}` | Delete all photos for a profile |
| PUT | `v3/users/{user_uid}/photos/{photo_uid}/make-legacy` | Mark a photo as legacy |

## Background Check

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `v3/backgroundcheck/manual-verify/{uid}` | Manually approve background check |
| GET | `v3/backgroundcheck/manual-reject/{uid}` | Manually reject background check |
| GET | `v3/backgroundcheck/manual-expire/{uid}` | Manually expire background check |
| GET | `v3/backgroundcheck/manual-request-expire/{uid}` | Manually expire background check request |
| GET | `v3/{user_uid}/requestbackgroundreverify/advance-approved-at` | Advance background check `approved_at` |

## Age Verification

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `v3/age-verification/mock` | Generate mock age verification response |

## Boost

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `v3/users/{user_uid}/boost/force-complete-active-boost` | Force complete an active boost |

## Email Testing

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `v3/email-test-sender` | Send a test email |

## Social

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `v3/social/{platform}/unlink/{user_id}` | Unlink a social platform account |

## Remoderation

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `v3/remoderation/populate-photo-queues` | Populate photo moderation queues |
| POST | `v3/remoderation/populate-text-queues` | Populate text moderation queues |
| POST | `v3/remoderation/get-latest-recommendations` | Get latest remoderation recommendations |
| POST | `v3/remoderation/populate-moderate-recommendations` | Populate moderate recommendations |

## Site Config

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `v3/site-config/platform-config` | Get platform config |
| GET | `v3/site-config/rules-engine` | Get rules engine config |

## Data Privacy / GDPR

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `v3/users/{user_uid}/data-privacy/prepare` | Prepare data privacy export |
| GET | `v3/users/{user_uid}/data-privacy/expire` | Expire data privacy request |

## IDV / PAS

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `v3/idv-pas-queue` | Generate IDV PAS queue |

## Diamond Pin

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `v3/diamond-pin/patch` | Patch diamond pin |
| GET | `v3/diamond-pin/remove` | Remove diamond pin |

## Limited Exposure

| Method | Endpoint | Description |
|--------|----------|-------------|
| PUT | `v3/limited-exposure/update` | Update limited exposure settings |

## SNS

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `v3/sns/qa/receive` | Simulate SNS event receive |

---

## Most-Used Endpoints (Quick Reference)

```
# Force approve pending profile
GET {ENV}/v3/users/{user_uid}/force-approve-profile

# Force activate account (email verified)
GET {ENV}/v3/users/{user_uid}/force-activate-account

# Delete a QA member
GET {ENV}/v3/profile/deleteMember/{email}

# Generate email OTP
POST {ENV}/v3/email/generate-otp
Body: { "email": "..." }

# Unsubscribe
GET {ENV}/v3/users/{user_uid}/unsubscribe

# Force complete boost
GET {ENV}/v3/users/{user_uid}/boost/force-complete-active-boost

# Approve/reject/expire background check
GET {ENV}/v3/backgroundcheck/manual-verify/{uid}
GET {ENV}/v3/backgroundcheck/manual-reject/{uid}
```
