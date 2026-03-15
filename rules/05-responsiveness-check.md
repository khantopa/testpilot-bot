# Stage 6: Responsiveness Check

This stage verifies the feature layout doesn't break at standard breakpoints.

---

## 6.1 — Standard Breakpoints

Check these breakpoints unless the test plan specifies different ones:

| Name | Width | Represents |
|------|-------|-----------|
| **Mobile S** | 375px | iPhone SE, small phones |
| **Mobile L** | 428px | iPhone 14 Pro Max |
| **Tablet** | 768px | iPad portrait |
| **Desktop** | 1280px | Standard laptop |
| **Desktop L** | 1440px | Wide desktop |

Only check breakpoints where Figma has a frame or where the feature is expected to be accessible.

---

## 6.2 — Breakpoint Setup

Set browser viewport for each breakpoint:

```javascript
// Playwright
await page.setViewportSize({ width: 375, height: 812 });

// Or via browser DevTools emulation
// DevTools → Toggle device toolbar → set custom dimensions
```

After resizing:
1. Reload the page (some layouts only update on load)
2. Wait 1 second for layout to settle
3. Verify the page loaded without JS errors

---

## 6.3 — What to Check at Each Breakpoint

For each breakpoint, verify:

### Layout Integrity
- No horizontal scrollbar (except where intentional — e.g., carousel)
- No content overflowing its container
- No elements overlapping each other unexpectedly
- No text truncated when it should be visible
- No buttons/links cut off by viewport edge

```javascript
// Check for horizontal overflow
const hasHorizontalScroll = document.documentElement.scrollWidth > window.innerWidth;
```

### Key Element Visibility
- Primary CTA button visible without scrolling (or scroll needed is acceptable per design)
- Navigation/header present and functional
- Feature content (the thing being tested) is visible and interactable

### Typography Reflow
- Text doesn't overflow its container
- No single-word lines where multi-word was expected (bad line breaks)
- Font sizes match Figma mobile specs (if different from desktop)

### Responsive Images / Media
- Images don't overflow container
- Images not pixelated (ensure correct srcset is loading)

### Touch Target Size (mobile breakpoints)
- Interactive elements (buttons, links) are at least 44×44px at mobile sizes
```javascript
const el = document.querySelector('<selector>');
const rect = el.getBoundingClientRect();
const touchTargetOk = rect.width >= 44 && rect.height >= 44;
```

---

## 6.4 — Screenshot Each Breakpoint

For each breakpoint × key element combination:
1. Take a full-page screenshot
2. Take a focused element screenshot

Save as: `reports/screenshots/<timestamp>-<breakpoint>-<element>.png`

---

## 6.5 — Comparison Against Figma Responsive Frames

If Figma has mobile/tablet frames:
```
get_screenshot(fileKey: "<key>", nodeId: "<mobile_frame_node>")
```

Compare layout structure (not pixel-perfect — use structural comparison):
- Is the column count right? (e.g., 2-col desktop → 1-col mobile)
- Is the stacking order correct?
- Is navigation transformed (hamburger menu on mobile)?

---

## 6.6 — Responsiveness Check Verdicts

| Status | Criteria |
|--------|---------|
| **PASS** | Layout intact, no overflow, elements visible and interactable |
| **FAIL** | Content overflow, overlapping elements, critical elements cut off |
| **PARTIAL** | Minor issues (slight overflow, suboptimal but usable) |
| **N/A** | Breakpoint not applicable (feature is desktop-only by design) |

---

## 6.7 — Common Failure Patterns

### "Horizontal scrollbar appears on mobile"
```
→ Find the overflowing element:
  document.querySelectorAll('*').forEach(el => {
    if (el.offsetWidth > document.body.offsetWidth) console.log(el);
  });
→ Screenshot the overflowing element
→ Report: FAIL — element <X> causes horizontal overflow at <width>px
```

### "Element hidden at mobile but visible in Figma"
```
IF an element Figma shows at mobile is CSS display:none on the real page:
  → Check if this is intentional (e.g., desktop-only feature)
  → If not documented as intentional: FAIL
  → Evidence: "Figma mobile frame shows <element>. Browser computed: display: none"
```

### "Font size too small at mobile"
```
IF font-size < 12px at mobile breakpoints:
  → Automatic FAIL — iOS Safari will auto-zoom, breaking layout
  → Report: "Font size <Xpx> at 375px — below minimum 12px for mobile"
```

---

## 6.8 — Responsiveness Summary

```markdown
### Responsiveness Summary
| Breakpoint | Status | Issues Found |
|-----------|--------|-------------|
| 375px | ✅ PASS | None |
| 768px | ❌ FAIL | Navigation overlay covers content |
| 1280px | ✅ PASS | None |
| 1440px | ✅ PASS | None |
```
