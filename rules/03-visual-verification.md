# Stage 4: Visual Verification

> Before starting any setup step, load `memory/selectors.md` for known page selectors and default actions.
> If a selector from memory works, use it. Only scan FE source if the selector fails or is missing.

This stage compares the rendered UI against Figma design specs with exact CSS property values.

**Figma is the source of truth for visual verification.**
A failing visual check is a FAIL regardless of "it looks close enough" reasoning.

---

## 4.1 — Capture Figma Specs

For each element identified in the test plan, extract from Figma:

### CSS Properties to Extract (always check these)

| Property | How to Extract from Figma | Example |
|----------|--------------------------|---------|
| `font-family` | Text layer → Typography | "Graphik, sans-serif" |
| `font-size` | Text layer → Typography | "16px" |
| `font-weight` | Text layer → Typography | "400", "600", "700" |
| `line-height` | Text layer → Typography | "24px" or "1.5" |
| `color` (text) | Text layer → Fill color | "#1A1A1A" |
| `background-color` | Frame/rect → Fill color | "#FFFFFF" or "rgba(0,0,0,0.5)" |
| `border-radius` | Layer → Corner radius | "8px" |
| `border` | Layer → Stroke | "1px solid #E0E0E0" |
| `padding` | Auto-layout frame → Padding | "16px 24px" |
| `gap` | Auto-layout frame → Gap | "12px" |
| `width` | Layer dimensions | "320px" or "100%" |
| `height` | Layer dimensions | "48px" |
| `opacity` | Layer → Opacity | "0.5" |
| `box-shadow` | Effects → Drop shadow | "0 2px 8px rgba(0,0,0,0.1)" |
| `letter-spacing` | Text layer → Letter spacing | "0.02em" |

### Figma MCP Call Pattern

```
get_design_context(fileKey: "<key>", nodeId: "<frame_node_id>")
```

The response includes computed styles. Record them in a table:

```markdown
### Figma Specs — <Component Name>
| Property | Figma Value |
|----------|------------|
| font-size | 16px |
| color | #1A1A1A |
| background-color | #FFFFFF |
| padding | 16px 24px |
| border-radius | 8px |
```

---

## 4.2 — Extract Rendered CSS from Browser

For each element, extract the computed styles from the live test environment.

### Method: Browser DevTools / Playwright

Target the element using the most specific stable selector:

```javascript
// Preferred: data attribute or semantic selector
const el = document.querySelector('[data-testid="feature-button"]');
// Fallback: class-based (less stable)
const el = document.querySelector('.feature-button');

// Extract computed styles
const styles = window.getComputedStyle(el);
const report = {
  fontFamily: styles.fontFamily,
  fontSize: styles.fontSize,
  fontWeight: styles.fontWeight,
  lineHeight: styles.lineHeight,
  color: styles.color,
  backgroundColor: styles.backgroundColor,
  borderRadius: styles.borderRadius,
  padding: styles.padding,
  // etc.
};
console.log(JSON.stringify(report, null, 2));
```

### Color Format Normalization

Browser returns `rgb(26, 26, 26)` — convert to hex for comparison:
```javascript
function rgbToHex(rgb) {
  const [r, g, b] = rgb.match(/\d+/g).map(Number);
  return '#' + [r, g, b].map(n => n.toString(16).padStart(2, '0')).join('').toUpperCase();
}
```

Record browser values in the same table format:

```markdown
### Browser Computed Styles — <Component Name>
| Property | Browser Value | Hex (if color) |
|----------|--------------|----------------|
| font-size | 16px | — |
| color | rgb(26, 26, 26) | #1A1A1A |
```

---

## 4.3 — Compare Figma vs Browser

Compare each property. Use this tolerance guide:

| Property Type | Tolerance | Notes |
|--------------|-----------|-------|
| Font size | ±0px | Exact match required |
| Font weight | ±0 | Exact match required |
| Color | ±0 (hex comparison) | Convert rgb→hex, exact match |
| Padding/Margin | ±2px | Subpixel rendering allowed |
| Border radius | ±1px | Rounding allowed |
| Line height | ±1px | Computed vs unitless conversion |
| Width (fluid) | N/A | Skip fluid widths |
| Width (fixed) | ±2px | Scrollbar width can affect |
| Box shadow | ±0 | Exact match on values |

### Comparison Output

```markdown
### Visual Comparison: <Component Name>
| Property | Figma | Browser | Status | Notes |
|----------|-------|---------|--------|-------|
| font-size | 16px | 16px | ✅ PASS | |
| color | #1A1A1A | #1A1A1A | ✅ PASS | |
| background-color | #FFFFFF | #F5F5F5 | ❌ FAIL | Off by one shade |
| padding | 16px 24px | 16px 20px | ❌ FAIL | Right padding 4px short |
| border-radius | 8px | 8px | ✅ PASS | |
```

---

## 4.4 — Screenshot Evidence

For every visual check, capture:

1. **Figma screenshot** — from `get_screenshot` MCP call
2. **Browser screenshot** — full element screenshot
3. **Overlay/comparison** — if tooling allows, side-by-side

Save screenshots to: `reports/screenshots/<timestamp>-<element-name>-figma.png`
and `reports/screenshots/<timestamp>-<element-name>-browser.png`

Reference both in the verification report.

---

## 4.5 — Element States to Check

For each interactive element, check all relevant states:

| State | How to Trigger |
|-------|---------------|
| **Default** | Page load, no interaction |
| **Hover** | `element.dispatchEvent(new MouseEvent('mouseover'))` |
| **Active** | Click and hold |
| **Focus** | `element.focus()` |
| **Disabled** | Check if disabled prop present |
| **Error** | Submit form with invalid data |
| **Loading** | Trigger async action, capture mid-load |
| **Empty** | Render with no content |

Only check states explicitly shown in Figma. Do not invent states not designed.

---

## 4.6 — Visual Check Confidence Levels

| Confidence | When to Apply |
|-----------|--------------|
| **HIGH** | Exact CSS property match, screenshot confirms |
| **MEDIUM** | Property matches but screenshot comparison was manual/subjective |
| **LOW** | Could not extract exact CSS value — visual estimate only |
| **INCONCLUSIVE** | Element not found in DOM / Figma spec missing |

---

## 4.7 — Common Failure Patterns

### "Element not found in DOM"
```
IF target element not found with expected selector:
  → Check if element exists with a different selector (search by text content)
  → Check if element is conditionally rendered (may require a specific app state)
  → Note: "Element absent from DOM — expected to be present based on Figma"
  → Status: FAIL (element absence when Figma shows it present is a bug)
```

### "Color close but not matching"
```
IF color difference is <= 5% lightness:
  → Report as FAIL with note: "Minor color deviation — may be intentional"
  → Confidence: MEDIUM
  → Recommend designer review
```

### "Figma uses design tokens"
```
IF Figma shows a token name (e.g., "color/primary/500") instead of hex:
  → Look up token in Figma variable definitions:
    get_variable_defs(fileKey: "<key>")
  → Resolve token to hex value
  → Then compare
```

### "CSS value uses calc() or CSS variable"
```
IF browser computed style returns a CSS variable (--token-name):
  → Evaluate: getComputedStyle(el).getPropertyValue('--token-name')
  → Resolve to actual computed value
  → Compare resolved value against Figma
```

---

## 4.8 — What NOT to Check

Do not perform visual verification on:
- Dynamically generated content (user names, dates, counts)
- Third-party embed components (maps, payment widgets)
- Animation timing/easing (unless explicitly in Figma prototype)
- Font rendering differences across OS (anti-aliasing)

Mark these as `N/A — Dynamic or third-party content`.

---

## 4.9 — Visual Verification Summary

After completing all visual checks, produce a summary:

```markdown
### Visual Verification Summary
- Total checks: X
- PASS: X
- FAIL: X
- INCONCLUSIVE: X

#### Failed Checks
| Element | Property | Figma | Browser | Impact |
|---------|----------|-------|---------|--------|
| Button | background-color | #007AFF | #0A84FF | Medium |
```

Include this summary in Stage 7 (Report).
