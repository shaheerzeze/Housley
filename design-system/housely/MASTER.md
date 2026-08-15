# Housely Design System — Warm Clarity

**Status:** Source of truth · 2026 visual system
**Platforms:** Flutter · iOS · Android · responsive web
**Reference policy:** The supplied Niva case study informs palette, typography character, density, and surface treatment only. Housely keeps its own content, information architecture, components, and layouts.

## Direction

Housely is a calm operating system for shared homes. It should feel precise, effortless, and quietly premium—not like an admin dashboard. The interface is light-first and nearly monochrome, using a soft-grey canvas, white content cards, compact geometric typography, and colour only when it communicates state.

Design dials: variance 4/10 · motion 3/10 · density 5/10.

Signature: **financial clarity blocks**—large values sit inside borderless tonal cards with small contextual labels and one decisive action. Hierarchy comes from scale, spacing, and black/grey contrast rather than decoration.

Home is an information-rich command view, not a shortcut screen. Above the fold it must answer: what is happening today, what needs me, and how is the household doing? Below it, show money, documents, belongings, people, and recent activity with enough context to act.

## Colour

| Token | Value | Role |
|---|---:|---|
| Canvas | `#F6F6F6` | Soft neutral app background |
| Surface | `#FFFFFF` | Primary cards and grouped records |
| Raised | `#E5E5E5` | Secondary controls and tonal cards |
| Pressed | `#D8D8D8` | Active and pressed state |
| Divider | `#E5E5E5` | Quiet internal separation |
| Text primary | `#1C1C1C` | Main content and primary actions |
| Text secondary | `#696969` | Supporting content |
| Text tertiary | `#969696` | Metadata only |
| Primary | `#1C1C1C` | Buttons, selected navigation, strong emphasis |
| Primary pressed | `#000000` | Pressed primary action |
| Primary soft | `#E5E5E5` | Selected and secondary surfaces |
| Positive | `#1D9A62` | Complete, gain, and success |
| Positive soft | `#E3F5EC` | Positive surfaces |
| Negative | `#D9505C` | Error, loss, and destructive action |
| Negative soft | `#FCE8EB` | Negative surfaces |
| Warning soft | `#FFF4D9` | Due and warning context |
| Information soft | `#E8F2FF` | Informational context |
| Violet soft | `#EEEAFF` | People and secondary categories |
| Scrim | `rgba(0,0,0,.30)` | Dismissible modal backdrop |

Rules:

- Reserve blue for the primary action, selection, and focused data.
- Coral communicates attention or urgency; it is never the default action colour.
- Yellow is a warm contextual accent and must use charcoal text.
- Use one dominant colour-field panel per viewport and smaller flat tints for supporting cards.
- Money uses tabular figures and colour only when status matters.
- Borders are hairlines. Prefer spacing, warm surface contrast, and minimal shadow.
- Colour fields may use a restrained two-stop radial gradient; never use them behind dense body copy.
- Do not reproduce the reference artwork, branding, copy, or screen layouts.

## Typography

The reference uses **Roobert Regular/Medium**. Because Roobert is a licensed commercial typeface and is not supplied as a project asset, Housely uses **DM Sans** as the production-safe metric and tonal match. If licensed Roobert files are later supplied, they can replace DM Sans at the theme layer without changing page code.

| Role | Size | Weight | Line height |
|---|---:|---:|---:|
| Display | 30 | 500 | 1.08 |
| Screen title | 23 | 500 | 1.16 |
| Feature title | 21 | 500 | 1.18 |
| Section title | 17 | 500 | 1.24 |
| Row title | 15.5 | 500 | 1.28 |
| Body | 15 | 400 | 1.42 |
| Supporting | 13.5 | 400 | 1.38 |
| Label/meta | 12 | 500 | 1.28 |

Use sentence case. Prefer medium over bold. Tighten large headings slightly; keep body copy neutral. Use tabular figures for amounts.

## Layout and density

- Phone gutter: 16; tablet gutter: 24.
- Spacing rhythm: 4, 8, 12, 16, 20, 24, 32.
- Minimum touch target: 48.
- Standard control height: 50.
- Standard grouped row: 60–64.
- Content width: 600 on focused flows; use two columns above 1024 where useful.
- Use generous whitespace between groups while keeping rows compact.

## Surfaces

- Default pages use soft grey; primary groups are white and secondary controls are light grey.
- Cards are borderless by default. Use tonal contrast before borders or shadow.
- Phone layouts use a 20px gutter and a 5-point spacing foundation.
- A feature panel may use one base tint plus a soft radial glow for depth and energy.
- Use 1px internal dividers with a 56px leading inset.
- Avoid placing every section inside an outlined card.
- Controls use 14px radius, groups 20px, and feature cards 24px.
- Shadows are low-opacity and broad; hierarchy should primarily come from tone and spacing.
- Chips and status labels are fully rounded and compact.

## Controls

- Primary button: action blue, white label, 50px high.
- Secondary button: warm stone surface with charcoal label.
- Destructive action: coral with charcoal or white text according to contrast.
- Icon actions: 44–48px circular or soft-square hit region.
- Segmented control: warm stone track; selected segment uses blue or white based on context.
- Inputs: warm filled surface, minimal border, persistent label, blue focus ring.

## Navigation

- Five labelled bottom destinations on phones.
- Compact side rail on wide layouts.
- Phone navigation is a detached charcoal capsule with 12px side clearance,
  bottom breathing room, and a 24px corner radius.
- The selected destination uses a compact white pill; inactive destinations
  remain quiet grey for clear hierarchy without introducing another accent.
- The dock has subtle elevation but no outline or edge-attached border.
- Screen titles align to the content grid and remain compact.

## Motion

- Feedback: 100–150ms.
- Content transition: 180–220ms.
- Use opacity and transforms only.
- Respect reduced motion.
- Haptics only for meaningful confirmation, destructive action, or explicit selection.

## Content rules

- Lead with the user’s outcome: amount, due state, ownership, or next action.
- One primary action per screen.
- Avoid duplicated icon and full-width buttons for the same action.
- Empty and error states explain the next step.
- Privacy copy is concise and contextual.

## Quality bar

- No active-looking dead controls.
- No truncation at 200% text without a full-value path.
- All normal text contrast ≥ 4.5:1.
- Selected, focused, pressed, disabled, loading, error, and success states remain distinct.
- Validate at 375px, tablet portrait, and wide landscape.
