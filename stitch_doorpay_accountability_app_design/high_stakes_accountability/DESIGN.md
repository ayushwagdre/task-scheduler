---
name: High-Stakes Accountability
colors:
  surface: '#141218'
  surface-dim: '#141218'
  surface-bright: '#3b383e'
  surface-container-lowest: '#0f0d13'
  surface-container-low: '#1d1b20'
  surface-container: '#211f24'
  surface-container-high: '#2b292f'
  surface-container-highest: '#36343a'
  on-surface: '#e6e0e9'
  on-surface-variant: '#cbc4d2'
  inverse-surface: '#e6e0e9'
  inverse-on-surface: '#322f35'
  outline: '#948e9c'
  outline-variant: '#494551'
  surface-tint: '#cfbcff'
  primary: '#cfbcff'
  on-primary: '#381e72'
  primary-container: '#6750a4'
  on-primary-container: '#e0d2ff'
  inverse-primary: '#6750a4'
  secondary: '#cdc0e9'
  on-secondary: '#342b4b'
  secondary-container: '#4d4465'
  on-secondary-container: '#bfb2da'
  tertiary: '#e7c365'
  on-tertiary: '#3e2e00'
  tertiary-container: '#c9a74d'
  on-tertiary-container: '#503d00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#cfbcff'
  on-primary-fixed: '#22005d'
  on-primary-fixed-variant: '#4f378a'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#cdc0e9'
  on-secondary-fixed: '#1f1635'
  on-secondary-fixed-variant: '#4b4263'
  tertiary-fixed: '#ffdf93'
  tertiary-fixed-dim: '#e7c365'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#594400'
  background: '#141218'
  on-background: '#e6e0e9'
  surface-variant: '#36343a'
typography:
  display:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '800'
    lineHeight: '1.1'
    letterSpacing: -0.04em
  h1:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  h2:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.3'
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
    letterSpacing: '0'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
    letterSpacing: '0'
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: '1.4'
    letterSpacing: 0.1em
  cta:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: '1'
    letterSpacing: -0.01em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  gutter: 16px
  margin: 24px
---

## Brand & Style

This design system is built on the philosophy of high-stakes accountability and extreme discipline. The visual language is intense, unapologetic, and premium, designed to evoke a sense of urgency and importance. It targets high-achievers who value friction as a tool for growth. 

The style combines **Minimalism** with **High-Contrast Boldness** and **Glassmorphism**. By utilizing a pitch-black foundation, the UI allows the vibrant accent colors to "pop" with almost neon intensity, signaling success or immediate threat. The glassmorphism elements add a layer of sophistication, ensuring the app feels like a high-end tool rather than a casual utility.

## Colors

The palette is rooted in absolute black to maximize contrast and reduce visual noise. 

- **Primary Background:** Pure black (#000000) is used for the base layer to create an infinite depth effect.
- **Accent Red (#FF3B30):** Reserved for failure, financial stakes, and high-urgency warnings. It should feel aggressive and impossible to ignore.
- **Accent Green (#34C759):** Used exclusively for streaks, completed tasks, and successful outcomes. It represents the "reward" state.
- **Surface Colors:** Dark grays (#121212) are used for cards and elevated surfaces to differentiate from the infinite black background.

## Typography

This design system utilizes **Inter** for its utilitarian precision and excellent readability in dark interfaces. 

- **Headlines:** Use heavy weights (Bold/Extra Bold) with tight letter spacing to create a sense of density and power.
- **Data Points:** Numbers, specifically streak counts and monetary values, should use the `display` style to dominate the visual hierarchy.
- **Labels:** Small caps with increased letter spacing are used for secondary metadata to maintain a clean, organized look without distracting from primary actions.

## Layout & Spacing

The layout follows a strict **8pt grid** system to ensure mathematical balance. 

- **Grid:** A fluid 12-column grid is used for desktop/tablet, while mobile relies on a single-column layout with 24px side margins.
- **Rhythm:** Generous vertical spacing (`xl`) is used between major sections to emphasize minimalism, while internal card components use tight spacing (`sm` to `md`) to keep related data points grouped.
- **Touch Targets:** All interactive elements maintain a minimum height of 48px to ensure ease of use during high-intensity interactions.

## Elevation & Depth

Depth is communicated through transparency and light-source simulation rather than traditional drop shadows.

- **Glassmorphism:** Overlays and modals use a `backdrop-filter: blur(20px)` with a semi-transparent dark fill (e.g., `rgba(20, 20, 20, 0.7)`). This maintains the context of the background while focusing the user.
- **Stroke-based Elevation:** Instead of heavy shadows, elevated elements use a 1px inner border (white at 10% opacity) on the top and left sides to simulate a subtle light source from the top-center.
- **Shadows:** When used, shadows are "long and soft" (`0 20px 40px rgba(0,0,0,0.5)`), designed to make cards feel like they are floating significantly above the base black layer.

## Shapes

The shape language balances modern approachability with structural rigidity. 

- **Base Radius:** Elements like input fields and small cards use a **0.5rem (8px)** radius.
- **Large Components:** Main containers and prominent cards use a **1rem (16px)** radius to feel more premium and "held."
- **CTAs:** Primary buttons use a **pill-shape (full round)** to differentiate them from the structural containers and signal clear interactivity.

## Components

### Buttons
- **Primary:** High-contrast white background with black text. These should feel "heavy."
- **Critical (Pay/Fail):** Solid Electric Red (#FF3B30) with white text.
- **Success (Complete):** Solid Vibrant Green (#34C759) with white text.

### Cards
Cards are built using the secondary background (#121212) with a 1px subtle border. For gamified "Streak" cards, a subtle gradient glow in Vibrant Green can be applied to the border.

### Input Fields
Inputs are dark with 1px borders that glow (either Red or Green) based on validation state. Labels are always positioned above the input in the `label-caps` style.

### Streak Indicators
A specialized component featuring large display typography for the number, paired with a progress ring or bar that uses the Vibrant Green accent.

### Progress Bars
Thin, 4px bars. The track is `rgba(255, 255, 255, 0.1)` and the indicator is either Green (on track) or Red (behind schedule).

### Glass Modals
Used for "The Moment of Truth" screens (where users confirm completion or payment). These use full-screen blurs to eliminate all distractions.