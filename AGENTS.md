# Ride-Sharing Platform — Workspace Instructions

## Mission
Improve the existing rider app, driver app, and Spring Boot backend to production-quality standards. Prioritize correctness, safety, reliability, maintainability, performance, and clear user experience over large rewrites or superficial polish.

## First: map the system
- Inspect repository layout, Git status, README files, build files, environment templates, tests, and architecture before editing.
- Identify whether this workspace contains the rider app, driver app, backend, or multiple repositories. If separate, inspect each and document how they communicate.
- Trace implemented ride flows: request, matching, accept/reject, arrival, start, completion, cancellation, fare/payment if implemented, and history.
- Identify real API contracts, authentication, authorization, location updates, notifications, and real-time mechanisms. Never assume a feature exists because it is common in ride-sharing apps.
- Create a concise architecture map and baseline verification report before major changes.

## Non-negotiable safety and correctness
- Do not perform a broad rewrite or mass refactor without a reviewed plan.
- Preserve behavior and public API contracts unless a change is explicitly requested and its impact is understood.
- Treat rider, driver, and backend changes as a coordinated system. Check both sides of API or lifecycle changes.
- Never invent endpoints, request fields, response shapes, status values, or business rules.
- Do not change ride status transitions without documenting valid transitions and checking all callers.
- Do not trust client-provided fare totals, driver identity, trip ownership, payment state, or privileged status. Validate authoritatively on the server.
- Check authorization and ownership for ride details, cancellations, trip actions, location access, and history.
- Investigate duplicate ride requests, duplicate accept/start/complete operations, race conditions, and stale state. Use transactions, constraints, idempotency, or concurrency controls where justified by the actual design.
- Treat location and personal information as sensitive. Avoid logging precise coordinates, tokens, phone numbers, or unnecessary personal data.
- Never weaken authentication, authorization, validation, or TLS configuration to make tests pass.

## Architecture and code quality
- Follow each repository's established conventions; improve incrementally.
- Prefer cohesive classes/functions, clear naming, explicit boundaries, and testable business logic.
- Avoid unnecessary abstractions, duplicated state, speculative frameworks, and dependencies without a concrete need.
- Keep UI presentation separate from business rules and network/data concerns according to existing architecture.
- Handle errors explicitly; do not swallow exceptions or show raw server stack traces to users.
- Handle loading, empty, success, failure, permission-denied, timeout, and offline states where relevant.
- Do not manually edit generated files when source definitions and generators exist.

## Rider and driver experience
- Keep rider and driver experiences distinct but use consistent terminology and design language.
- Optimize the real ride workflow before adding decorative features.
- Provide clear feedback for matching, acceptance, arrival, trip progress, cancellation, completion, and failures as supported by the backend.
- Make current ride state and next action easy to understand.
- Handle denied location permission, disabled location services, poor connectivity, app resume, stale location, and interrupted requests where applicable.
- Use accessible touch targets, readable contrast and typography, meaningful labels, and predictable back/navigation behavior.
- Keep animations restrained and purposeful; respect reduced-motion preferences where supported.
- Do not invent features or change fare, cancellation, matching, or payment policies without explicit direction.

## API and integration
- Before changing DTOs, endpoints, status enums, authentication, or error responses, search all consumers in both apps and backend.
- Keep serialization, date/time formats, units, nullable fields, and error handling consistent with the real contract.
- Avoid breaking changes. If necessary, provide a migration plan and update all known clients and tests.
- Make network operations resilient to timeouts, retries, duplicate submission, and stale responses as appropriate. Do not blindly retry non-idempotent operations.
- Keep secrets and environment-specific values out of source control.

## Performance
- Measure or identify a credible bottleneck before optimizing.
- Avoid unnecessary rebuilds, repeated requests, unbounded location updates, excessive polling, blocking work, N+1 queries, and missing indexes.
- Preserve correctness when optimizing concurrency, caching, streams, or database access.
- Consider battery, mobile data, and location accuracy, not only raw speed.
- Do not cache mutable ride state without a clear invalidation strategy.

## Testing and delivery
1. Inspect Git status and preserve all existing changes.
2. Map affected behavior and establish baseline results.
3. Plan a small, reversible implementation.
4. Add or update focused tests.
5. Run the relevant formatter, static analysis, tests, and build for each affected repository when available.
6. For cross-system changes, verify API contracts and both client integrations.
7. Review the final diff for accidental changes and secrets.
8. Report commands actually run, results, unverified areas, and pre-existing failures.

Never claim checks passed unless they ran successfully. Ask before destructive database operations, production deployments, changing live infrastructure, paid services, or pushing/merging changes.
