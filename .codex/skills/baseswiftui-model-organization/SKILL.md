---
name: baseswiftui-model-organization
description: Create, move, or review BaseSwiftUI models, entities, screen items, enums, defaults, mock data, and data-source inputs. Use whenever model placement or ownership changes anywhere in the app.
---

# BaseSwiftUI Model Organization

Read `docs/architecture.md` for the ProjMaker-first structure with preserved layers.
New/updated headers use `Created by Vu The Anh`.

## Ownership

- Business entities: `BaseSwiftUI/Domain/Entities/<Feature>`; no SwiftUI/UIKit,
  networking, persistence or SDK imports.
- API/storage transport models: `BaseSwiftUI/Data/DTOs`; map to Domain in Data.
- UI-only row/tab/section/presentation items: separate files in
  `BaseSwiftUI/Presentation/Screens/<Feature>` or a shared Presentation folder.
- State, Intent and Effect stay with the feature Container; shared container and
  navigation configuration types stay in Core with their framework contract.
- Defaults, fixtures and mock data live beside the model in its own layer.
- Do not declare business/transport/UI item models inside Views, Containers,
  services, factories or Utils/Extensions. Keep reusable extensions in Utils.

## Lists

Containers/providers own BaseDataSource and list loading. Repeated UI renders
through the closest BaseDataSource view; feature Views do not build static model
arrays, direct collection loops or manual cell-width systems.

## Check

Inspect the model's consumers before moving it. Preserve Domain/DTO/Presentation
boundaries; do not flatten all models into Domain or remove DTO/use-case layers
because the upstream ProjMaker demo does not need them. Verify route payloads,
DI and list inputs after moves, then build the workspace for generic iOS.
