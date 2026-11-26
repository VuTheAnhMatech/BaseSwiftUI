# Validate the requested Duo/iPad adaptive behavior

For `assess`, inspect only the named screen/flow and report source findings,
uncertainties and the smallest remediation. No edits, builds, index refreshes
or runtime actions. A request to fix permits `adapt`; a diagnosis alone does not.

For `adapt`, follow root shared-symbol impact rules and run `git diff --check`
plus the existing workspace build for `generic/platform=iOS` after Swift edits.
Repeat after compiler fixes or subsequent Swift changes. Use focused existing
tests for changed behavior where justified; do not create test targets or CI
for a layout task. Skill/document-only work needs no app build.

## Source checks for the affected pattern

| Pattern | Check before claiming implementation complete |
| --- | --- |
| List-detail | Same selection/IDs and route owner; Back/deep link/presentation semantics remain reachable |
| Supporting pane | Hidden pane has a working access path; draft has one owner; no geometry-triggered dismissal loop |
| Media/controls | Stable player/service and child identity; resize does not dispatch load/stop or create another task |
| Grid/feed | Same data source/IDs, scrolling owner and anchor; alignment uses actual region rather than even-count assumption |
| Form/settings | Draft/focus retained; all actions reachable with keyboard and larger text |
| Custom bars/controls | Insets owned once; preferred bar edge is not treated as visibility; actions remain reachable in overflow and fallback |
| Reserved regions | Active/inactive policy, partial intersections, RTL and Layout origin handled; displacement stays in bounds and avoids other controls |
| iPad window drag | Width/height changes within the same size class still adapt; one screen/state owner; no root resize gesture, reload or frozen layout |
| UIKit/SDK host | Same host identity; updated local bounds/environment; no stale callback after detach or newer geometry |
| Accessibility | Meaningful pane order; focus survives or has a relevant fallback; large text/keyboard preserve access; Reduce Motion respected |

## Runtime evidence only when requested

Simulator requires explicit user instruction; a request to "make it work on
Duo" or "compare" does not by itself authorize launching it. Do not install
community drivers or create/reset simulators as part of this skill.

When authorized and supported, test the affected flow on narrow/outer and
wide/inner layouts, relevant rotations/partial-fold positions, a narrow/short
window, either multitasking side when affected, and the older-OS fallback.
For iPad-only work, use wide-to-narrow, tall-to-short and back-to-wide transitions,
including a drag that leaves size class unchanged. Check scroll offset after
content fits again and a sheet/keyboard visible during resize. Do not add Duo
pose checks to an iPad-only task. Report only the cases actually exercised.
For arrangements include primary-only presentation and the alternate access
path. For custom region handling include camera activity or inactive-region
cases when the available environment can exercise them.
Add keyboard, Dynamic Type, VoiceOver focus/order or RTL when the changed
behavior depends on them. Resize during selection, editing or playback, rather
than checking only fresh launches. Observe operation counts and state as well
as screenshots. Use existing tooling; report poses it cannot drive.

Static preview dimensions are not proof of hardware fold geometry. Compilation
is not visual or state-continuity validation. Camera capture and simultaneous
display behavior need appropriate hardware evidence outside ordinary UI work.

Report source checks, SDK/build, actual runtime checks and untested cases
separately. Never claim prompt speed gains without comparable measured runs.
