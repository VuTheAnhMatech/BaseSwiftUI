# Vertical bars, overflow and presentations

Read for Duo bar adaptation or sheet/panel work. Preserve the screen's current
navigation owner, back/dismissal contracts and actions. API availability lives
in `sdk-compatibility.md`; current Apple sources are in `sources.md`.

## System bars and custom chrome

Navigation-container-managed toolbars and TabView receive system adaptation.
A custom BaseNavBar/HStack does not acquire relocation, overflow or camera
avoidance automatically. Prefer a feature-local integration when it preserves
the current route contract; shared navbar/router redesign belongs to architecture.

`toolbarVerticalEdge` reports the system's preferred edge even when no vertical
bar is visible. Nil means a context where the system never uses a vertical bar.
Use it to align custom UI, not to detect device identity, toolbar visibility or
its width. Read actual per-edge safe areas. Hardware-aligned bars do not simply
swap sides with RTL; keep physical bar position separate from content mirroring.

## Actions and limited space

- Provide both a meaningful title and symbol for adaptable actions. Vertical
  bars use symbols; overflow needs titles too. Title-only/custom-view items do
  not automatically participate vertically; inspect supported axis behavior
  and actual fit before opting a custom item in.
- Use semantic placements: Back/Close before prominent completion actions,
  then related action groups. Use cancellationAction for custom Close/Back and
  verify topBarPinnedTrailing when a prominent Done action needs it. Do not
  rebuild the vertical sequence with fixed spacers or guessed bar dimensions.
- Place controls on the content they affect. In NavigationSplitView, detail
  bars can become vertical while sidebar/content bars stay horizontal;
  inspectors keep horizontal bars. Do not move all column actions to detail.
- Use visibilityPriority when essential actions must remain visible longer.
  Use ToolbarOverflowMenu for actions that should always live in overflow;
  keep one discoverable overflow menu rather than duplicating the same actions.
- Default compression favors navigation destinations. Consider
  toolbarVerticalCompressionBehavior(.prefersToolbarItems) for a task-focused
  screen whose actions should take priority over tabs. Verify the actual need.
- Preserve default vertical placement unless the requested experience gives a
  concrete reason to disable it. A bar opt-out is not a general Duo fix.

## Sheets and supporting panels

System sheets, alerts and popovers account for reserved regions; custom overlay
presentations need their own geometry handling. Keep one presentation binding
and draft owner through resizing; do not dismiss/reopen solely on geometry.

`presentationPlacement` is an iOS 27 sheet preference, not a general alignment
modifier. Use it when placement should preserve visible context. On the outer
display sheet bars are vertical by default; on the inner display centered or
leading sheets use horizontal bars, while trailing sheets use vertical bars.
Check keyboard, detents and dismissal in the actual context rather than using
that rule to infer device identity.

For supplementary controls, inspector already supports a trailing column and
compact sheet from iOS 17. Respect the current navigation hierarchy and verify
push/back behavior when adding it; an upstream beta reproduction is not a
universal rule about where every inspector must attach.

Fallbacks retain the existing iOS 17 actions and presentations. New overflow or
placement APIs must not make an action unreachable on an older OS.
