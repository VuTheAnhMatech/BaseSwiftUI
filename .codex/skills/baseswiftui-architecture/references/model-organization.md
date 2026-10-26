# BaseSwiftUI Model Organization

## Scope

For a placement question/audit, inspect and report without moving files or
building. Edit only when requested. Keep headers `Created by Vu The Anh`.

Read the ownership section of `BaseSwiftUI/MT-CleanArchitecture/README.md`.
It is the source of truth for Domain, Data, and Presentation boundaries.

## Placement

- Business entities/value types: `MT-CleanArchitecture/Domain/Entities/<Feature>`.
- API DTOs, database/cache records, and source parsing: app Data layer.
- UI-only row/tab/section items, display metadata, and preview samples:
  separate files in `MT-Screens/<Feature>` (the existing Presentation root).
- MVI Feature/State/Intent: keep with the feature Container.
- Defaults and mocks: beside their owning model in the same layer, not all
  under Domain. Keep SDK/UI types out of Domain.
- Truly shared models: the owning layer's shared folder; do not create a
  global Models folder or put feature models in `Exts`, Factory, or Base.

Do not migrate existing screen entities merely to normalize folders during
an unrelated UI edit. For an authorized move, inspect references, preserve
behavior and apply root shared-symbol impact rules where relevant.

## Collection boundary

- Feature views must not initialize list/static data.
- Containers map domain results into UI items and own `BaseDataSource`, a
  presentation collection binder. Data-layer sources handle I/O; the binder
  is not a repository or remote/local data source.
- Repeated UI must render through `BaseDataSource` plus Base data-source views:
  `BaseGridView`, `BaseScrollView`, `BaseStackView`, `BaseLazyListView`, or
  `BaseListView`.
- Do not use direct feature-view `ForEach`, `LazyVGrid`, `GridItem`, manual cell
  width math, or ad hoc horizontal `ScrollView` loops.

## Verify only the changed ownership

- Check touched models and direct consumers, not all feature folders.
- Domain is free of UI/SDK/storage imports; transport models do not leak upward.
- UI items/defaults stay outside View bodies; MVI types keep their local owner.
- After Swift changes, build once through `BaseSwiftUI.xcworkspace` for
  `generic/platform=iOS`. A read-only audit does not need a build.
