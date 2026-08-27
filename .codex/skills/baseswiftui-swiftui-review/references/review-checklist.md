# BaseSwiftUI Review Checklist

## Severity

- `Critical`: exploitable secret exposure, data loss, or a reliably fatal path.
- `High`: likely crash, broken primary flow, serious security/privacy issue, or
  corrupt navigation/state ownership.
- `Medium`: user-visible incorrect behavior, accessibility barrier, unstable
  identity, meaningful performance regression, or maintainability issue likely
  to cause defects.
- `Low`: contained quality improvement with limited user impact.

## Correctness and architecture

- Trace View action -> Intent -> Container -> dependency/router -> updated
  State, including cancellation and failure paths.
- Confirm Views do not perform service, repository, persistence, purchase, or
  navigation decisions directly.
- Confirm Factory registrations, route parameters, builders, and injected
  types agree.
- Exercise `push -> sheet -> dismiss -> Back`. Sheet content must dismiss its
  presentation, not ask its nested router to dismiss the parent's sheet.
- Check loading, empty, error, retry, duplicate-tap, and repeated-appearance
  behavior.
- For authenticated networking, verify a 401 refresh is bounded and applies
  only to authorization-required requests; a rejected replacement token must
  not start an endless refresh/retry cycle.

## Data and collections

- Verify stable unique IDs and a constant top-level row shape.
- Confirm BaseDataSource is owned outside the View and feature screens do not
  duplicate raw collection loops.
- Verify filtered items still emit the correct source-array `IndexPath`.
- Keep entities, enums, defaults, and mock/sample data under Domain/Entities.

## UI and accessibility

- Check compact width, Dynamic Type, long localization, keyboard, safe areas,
  overlays, and bottom content insets.
- Check icon labels, traits, focus/order, touch targets, contrast, and
  non-color-only meaning.
- Check Reduce Motion for nonessential or large motion effects.

## Performance and security

- Look for repeated expensive work in `body`, broad observation, unstable
  identity, oversized images, unnecessary type erasure, and unbounded tasks.
- Check secrets, production URLs/config, sensitive logs, and credential
  storage. The current UserDefaults-backed `TokenStore` is scaffold-only;
  production authentication requires a secure implementation.
- Header redaction is insufficient when DEBUG logging prints response bodies;
  check auth and personal-data endpoints for field- or endpoint-aware redaction.

## Evidence gate

Every finding must cite a concrete code location and explain the user-visible
or engineering consequence. Do not list generic best practices without a
matching defect or justified opportunity in the inspected code.
