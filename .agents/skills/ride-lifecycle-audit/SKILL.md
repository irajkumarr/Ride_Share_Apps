---
name: ride-lifecycle-audit
description: Maps and validates the end-to-end ride lifecycle across rider app, driver app, and Spring Boot backend. Use before changing trip status, matching, cancellation, arrival, trip start/completion, fare, or ride history.
---

# Ride Lifecycle Audit

1. Inspect Git status and applicable instructions.
2. Locate ride/trip models, status enums, endpoints, services, persistence, notifications/realtime events, client state, and tests.
3. Trace each implemented action from UI to API to server validation to database update to the other client's update.
4. Document actual states and allowed transitions from source/tests; do not invent transitions.
5. Look for races, duplicate submissions, stale responses, missing authorization, inconsistent status handling, and cancellation conflicts.
6. Record baseline test results before editing.
7. Propose a minimal fix and identify contract implications.
8. Implement the agreed scope and update tests across affected repositories.
9. Verify valid/invalid transitions, duplicate actions, error paths, and both client views where feasible.

## Invariants to investigate
- Only authorized users can read or mutate a trip.
- Only the assigned driver can perform driver-only actions.
- Terminal states cannot accidentally return to active states.
- Concurrent requests cannot create contradictory assignments or transitions.
- Client state recovers from timeouts, app resume, and stale events.
- The server is authoritative for trip state and any fare/payment rules that exist.

Treat these as properties to validate against actual product rules, not permission to invent new behavior.

## Report
Include a transition table or concise lifecycle map, contract dependencies, confirmed defects, tests run, and remaining unknowns.
