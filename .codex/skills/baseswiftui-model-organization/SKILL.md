---
name: baseswiftui-model-organization
description: Create, move, or review BaseSwiftUI models, entities, screen items, enums, defaults, mock data, and data-source inputs. Use whenever model placement or ownership changes anywhere in the app.
---

# BaseSwiftUI Model Organization

## Core Rule

For generated or updated model/entity file header comments, always use
`Created by Vu The Anh`; never use `HoanPC`, `CarWidget`, or another
project/person name.

Keep all app models, entities, screen item structs, section/tab enums, mock data,
sample data, and default static lists under:

`BaseSwiftUI/MT-CleanArchitecture/Domain/Entities/`

Never declare these in SwiftUI views, MVI containers, factories, services,
repositories, helpers, or `BaseSwiftUI/Exts`.

## Folder Placement

- Put feature-specific models in a feature folder:
  - `Domain/Entities/Home/HomeEntities.swift`
  - `Domain/Entities/<Feature>/<Feature>Entities.swift`
- Put route/tab/presentation entities in their feature folder when they are not
  shared domain concepts:
  - `Domain/Entities/<Feature>/<Feature>Presentation.swift`
- Put truly shared app-wide entities in:
  - `Domain/Entities/Shared/`
- Do not leave unrelated feature models together in one flat file.
- Do not use `Exts` as a place to hide entities or default lists.

## Default And Static Data

- Store default lists beside their model in the same entity folder, usually as a
  `static let defaults` extension.
- A container may assign defaults into state or a `BaseDataSource`, but it must
  not manually build arrays of `.init(...)` for model lists.
- Repositories/data providers may compose domain content, but reusable mock or
  sample lists still belong in `Domain/Entities`.

## BaseDataSource Boundary

- Feature views must not initialize list/static data.
- Containers or data providers own list loading and push repeated UI data into
  `BaseDataSource`.
- Repeated UI must render through `BaseDataSource` plus Base data-source views:
  `BaseGridView`, `BaseScrollView`, `BaseStackView`, `BaseLazyListView`, or
  `BaseListView`.
- Do not use direct feature-view `ForEach`, `LazyVGrid`, `GridItem`, manual cell
  width math, or ad hoc horizontal `ScrollView` loops.

## Review Checklist

- Search feature folders for `struct`, `enum`, `.init(` arrays, `ForEach`, and
  `LazyVGrid`.
- Move any model-like type out of views/containers unless it is strictly MVI
  `Feature`, `State`, or `Intent`.
- If a type has UI labels, asset names, tab metadata, section metadata, or row
  definitions, treat it as an entity and place it under `Domain/Entities`.
- After moving files, build through `BaseSwiftUI.xcworkspace`.
