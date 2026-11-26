# Accessibility across Duo layout changes

Read when panes reflow, controls move, focus can disappear, or accessibility is
requested. Preserve semantic order and current interaction state as the same
screen resizes. Apply checks to the affected flow, not every screen by default.

## Pane order and focus

Custom side-by-side panes can interleave in VoiceOver's reading order. Where
that breaks the content relationship, group each meaningful pane with
`accessibilityElement(children: .contain)`. Children remain individually
reachable, unlike collapsing an interactive pane into one combined element.
System NavigationSplitView may already provide suitable grouping; inspect
before adding redundant wrappers. Mark meaningful section titles as headings.

Keep logical order stable. Use accessibilitySortPriority only to correct a
specific order among siblings, not to rearrange semantics for every pose.
Hidden secondary actions need another accessible route, just like visible UI.

Keyboard focus (`FocusState`) and accessibility focus (`AccessibilityFocusState`)
are separate. Keep stable IDs and owners first. If the focused element vanishes,
restore to its surviving equivalent or the nearest meaningful context after
layout is ready. Avoid stealing focus on every geometry update or first render.
Do not make a community example's 300/500 ms delay a correctness requirement;
any deferred request must be cancellable and still relevant when applied.

## Text, reachability and motion

- Let large Dynamic Type change the layout: reflow labels/actions, reduce
  nonessential spacing and allow scrolling where content/keyboard fit requires
  it. Do not shrink text or cap accessibility sizes to preserve two columns.
- Check short/narrow windows and keyboard-visible editing, not only a large
  inner display. Preserve draft, caret/focus and the route to submit/cancel.
- Give icon actions names that explain their purpose in VoiceOver, Voice Control
  and overflow. Use system controls and usable hit targets; prevent overlap
  after displacement, rather than enlarging targets into neighbouring controls.
- Respect accessibilityReduceMotion: avoid large spatial/3D hinge or resize
  effects; use a quiet state change or suitable fade. Essential actions also
  need a button or accessible action if an optional gesture/hinge input exists.
- Keep status understandable without color alone, preserve contrast over
  backgrounds, and keep essential commands reachable with a hardware keyboard
  when the affected screen supports one.

## Evidence

Apple's `.contain`, AccessibilityFocusState, DynamicTypeSize and Reduce Motion
references establish these contracts; links are in `sources.md`. Community
focus/reading-order observations are useful reproduction cases, not verified
behavior of this app. For authorized runtime work, follow `validation.md` and
check the transition with VoiceOver/focus active, not only fresh screenshots.
