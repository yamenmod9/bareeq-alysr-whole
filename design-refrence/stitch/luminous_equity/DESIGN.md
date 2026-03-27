# Design System Specification: The Architectural Pulse

## 1. Overview & Creative North Star: "The Digital Vault"
This design system is built upon the North Star of **"The Digital Vault."** In the high-stakes world of BNPL (Buy Now, Pay Later) and enterprise fintech, trust isn't built with generic templates; it is constructed through architectural precision, intentional depth, and a "high-end editorial" clarity. 

We move away from the "flat web" by embracing **Tonal Layering**. The UI should feel like a custom-machined instrument—sharp, weighted, and sophisticated. We challenge the rigid grid by utilizing intentional asymmetry in sidebar interactions and high-contrast typography scales that prioritize "Data-as-Art." This is not just a dashboard; it is a premium financial environment where every pixel denotes stability and "Financial Success."

---

## 2. Colors & Surface Philosophy
Our palette is anchored in deep, authoritative blues and slate grays, punctuated by "Success Teal" to drive action without the visual fatigue of overused purples.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to section off content. 
*   **The Execution:** Boundaries must be defined solely through background color shifts. For example, a `surface-container-low` component should sit on a `surface` background to create a "carved" or "inset" look.
*   **Surface Hierarchy:** Use the tiers (Lowest to Highest) to create physical depth.
    *   **Base:** `surface` (#f8f9ff)
    *   **De-emphasized zones:** `surface-container-low` (#eff4ff)
    *   **Interactive/Primary containers:** `surface-container` (#e5eeff)
    *   **High-prominence modals/pop-overs:** `surface-container-highest` (#d3e4fe)

### The Glass & Gradient Rule
To achieve a signature premium feel:
*   **Floating Elements:** Use `surface-container-lowest` (#ffffff) with a 60% opacity and a `20px` backdrop-blur to create a "frosted glass" effect for navigation overlays or tooltips.
*   **Signature Gradients:** For CTAs and Hero KPI cards, transition from `primary` (#000000) to `primary_container` (#131b2e) at a 135-degree angle. This adds "soul" and a sense of metallic sheen to the interface.

---

## 3. Typography: Editorial Precision
We utilize a dual-font strategy to balance character with dense data readability.

*   **Display & Headlines (Manrope):** Used for large-scale numbers and section titles. The geometric nature of Manrope feels "engineered."
    *   *Headline-LG (2rem):* For primary financial totals.
*   **Body & Labels (Inter):** The workhorse for data tables and form labels. Its high x-height ensures legibility in Arabic and English at small scales.
    *   *Body-MD (0.875rem):* The standard for data table rows.
    *   *Label-SM (0.6875rem):* Used for micro-data, always in `on_surface_variant` (#45464d).

**RTL Priority:** Typography scales must remain identical across English and Arabic. When switching to Arabic, ensure line-height is increased by 10% to accommodate script descenders without crowding the "Vault" containers.

---

## 4. Elevation & Depth
We eschew traditional drop shadows for **Ambient Tonal Layering.**

*   **The Layering Principle:** Depth is achieved by "stacking." Place a `surface-container-lowest` card (the "Sheet") on a `surface-container-low` background (the "Table"). The contrast in hex values creates the lift.
*   **Ambient Shadows:** If a floating state is required (e.g., a dragged table row), use a diffused shadow: `0px 12px 32px rgba(11, 28, 48, 0.06)`. Note the use of the `on_surface` blue tint in the shadow color rather than pure black.
*   **The "Ghost Border" Fallback:** If accessibility requires a stroke, use `outline_variant` at **15% opacity**. Never use 100% opaque borders; they shatter the editorial flow.

---

## 5. Components & Interface Rhythm

### KPI Cards (The "Financial Pulse")
*   **Style:** No borders. Use `surface-container-lowest`.
*   **Accent:** A 4px vertical "Success Stripe" using `tertiary_fixed` (#89f5e7) on the leading edge (Left for LTR, Right for RTL).
*   **Visual Rhythm:** Incorporate a subtle, low-opacity geometric pattern in the background using the `primary_fixed` color.

### Data Tables (Dense-but-Readable)
*   **Rule:** Forbid divider lines between rows.
*   **Separation:** Use a subtle background toggle. Even rows use `surface`, odd rows use `surface-container-low`.
*   **Header:** `headline-sm` typography in `on_surface_variant`. 

### Sidebar Navigation (Collapsible)
*   **Layout:** Sidebar-led with a `surface_dim` (#cbdbf5) background.
*   **Active State:** Avoid a "box" around the active link. Use a "pill" shape (`rounded-full`) that utilizes a teal-to-blue gradient at 10% opacity.

### Status Badges
*   **Success:** `tertiary_container` (#00201d) background with `on_tertiary_container` (#0c9488) text.
*   **Error:** `error_container` (#ffdad6) background with `on_error_container` (#93000a) text.

### Form Elements
*   **Input Fields:** Use `surface_container_low` for the input track. Upon focus, shift the background to `surface_container_lowest` and apply a "Ghost Border" of `primary` at 20% opacity.

---

## 6. Do’s and Don’ts

### Do
*   **Do** prioritize vertical whitespace over lines. Use `spacing.8` (1.75rem) to separate major sections.
*   **Do** align all text to the "reading start" (Left for English, Right for Arabic) to maintain the sharp hierarchy.
*   **Do** use `tertiary` (Teal) sparingly—only for successful transactions, primary conversion buttons, or positive growth trends.

### Don't
*   **Don't** use "Card Shadows" on every element. If everything floats, nothing is important.
*   **Don't** use pure black for text. Use `on_background` (#0b1c30) for a softer, more premium enterprise feel.
*   **Don't** use standard "Purple" or "Violet" accents. This is a blue/teal system; maintain the "Digital Vault" seriousness.
*   **Don't** mix roundedness. Use `rounded-md` (0.375rem) for UI controls and `rounded-xl` (0.75rem) for primary containers. Consistency is the key to an "Enterprise-Ready" look.