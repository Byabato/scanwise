# ScanWise Design System

## Design character

Calm intelligence.

The application should feel:

- minimal;
- modern;
- trustworthy;
- precise;
- private;
- premium;
- approachable;
- fast.

It must not look like:

- a student project;
- a cryptocurrency application;
- a cyber-security dashboard;
- an AI-generated template;
- a web dashboard compressed onto a phone.

## Color direction

Initial light-theme palette:

- background: `#F7F8F6`
- primary surface: `#FFFFFF`
- secondary surface: `#F1F3F0`
- primary text: `#161A18`
- secondary text: `#646B67`
- divider: `#E2E6E2`
- brand primary: `#176B55`
- brand soft: `#DDEFE8`
- information: `#356B8C`
- caution: `#A66610`
- critical: `#B43A3A`
- positive: `#287A55`

These values are starting tokens. They may be adjusted during implementation
to meet contrast and visual-quality requirements.

The scanner surface should use near-black camera controls with warm-white
foregrounds.

## Typography

Use a clean Android-compatible sans-serif font.

Initial hierarchy:

- screen title: 24 sp, semibold;
- section title: 18–20 sp, semibold;
- card title: 16 sp, semibold;
- body: 15–16 sp;
- supporting text: 13–14 sp;
- compact label: 12–13 sp, medium.

Use sentence case.

Do not use uppercase except for compact technical labels such as EAN-13.

## Spacing

Use an 8-point spacing system.

Core values:

- 4: micro spacing;
- 8: tightly related elements;
- 12: compact internal spacing;
- 16: standard component padding;
- 20: screen horizontal padding;
- 24: section separation;
- 32: major separation.

## Shape

- primary cards: approximately 20 dp;
- modal bottom sheets: approximately 28 dp top radius;
- buttons: 14–16 dp;
- chips: rounded;
- camera actions: circular.

Do not make every control pill-shaped.

## Elevation

Prefer:

1. spacing;
2. tonal surfaces;
3. borders;
4. elevation only where necessary.

Use shadows mainly for:

- result sheets;
- floating camera controls;
- dialogs;
- transient overlays.

## Navigation

Primary destinations:

1. Scan
2. Library
3. Settings

Use Material 3 bottom navigation.

Scan is the default destination.

## Result hierarchy

Every result should present:

1. type;
2. title;
3. interpreted information;
4. destination or identifier;
5. risk or verification notice;
6. one primary action;
7. secondary actions;
8. save or organization controls;
9. expandable details;
10. raw payload.

## Warning design

Warnings must use:

- icon;
- heading;
- explanation;
- optional details;
- color as a supporting signal only.

Do not represent warning severity through color alone.

Do not make the entire screen red.

## Accessibility

- minimum 48 dp interaction targets;
- readable contrast;
- semantic labels;
- support large text;
- no critical gesture-only controls;
- warnings understandable without color;
- buttons should communicate their consequence;
- raw technical data should be selectable where useful.