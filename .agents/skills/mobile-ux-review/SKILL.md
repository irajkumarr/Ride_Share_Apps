---
name: mobile-ux-review
description: Reviews and improves rider and driver mobile UX for clarity, task completion, error recovery, accessibility, and restrained visual polish without changing business rules.
---

# Mobile UX Review

## Principle
Improve task completion and user confidence, not decoration. Preserve existing product policy and backend behavior.

## Review implemented flows
- Rider: location/destination selection, ride options if implemented, requesting, matching, driver details, pickup, trip progress, cancellation, completion, and history.
- Driver: availability, incoming request, accept/reject, navigation to pickup if implemented, arrival, trip start/completion, and history/earnings if implemented.
Only review flows that exist; do not invent features.

## UX checks
- Is the current state immediately understandable?
- Is the primary next action clear?
- Is progress shown during network operations?
- Can users recover from timeout, lost connectivity, denied permission, no matching driver, cancellation conflict, or stale state?
- Are consequential actions clearly labeled and confirmed where appropriate?
- Are duplicate submissions prevented?
- Are contrast, touch targets, labels, semantics, and navigation usable?
- Does the screen adapt to small devices, large text, insets, and keyboard visibility?
- Do map overlays, bottom sheets, and action controls compete for space?
- Is motion restrained and purposeful?

## Boundaries
Do not change fare, matching, cancellation, or backend lifecycle rules during a visual-only task. Do not fabricate data. Reuse existing design and state patterns. Prefer small improvements. Never show success before the operation is confirmed.

## Verification
Inspect relevant screens on narrow and larger devices/viewports where possible. Exercise loading, empty, success, and failure states. Report what was actually tested.
