---
name: verification-code-review
description: Reviews ride-sharing code changes for correctness, security, regressions, test quality, API coordination, mobile UX, and performance before completion.
---

# Verification and Code Review

Review the complete Git diff and actual command results.

## Priority order
1. Ride lifecycle correctness and data integrity.
2. Authentication, authorization, ownership, and sensitive-data handling.
3. API compatibility between rider, driver, and backend.
4. Concurrency, duplicate requests, stale state, and transaction boundaries.
5. Error handling and recovery under weak connectivity.
6. Tests for changed behavior and important failure paths.
7. UI clarity, accessibility, responsiveness, and reduced motion.
8. Performance, battery/network use, database query behavior, and avoidable rebuilds.
9. Unrelated file changes, generated files, dependency changes, and secret leakage.

## Findings
- List actionable issues first, ordered by severity.
- Reference file and line/location where possible.
- Explain impact and a practical fix.
- Distinguish confirmed bugs from risks needing runtime verification.
- Do not present style preferences as correctness defects.

## Final verification
Compare claimed test/build results with actual output. Check Git status and diff errors. Confirm no secrets or local-only configuration were added. State exactly which apps and backend components were tested. If no issues are found, say what was inspected and what remains unverified.
