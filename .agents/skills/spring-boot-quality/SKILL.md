---
name: spring-boot-quality
description: Reviews and improves Spring Boot backend for layered design, transaction correctness, validation, security, database performance, API compatibility, observability, and tests.
---

# Spring Boot Backend Quality

## Inspect first
Read build.gradle or pom.xml, application configuration, profiles, controllers, DTOs, services, repositories, entities, security configuration, migrations, and tests. Determine Java/Kotlin and Spring Boot versions, persistence, authentication, and conventions. Inspect configuration names without printing secret values. Record baseline results before major edits.

## Engineering standards
- Keep controllers focused on HTTP mapping and validation; keep business rules in appropriate services/domain components.
- Use request/response DTOs rather than unintentionally exposing persistence entities.
- Apply validation at API boundaries and enforce authorization server-side.
- Use transactions for multi-step state changes that require atomicity.
- Check transaction boundaries, lazy loading, N+1 queries, pagination, indexes, and concurrency where relevant.
- Use locking, uniqueness constraints, or idempotency only when supported by the domain and justified by race analysis.
- Use consistent HTTP status codes and stable, non-sensitive error responses.
- Do not hide exceptions; preserve useful internal diagnostics without logging secrets or sensitive location data.
- Never trust the client as authority for driver assignment, ride ownership, fare, or payment status.
- Preserve API compatibility or document and test a coordinated migration.
- Avoid dependencies without a concrete need.

## Ride-specific review
Verify authorization and ownership on ride-specific reads/mutations; validate state transitions in the service layer; investigate simultaneous driver acceptance, duplicate ride creation, cancellation races, repeated completion, and transaction consistency where relevant. Check that notifications reflect committed state. Treat coordinates, phone numbers, tokens, and personal data as sensitive.

## Verification
Use the project's wrapper and scripts (for example, ./gradlew test or mvnw test). Run focused tests, broader tests, and build when practical. Add tests for validation, authorization, invalid transitions, race-sensitive behavior where feasible, and contract compatibility. Never claim checks passed unless they actually did.
