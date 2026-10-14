---
name: api-contract-coordination
description: Coordinates API changes across rider app, driver app, and Spring Boot backend to prevent request/response, authentication, serialization, and ride-state integration regressions.
---

# API Contract Coordination

## Before changing a contract
1. Find backend endpoint, request/response DTOs, validation, service behavior, error mapping, and tests.
2. Find all rider and driver call sites, models, serializers, repositories, and state/UI consumers.
3. Check OpenAPI definitions or API collections if present, but verify them against source.
4. Record current behavior and compatibility requirements.

## Review
- HTTP method/path, status codes, authentication, authorization.
- Required, optional, nullable, and defaulted fields.
- Enum values, status transitions, ID formats, timestamps/time zones, coordinate units, fare representation, and pagination.
- Error payload shape and user-visible mapping.
- Timeout, retry, duplicate-submit, and idempotency behavior.

## Change safely
- Prefer additive, backward-compatible changes.
- If breaking changes are necessary, explain why and update all known clients, documentation, and tests in one coordinated plan.
- Never guess endpoints or fields.
- Do not blindly retry non-idempotent operations.
- Do not let optimistic UI state masquerade as authoritative backend state.
- Keep secrets and personal information out of logs and fixtures.

## Verification
Test backend contract and both mobile consumers where feasible. Check success, validation errors, unauthorized/forbidden access, not-found, conflict, timeout, and stale-state behavior as relevant. Report which clients were verified and what remains untested.
