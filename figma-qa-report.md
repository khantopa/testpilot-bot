# Visual QA Report — Revolve Festival Modal
**Date:** 2026-03-19
**Figma Source:** https://www.figma.com/design/B3hUqXpKfPnFE6e7ICIprZ/SAPD-0267-Revolve-Festival-Components?node-id=2124-7375&m=dev
**Test URL:** http://localhost:8080/member
**Viewport:** 390×844 (Mobile)

---

## Summary
- **Total Issues Found:** 10
- **Critical:** 3 | **Major:** 5 | **Minor:** 2
- **Overall Match Score:** ~65%

---

## Critical Issues
> Issues that break layout, readability, or significantly deviate from design

### 1. Gold Tag Background Color Completely Wrong
- **Element:** `.css-of2wss` (Gold tag badge)
- **Property:** `background-color`
- **Figma Value:** `#e0aba1` (rose/dusty pink)
- **Live Value:** `rgb(82, 93, 103)` / `#525D67` (dark grey)
- **Deviation:** Entirely different color — grey vs pink
- **Suggested Fix:** Change `background-color` from `#525D67` to `#e0aba1` on the Gold tag component

### 2. Gold Tag Text Color Wrong
- **Element:** `.css-of2wss` (Gold tag badge)
- **Property:** `color`
- **Figma Value:** `white` / `#FFFFFF`
- **Live Value:** `rgb(230, 232, 233)` / `#E6E8E9`
- **Deviation:** Off-white instead of pure white
- **Suggested Fix:** Change `color` to `#FFFFFF` on the Gold tag

### 3. Gold Tag Padding Mismatch
- **Element:** `.css-of2wss` (Gold tag badge)
- **Property:** `padding`
- **Figma Value:** `8px 12px` (vertical 8px, horizontal 12px)
- **Live Value:** `2px 8px`
- **Deviation:** Vertical padding 2px vs 8px (-6px), horizontal padding 8px vs 12px (-4px)
- **Suggested Fix:** Change `padding` from `2px 8px` to `8px 12px`

---

## Major Issues
> Noticeable visual differences that affect design fidelity

### 4. Heading Text Content Differs
- **Element:** `h2` (`.css-3xod6v`)
- **Property:** Text content
- **Figma Value:** "Welcome to Seeking!"
- **Live Value:** "Lucky you!"
- **Deviation:** Different heading copy
- **Suggested Fix:** Update heading text to "Welcome to Seeking!" — or confirm with design if "Lucky you!" is the intended copy for this variant

### 5. Body Text Content & Color Differ
- **Element:** `p.css-1j6i1jc` (first paragraph)
- **Property:** `color` + content
- **Figma Value:** Color `#081726`, text: "You signed up with Seeking at Revolve Festival '26, so we unlocked something special for you: **Gold subscription** *for life!*"
- **Live Value:** Color `rgb(82, 93, 103)` / `#525D67`, text: "Because you signed up with Seeking at Revolve Festival '26, you've unlocked the special influencer badge and received a subscription for life!"
- **Deviation:** Body text color is `#525D67` (grey) instead of `#081726` (dark navy). Copy also differs.
- **Suggested Fix:** Change body paragraph `color` to `#081726`. Verify copy with design/product.

### 6. Benefits Label Text & Styling Differ
- **Element:** `p.css-1j6i1jc` (second paragraph — benefits intro)
- **Property:** Content + font-weight of "Gold"
- **Figma Value:** "Your exclusive **Gold** benefits include:" with "Gold" at `font-weight: 500` (Medium)
- **Live Value:** "Enjoy the full **Gold** experience:" with "Gold" at `font-weight: 700` (Bold)
- **Deviation:** Different copy. "Gold" is Bold (700) instead of Medium (500)
- **Suggested Fix:** Change `<strong>` to `<span>` with `font-weight: 500` for "Gold". Update copy to match Figma.

### 7. Modal Width Should Be 90% on Mobile (Not 100%)
- **Element:** `.css-1e2y5pa` (modal content panel)
- **Property:** `width`
- **Figma Value:** 90% of viewport width (per spec requirement: modal should be 90% width on mobile). Figma frame shows content at 343px in 375px frame = ~91.5%
- **Live Value:** `390px` (100% of 390px viewport)
- **Deviation:** Modal takes full viewport width instead of ~90%
- **Suggested Fix:** Set `width: 90%` or `max-width: 90vw` on the modal panel, and center it horizontally. Alternatively, add `margin: 0 auto` with the width constraint.

### 8. Modal Bottom Padding Mismatch
- **Element:** `.css-1e2y5pa` (modal content panel)
- **Property:** `padding-bottom`
- **Figma Value:** `32px` (Figma shows `pb-[var(--spacing/xxl,32px)]`)
- **Live Value:** `24px`
- **Deviation:** -8px
- **Suggested Fix:** Change `padding-bottom` from `24px` to `32px`

---

## Minor Issues
> Small deviations within near-tolerance range

### 9. Feature Benefit Text Wording Differences
- **Element:** Feature list items (checkmark rows)
- **Property:** Text content
- **Figma Values:**
  1. "Greater visibility and attention with a Gold badge"
  2. "See when the messages you send are read"
  3. "Set multiple locations and date in more cities"
  4. "Enhanced privacy controls to manage what others see"
  5. "Unlock an exclusive influencer badge that elevates your profile"
- **Live Values:**
  1. "Stand out with special Gold membership badges so people know who you are"
  2. "Get read receipts on your messages"
  3. "Set multiple locations and be shown in more cities"
  4. "Unlock advanced privacy controls"
  5. "Organize connections with private notes"
- **Deviation:** All 5 benefit items have different wording. Items convey similar concepts but copy is not aligned.
- **Suggested Fix:** Verify with product/design which copy is authoritative and update FE accordingly.

### 10. Close Button Margin-Bottom
- **Element:** `.css-7dw8gd` (close button container)
- **Property:** `margin-bottom`
- **Figma Value:** The Heading bar has `padding: 24px 16px` (24px top/bottom, 16px sides), then Content starts at `top: 68.5px`
- **Live Value:** `margin-bottom: 24px` on close container
- **Deviation:** Within tolerance — spacing is approximately correct. The Figma uses absolute positioning while live uses flex flow, so the visual result is similar.
- **Suggested Fix:** No fix needed — spacing is functionally equivalent.

---

## Passed Checks
> Properties that match Figma spec within tolerance

- **H2 heading**: font-family ✅ (`IvyPresto_Headline`), font-size ✅ (`24px`), font-weight ✅ (`300`), line-height ✅ (`31px`), color ✅ (`#081726`)
- **Hero image area**: height ✅ (`160px`), width ✅ (full content width)
- **Feature text**: font-size ✅ (`14px`), line-height ✅ (`19px`), color ✅ (`#5b636c`)
- **Features container**: gap ✅ (`12px`), padding-left/right ✅ (`8px`)
- **CTA button**: background-color ✅ (`#ff4a4a`), border-radius ✅ (`100px`), height ✅ (`48px`), full-width ✅, font-size ✅ (`16px`), font-weight ✅ (`500`), text-color ✅ (near-white)
- **Footer text**: font-size ✅ (`14px`), line-height ✅ (`19px`), color ✅ (`#5b636c`), underline on link ✅
- **"for life!" text**: font-family ✅ (`Indivisible:SemiBold_Italic`), color ✅ (`#ff4a4a`)
- **Modal container**: border-radius ✅ (`2px 2px 0 0`), background-color ✅ (`white`), overflow-y ✅ (`auto` — scrollable)
- **Modal panel padding**: padding-top ✅ (`16px`), padding-left/right ✅ (`16px`)

---

## Screenshots
- Figma Reference: (embedded in Figma MCP response — node 2124:7375)
- Live Captured (viewport): `screenshots/revolve-modal/live-modal-mobile.png`
- Live Captured (full page): `screenshots/revolve-modal/live-modal-fullpage.png`

---

## FE Source Files

All fixes should be made in the FE repo (`/Users/khantopa/dev/sa-v3`):

| File | Purpose |
|------|---------|
| `resources/react-app/modules/Campaign/CampaignModal.tsx` | Main modal component — layout, padding, width |
| `resources/react-app/modules/Campaign/utils.tsx` | `getRevolveModalContent()` — heading, body, benefits copy |
| `resources/react-app/modules/Campaign/HeroImageArea.tsx` | Hero image + tier badge rendering |
| `resources/react-app/modules/Campaign/types.ts` | Type definitions |

### Key `data-testid` Selectors

| Selector | Element |
|----------|---------|
| `data-testid="campaign-modal-welcome"` | Modal overlay container |
| `data-testid="revolve-tier-badge"` | Gold tag badge |
| `data-testid="revolve-hero-image-area"` | Hero image area |
| `data-testid="revolve-feature-item"` | Each benefit row (×5) |
| `data-testid="revolve-duration-phrase"` | "for life!" italic text |
| `data-testid="campaign-modal-action-button"` | "Browse members" CTA button |
| `data-cy-button="campaign-modal-close"` | Close (X) button |

---

## Quick Fix Checklist

### CSS Fixes Applied
- [x] Add `padding: '8px 12px'` to Gold + Platinum badge `&&` overrides (`utils.tsx`)
- [x] Add Revolve body text color override `#081726` via `revolveMessageStyles` with `&&` (`utils.tsx`)
- [x] Change `<strong>` to `<span style={{ fontWeight: 500 }}>` for "Gold" in benefits label (`utils.tsx`)
- [x] Set modal `maxHeight: '90% !important'` (`styles.ts` + `designTokens.ts`)
- [x] Change modal `padding-bottom` from `24px` to `32px` (`designTokens.ts`)

### Data Issue (not CSS)
- [ ] Gold tag shows Platinum styles because `package_name` from backend is not `'gold'`

### Content Changes Deferred (TODO in code)
- [ ] Verify heading/body/feature copy against Figma
