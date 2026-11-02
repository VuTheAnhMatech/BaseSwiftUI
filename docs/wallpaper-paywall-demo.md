# Wallpaper paywall UI preview

Source: [Figma node 111:15487](https://www.figma.com/design/dXXS3kaCtdNN2LHxi0btYZ/-SS--Design-1.0?node-id=111-15487).

Debug opens this screen after splash. Close returns to the Translate demo.
Release continues to open Home. No shared Base component was changed.

Tap Translate's top-right Settings button to present the paywall again in a
full-screen cover. X dismisses to the same Translate Container/draft; opening
again creates a fresh paywall session. The editor resigns focus before opening.
The former Settings preview/API menu is available by holding the same button.
The startup paywall uses that same presentation wrapper over a mounted Translate
screen, rather than replacing the root View branch. Presentation continuity and
rendering bounds are independent: that change alone did not fix the reported
wallpaper left behind after dismissal.

The screen includes the supplied wallpaper artwork, alternating animated columns,
benefits, weekly/yearly selection, Continue and legal/restore controls. Animation
uses the design's 30-second linear loop and stops for Reduce Motion or an inactive
scene. The wallpaper images and icons are stored in a scoped asset namespace.
Raster artwork has 2x/3x variants except the source too small for 3x; no image was
upscaled. Montserrat is not bundled, so text uses the existing Plus Jakarta Sans.

Compact windows use the phone composition. At 780pt or wider, artwork and the
purchase panel sit side by side. Scrolling is enabled only when measured panel
height plus close-button clearance exceeds usable height. The art area shrinks
before controls, and accessibility text retains one column. Selection belongs to
one Container across layout changes. The wide layout is an adaptation of the
phone design, not another supplied Figma frame.

The purchase panel now anchors to the current bottom safe area in narrow and
wide windows, with no added bottom padding. The prior code added 8pt and used
44pt legal controls. Figma evidence instead gives a 24pt legal row (16pt text
line + 4pt vertical padding per edge), no container top padding, and a separate
14pt CTA-to-row gap. Scoped native buttons avoid BaseButton's implicit 40pt
minimum; larger accessibility text can still grow. Safe-area values are read
from the current layout, never fixed by device name or fold pose.
Runtime checks after this correction measured 24pt for all three legal buttons
and 14pt between Continue and the row on both SE and folded Duo. On folded Duo,
the row ends at y=644 in a 678pt display: only the system's 34pt bottom safe area
remains. On SE, which has no bottom safe area, the row ends at y=667 in a 667pt
display. The former default was 34pt + 8pt extra inset and 44pt-tall legal
buttons on folded Duo. Results: `legal-duo.xcresult` and `legal-se.xcresult` in
`/private/tmp/PaywallDismissProbe/`. Open/close, keyboard and draft checks passed;
this footer correction has not been exercised through every fold pose.

Prices ($4.99/week and $29.99/year) and the Best Deal badge are design fixtures.
Continue and Restore show preview notices; they never purchase, restore, or grant
entitlements. Terms and Privacy also show notices because no URLs are configured.
Production integration needs real StoreKit products, localized prices, subscription
terms, restore behavior and legal URLs before this can be a working paywall.

Generic iOS and Simulator Debug builds passed using Xcode 27.1. The app was
installed and launched on SE (3rd generation), 17 Pro Max, Duo and iPad (A16).
SE, Pro Max and iPad use the installed 26.4 runtime; Duo uses 27.1. The installed
27.1 runtime is not compatible with the available iPad profile.

The scroll correction also fixes a scaled-to-fill background expanding the
foreground beyond its viewport. Background artwork and the readability gradient
are independent of the scroll content. LLDB inspection on all four Simulators
confirmed `isScrollEnabled = false` at their fitting default text sizes. On SE,
the largest accessibility text size produced 1454.5pt of content in a 667pt scroll
viewport and `isScrollEnabled = true`; the original `large` text size was restored.
This verifies runtime sizing and scroll configuration, not physical swipe input.

On 2026-11-02, temporary external XCUITests on SE passed startup close, two
Settings open/close cycles, draft preservation, keyboard dismissal and bottom-bar
hit testing. However, Simulator video still showed wallpaper left beneath the
bottom bar even though XCTest and simctl snapshots appeared correct. Those early
passes were insufficient visual evidence.

The rendering correction bounds and clips the scaled texture and animated canvas
inside the background's actual viewport. The compact black scrim now shares that
full-bleed viewport, fixing the exposed strip along the Duo outer display's
asymmetric trailing safe area without moving controls into the reserved area.
The SE recording `transition-bounded.mp4` shows the corrected post-dismiss bar.
The UI harness and evidence live under `/private/tmp/PaywallDismissProbe/`,
outside the repo; they do not add CI or an app test target.

The combined fix was then installed on all four Simulators. `final-se`,
`final-pro`, `final-duo` and `final-ipad` each have a passing `.xcresult` and a
Simulator `.mp4` recording in that evidence directory. Frame inspection after
the initial close and repeated Settings dismissals shows the bottom bar without
the stale wallpaper strip. Duo was checked on its folded outer display (1): the
scrim covers the trailing reserved area while controls remain safely inset.
Other fold poses and continuous fold transitions are not covered by this result.

Continuous window resizing, all Duo poses/displays, VoiceOver, manual
drag/scroll-to-end and purchase integration remain
manual checks. Available-space adaptation does not query Duo hinge geometry. Local
captures are under `/private/tmp/BaseSwiftUI-paywall-captures/`.
