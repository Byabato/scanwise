---
name: Luminous Intelligence
colors:
  surface: '#f9faf8'
  surface-dim: '#d9dad8'
  surface-bright: '#f9faf8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f2'
  surface-container: '#edeeec'
  surface-container-high: '#e7e8e6'
  surface-container-highest: '#e2e3e1'
  on-surface: '#191c1b'
  on-surface-variant: '#3f4944'
  inverse-surface: '#2e3130'
  inverse-on-surface: '#f0f1ef'
  outline: '#6f7974'
  outline-variant: '#bec9c3'
  surface-tint: '#166b55'
  primary: '#00513f'
  on-primary: '#ffffff'
  primary-container: '#176b55'
  on-primary-container: '#9be9cd'
  inverse-primary: '#89d5ba'
  secondary: '#51625d'
  on-secondary: '#ffffff'
  secondary-container: '#d2e4dd'
  on-secondary-container: '#566661'
  tertiary: '#0a4c6c'
  on-tertiary: '#ffffff'
  tertiary-container: '#2d6485'
  on-tertiary-container: '#b3dfff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a4f2d6'
  primary-fixed-dim: '#89d5ba'
  on-primary-fixed: '#002117'
  on-primary-fixed-variant: '#00513f'
  secondary-fixed: '#d5e6e0'
  secondary-fixed-dim: '#b9cac4'
  on-secondary-fixed: '#0f1e1a'
  on-secondary-fixed-variant: '#3a4a45'
  tertiary-fixed: '#c8e6ff'
  tertiary-fixed-dim: '#99cdf2'
  on-tertiary-fixed: '#001e2e'
  on-tertiary-fixed-variant: '#094c6b'
  background: '#f9faf8'
  on-background: '#191c1b'
  surface-variant: '#e2e3e1'
  surface-primary: '#FFFFFF'
  surface-secondary: '#F1F3F0'
  text-primary: '#161A18'
  text-secondary: '#646B67'
  divider: '#E2E6E2'
  caution: '#A66610'
  critical: '#B43A3A'
  positive: '#287A55'
typography:
  screen-title:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.02em
  section-title:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  card-title:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-default:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 20px
  body-supporting:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-compact:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  screen-title-mobile:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  margin-horizontal: 20px
  gutter: 16px
  stack-sm: 4px
  stack-md: 12px
  stack-lg: 24px
---

## Brand & Style

The design system is built on the principle of **Calm Intelligence**. It seeks to bridge the gap between technical utility and human approachability, positioning itself as a sophisticated digital companion that prioritizes privacy without feeling clinical or cold. The visual narrative is "Restrained Sophistication"—every element exists for a purpose, utilizing a muted, organic palette to evoke a sense of security and clarity.

The chosen style is **Corporate / Modern** with a strong emphasis on **Tonal Minimalism**. It adheres strictly to Material 3 principles, using subtle elevation, clear hierarchy, and a warm-neutral foundation to ensure the user feels in control and informed. The interface avoids "hacker" tropes or aggressive security aesthetics, opting instead for a polished, editorial feel that emphasizes the value of information interpretation.

## Colors

The palette is anchored by a **Forest Green** primary brand color, representing growth and security. This is balanced by a **Warm Off-White** background that reduces eye strain and distinguishes the app from the stark white of generic utilities. 

- **Primary Brand (#176B55):** Used for key actions, brand identity, and success states.
- **Surface Strategy:** The app uses three levels of containment: the `neutral` background for the base, `surface-secondary` for grouped content or list items, and `surface-primary` for the highest-level interactive elements like cards and bottom sheets.
- **Semantic Feedback:** Caution (Amber) and Critical (Red) colors are used sparingly. For suspicious scans, the UI uses these colors for text and icons to signal risk without overwhelming the user with alarming "danger" blocks.
- **Dark Mode / Camera Overlay:** The camera experience should invert this logic, utilizing a near-black transparency to keep the focus on the physical world, while controls use the `neutral` off-white for high legibility.

## Typography

This design system utilizes **Inter** for its exceptional legibility and systematic weight distribution. The type hierarchy is intentionally tight to prevent information density from feeling overwhelming.

- **Scale:** Headings use semibold weights to provide a strong structural anchor.
- **Readability:** Body text is set at 15px to optimize for scanning long lists of data or technical details. 
- **Contextual Styles:** `label-compact` is used for metadata, badges, and secondary navigation labels, often in `text-secondary` to maintain a clear visual hierarchy.
- **Alignment:** All typography follows a strict vertical rhythm based on the 8pt grid, ensuring that line heights are multiples of 4px.

## Layout & Spacing

The layout philosophy follows a **Fluid Grid** model optimized for Android mobile viewports (390x844). 

- **Grid:** A standard 4-column mobile grid is used, but the primary constraint is the **20px horizontal margin**, which provides a "breathable" frame around the content.
- **Rhythm:** An 8pt spacing system governs all spatial relationships. 4px increments are used for internal component padding (e.g., icon-to-label), while 12px and 24px increments define the vertical separation between sections and cards.
- **Safe Areas:** Adherence to edge-to-edge layouts is mandatory. Content must flow behind the system bars with appropriate top/bottom padding to ensure no interactive elements overlap with the camera notch or system navigation.

## Elevation & Depth

This design system prioritizes **Tonal Separation** and **Borders** over heavy drop shadows. This approach aligns with the "Calm Intelligence" brand, avoiding the visual clutter of floating elements.

- **Levels of Depth:** 
  - **Level 0 (Background):** The base `#F7F8F6` layer.
  - **Level 1 (Surface):** Cards and secondary containers use `#FFFFFF` with a subtle `#E2E6E2` 1px border. No shadow is applied here.
  - **Level 2 (Floating):** Floating Action Buttons (FABs) or active camera controls use a very soft, diffused shadow (10% opacity, 8px blur, 4px Y-offset) to indicate interactivity.
  - **Level 3 (Overlays):** Modal Bottom Sheets use the highest elevation, utilizing a 24% dimmed backdrop behind them to focus the user's attention.
- **Glassmorphism:** Reserved exclusively for the camera interface top bar and controls to provide context without obscuring the camera feed.

## Shapes

The shape language is "Rounded-Sophisticate." It avoids the extreme playfulness of full pill-shapes, opting instead for generous, deliberate radii that feel modern and accessible.

- **Global Radius:** Standard UI elements like small buttons or input fields use a **14-16px radius**.
- **Container Radius:** Standard cards use a **20px radius**, providing a distinct containerized feel that softens the "technical" nature of scan data.
- **Feature Radius:** Bottom sheets use a **28px top radius** to feel like an organic drawer emerging from the bottom of the screen.
- **Camera Controls:** Circular shapes are used exclusively for camera-related functions (shutter, torch) to align with traditional photography mental models.

## Components

### Buttons
- **Primary:** Forest green background, white text, 16px radius. Full-width for primary actions in result sheets.
- **Secondary:** Soft brand surface (`#DDEFE8`) with primary text. Used for less critical actions like "Save to Library."
- **Ghost:** Transparent background with `text-secondary`. Used for "Cancel" or "Dismiss."

### Cards
- **Structure:** White surface, 20px radius, 1px border (`#E2E6E2`).
- **Content:** Header (16px semibold) followed by supporting copy (14px). Icons should be 24dp line icons in `text-secondary`.

### Input Fields & Selectors
- **Search:** 20px radius, `#F1F3F0` background, no border.
- **Chips:** 12px medium labels inside a 16px radius container. Active state uses `primary-brand` with white text; inactive uses `surface-secondary` with `text-secondary`.

### Bottom Sheets
- **Result Sheet:** 28px top radius. Layout order: Type Badge → Title → Security Status (if caution/critical) → Primary Action → Secondary Action Row.
- **Navigation Bar:** Material 3 standard. Line icons (24dp), 12px labels. The "Scan" icon is the central focus but maintains the same visual weight as Library and Settings.

### Scanning Frame
- **Design:** Four corner segments (32dp length, 3dp thickness) with a 20px corner radius. Animates to "tighten" and pulse slightly when a code is detected.