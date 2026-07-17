# Changelog

All notable changes to Reimburse Mate are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- Material 3 visual redesign across every screen (seeded `ColorScheme`, flat
  surface-container cards, floating rounded bottom nav, restyled New Entry/Filing/
  Settings screens)
- Manual claim status changes (Draft/Yet to Claim/Submitted/Paid/Rejected) from the
  Claim Detail screen
- Persistent light/dark/system theme toggle in Settings
- Live app version display in Settings (via `package_info_plus`, replacing a
  hardcoded string)
- `AGENTS.md`, `lib/AGENTS.md`, `docs/GOTCHAS.md` — contributor/AI-agent documentation

### Fixed
- New Entry "Save" silently failing with no error shown (root cause: an on-disk
  database schema that had drifted out of sync with the code — see
  `docs/GOTCHAS.md` #2)
- Receipt/payment-proof attachments being stored in OS-clearable temp/cache paths
  instead of permanent app storage, causing them to occasionally go missing
- Claims permanently stuck at "Submitted" with no way to mark Paid/Rejected
- Filing a local "Save ZIP" backup incorrectly marking claims as submitted
- OCR scans of invoice vs. payment-proof attachments occasionally overwriting each
  other's in-flight results
- Monthly spend chart merging different years into the same bar
- Dashboard totals always showing ₹ regardless of the configured default currency
- Invisible tap ripple feedback on several list cards (missing `Material` ancestor)
- Transparent status bar rendering as a solid black scrim on Android 15+ devices
  (`targetSdk` bump + reactive `SystemUiOverlayStyle`)
- Several instances of exceptions being silently swallowed instead of surfaced to
  the user (file picking, OCR, database writes) — see `docs/GOTCHAS.md` #1

### Removed
- Unused location permissions (`ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION`) —
  never actually used by any feature

---

Earlier history predates this changelog; the app was originally a SwiftUI/SwiftData
iOS app before being rewritten in Flutter.
