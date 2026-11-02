# Sources and adaptation decisions

Reviewed 2026-10-30. This skill is authored for BaseSwiftUI; it does not vendor
upstream templates, scripts or plugins. Community build/runtime claims were
read, not reproduced locally. Recheck current Apple APIs when introducing code.

## Official evidence

- [ArrangementView](https://developer.apple.com/documentation/swiftui/arrangementview): two content areas, split/overlay behavior; iOS 27.1.
- [ReservedRegion](https://developer.apple.com/documentation/swiftui/reservedregion): local coordinates, margins included, scrolling-container limitations; iOS 27.1.
- [Split axes](https://developer.apple.com/documentation/swiftui/splitarrangementviewstyle/axes(_:)): only primary is shown on excluded axes.
- [Preparing for Duo](https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo): platform adoption context.

## Community references, pinned at review

| Source | Adopted concept | Excluded |
| --- | --- | --- |
| [hechen/iphone-duo-skills](https://github.com/hechen/iphone-duo-skills/tree/3d0e4532534bc090513e0fda416dd4d4f229910b), MIT | Narrow layout boundary, stable state owner, SDK honesty | Whole pack and automatic runtime checks |
| [Kimeur/duology](https://github.com/Kimeur/duology/tree/49d4658705d31b49c4b1d6e0aaa4012ab38c2290), MIT | Choose pattern by content relationship; preserve child identity; hidden-pane fallback | Swift 6/iOS 26 app templates, Observation migration, project generators, companion-skill chain |
| [Bunn/iphone-duo-skill](https://github.com/Bunn/iphone-duo-skill/tree/bb581e08cae8d8a715b2d41eb966509a3e8e292e), MIT | Distinguish docs, SDK declarations and runtime evidence | Long mandatory guide and automatic Xcode companion skills |

Belweave examples informed review cases, not production templates: axis-limited
panes need an access path, changing List/Grid branches can lose scroll state,
and custom displacement must check collisions and bounds after moving.
No upstream point-size tables become layout constants. Foldsmith's automatic
commits/driver bootstrap and Auspexlabs' screen thresholds/compiler-version
SDK gate were excluded. The external instruction scan was reviewed in context;
no upstream commands were executed or granted authority over repo policy.

## Maintenance and evidence limits

Read only the source relevant to a disputed claim; no GitHub refresh per prompt.
Update checked dates only after checking the named claim. Preserve older-OS
fallback and project ownership even if an upstream sample uses another design.
Routing definitions and metadata checks are not behavioral or speed benchmarks.
