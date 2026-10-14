---
name: flutter-mobile-quality
description: Improves Flutter rider or driver apps for maintainability, state correctness, responsiveness, accessibility, network resilience, and performance while preserving existing architecture.
---

# Flutter Mobile Quality

## Inspect first
Read pubspec.yaml, app entry points, routing, feature structure, state management, dependency injection, networking, models, and tests. Follow the actual state-management choice (BLoC/Cubit, Riverpod, Provider, or another existing solution). Do not migrate it without a specific reason. Inspect code generation conventions before edits.

## Engineering standards
- Keep widgets focused on rendering and user interaction.
- Keep business rules and network/persistence logic in established layers.
- Avoid duplicate requests, stale async updates, unnecessary rebuilds, and unmanaged stream/subscription lifetimes.
- Model loading, empty, success, failure, permission-denied, timeout, and offline states where relevant.
- Prevent duplicate taps from causing duplicate non-idempotent requests.
- Handle app lifecycle and stale ride state where relevant.
- Dispose controllers, subscriptions, and resources correctly.
- Use typed models and explicit parsing/error handling consistent with the codebase.
- Do not swallow exceptions or expose raw internal errors to users.

## Rider/driver UX
- Make current trip state and next action obvious.
- Provide immediate, truthful feedback for network actions.
- Handle denied location permissions, disabled services, stale GPS, and poor connectivity gracefully.
- Keep maps and live location updates efficient; avoid needless polling or rebuilds.
- Maintain accessible text, contrast, touch targets, semantics, and predictable navigation.
- Keep animation minimal and purposeful.

## Verification
Use the repository's actual scripts. Run dart format for affected Dart code, flutter analyze, relevant flutter tests, and builds when feasible. Test important state transitions and failure paths. Report actual outcomes and distinguish pre-existing failures from introduced failures.
