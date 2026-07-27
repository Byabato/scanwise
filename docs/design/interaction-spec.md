# ScanWise Interaction Specification

## Scan acceptance

1. Scanner detects a candidate value.
2. Acceptance gate verifies that the application is ready.
3. Duplicate callbacks during processing are ignored.
4. Camera processing pauses.
5. Content is parsed and assessed.
6. Haptic feedback occurs when enabled.
7. Result UI is presented.
8. Scanner resumes only after the result is dismissed or completed.

## Result presentation

Use a modal bottom sheet or an equivalent compact result surface.

The sheet should:

- show interpreted information first;
- expose raw data only through progressive disclosure;
- contain one dominant primary action;
- keep Copy, Share and Save secondary;
- allow dismissal;
- preserve camera context in the background where appropriate.

## External actions

- Never execute automatically.
- Clearly label the consequence.
- Require confirmation for concerning destinations.
- Gracefully handle unavailable external applications.
- Return the user to a stable application state.

## Save

1. User selects Save.
2. Collection picker appears.
3. Suggested collection is displayed.
4. User may add a note.
5. Save completes locally.
6. Snackbar confirms success.
7. Undo remains available briefly.

## Delete

1. User deletes a Library item.
2. Item is removed optimistically where safe.
3. Snackbar offers Undo.
4. Permanent removal completes after the Undo period or according to the
   repository policy.

## Duplicate

Do not treat duplicate scans as an error.

Present:

- previous title;
- previous date;
- collection;
- note;
- occurrence count.

Actions:

- open existing;
- record new occurrence;
- save separately;
- dismiss.

## Motion

Motion should be functional and restrained.

Initial targets:

- detection feedback: approximately 180 ms;
- result-sheet entrance: approximately 240 ms;
- state transitions: 180–260 ms;
- no decorative looping animations.

Animation durations should be centralized as design tokens.

## Back behavior

- back closes an open sheet first;
- back exits nested detail before leaving the current primary destination;
- scanner resources stop when leaving the scanner destination;
- Android predictive-back compatibility should be considered.