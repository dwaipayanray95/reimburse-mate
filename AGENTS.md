# AGENTS.md — Reimburse Mate

This file orients AI coding agents (Claude Code, Codex, Cursor, etc.) working in this
repository. Read this before making changes. See also `lib/AGENTS.md` (architecture map)
and `docs/GOTCHAS.md` (specific bugs already found and fixed once — don't reintroduce them).

## What this app is

Reimburse Mate is a personal Flutter app (Android + iOS) for logging expense
reimbursement claims: log an expense with a receipt photo/PDF and payment proof, track
its status (Draft → Yet to Claim → Submitted → Paid/Rejected), and batch-export claims
as a CSV+receipts ZIP to email to an accounts team.

**Note:** `README.md` at the repo root is stale — it describes a pre-rewrite SwiftUI/iOS
version. The app was fully rewritten in Flutter (see git log: "rewrote the entire app in
flutter"). Trust the code and this file over `README.md` until someone updates it.

## Tech stack

- **Flutter** (Dart ^3.5.0), Material 3
- **State management:** Riverpod (`flutter_riverpod`) — `StateNotifierProvider` per feature
- **Local database:** Drift (`drift` + `sqlite3_flutter_libs`) over SQLite, single table
  `Reimbursements`, stored at `<app documents dir>/reimbursements.db`
- **Persisted settings:** `shared_preferences` via `SettingsRepository`
- **OCR:** `google_mlkit_text_recognition` (on-device, no network)
- **File/image picking:** `image_picker`, `file_picker`, `flutter_image_compress`
- **Export:** `archive` (ZIP), `csv`, `flutter_email_sender` + `share_plus` (send/share)

## Commands

```bash
flutter pub get              # install deps
flutter analyze              # static analysis — MUST be clean (no errors) before considering work done
flutter build apk --debug    # sanity-build Android before pushing to device
flutter run -d <device-id>   # run on a connected device/emulator
flutter devices              # list available targets
```

There is no meaningful automated test suite yet (`test/` is effectively unused) — verifying
a change means running the app on a real device/emulator and exercising the affected flow.
`flutter analyze` catches compile errors and lints but does **not** catch logic bugs.

### Running on device notes

- Wireless ADB installs in this environment have repeatedly stalled for 5-10 minutes before
  eventually succeeding. This is a connection/install quirk, not a build failure — if
  `flutter build apk --debug` succeeds, the code is fine even if the on-device install is slow.
- `flutter build apk --debug` alone is the fastest way to confirm a change compiles for
  Android without waiting on a device.

## Architecture

Feature-first layout under `lib/features/<feature>/`:

```
lib/
  core/
    database/       # Drift table + generated code + migration strategy
    providers.dart   # ALL Riverpod provider wiring lives here — single source of truth
    theme/            # ColorScheme (seeded M3), typography, shape tokens
    widgets/          # Shared widgets (GlassCard, StatusChip, EmptyState, ...)
    utils/            # FilePickerService (picking + persisting attachments)
  features/
    <feature>/
      application/     # StateNotifier + State classes (business logic, no widgets)
      data/            # Repositories / services that touch DB, disk, network, plugins
      presentation/    # Screens + feature-local widgets (dumb, read state via ref.watch)
  models/              # Plain enums/classes shared across features (ClaimStatus, ExpenseCategory, ...)
  home_screen.dart      # Bottom nav (Dashboard/Claims) + FAB → New Entry
  main.dart             # App root, ThemeMode wiring
```

See `lib/AGENTS.md` for the full provider graph and per-feature notes.

## Conventions to follow

1. **Never silently swallow exceptions.** This codebase had a recurring bug pattern:
   `catch (_) { return null; }` in service/notifier layers, which made real failures
   (DB write errors, file pick errors, OCR failures) indistinguishable from "nothing to
   do" — the UI would just do nothing with no feedback. Every `catch` block must either
   rethrow, surface an error message through state the UI can display, or have an
   explicit, commented reason why swallowing is correct. See `docs/GOTCHAS.md` for the
   history here — this exact pattern was found independently in four different files.

2. **Attachments must be copied into permanent storage**, never referenced by the raw
   path a picker plugin returns. `image_picker`/`file_picker` paths point into OS
   temp/cache directories that can be cleared at any time. `FilePickerService._persistFile`
   copies + compresses into `<app documents dir>/attachments/` — always go through that
   service rather than using `image_picker`/`file_picker` directly.

3. **Any change to the `Reimbursements` Drift table must bump `schemaVersion`** in
   `lib/core/database/app_database.dart` and be additive (new nullable columns or
   columns with defaults). There is a `beforeOpen` safety net that reconciles missing
   columns automatically, but don't rely on it as your only migration path — always bump
   the version explicitly so the intent is visible in the diff.

4. **Use theme tokens, not hardcoded colors**, for anything that isn't a semantic
   status/category color. Status colors (`ClaimStatus.color`) and category colors
   (`ExpenseCategory.color`) are intentionally fixed hex values (see
   `lib/models/claim_status.dart`, `lib/models/expense_category.dart`) — don't theme
   those. Everything else (surfaces, text, dividers) should come from
   `Theme.of(context).colorScheme.*`.

5. **Wrap any card/container that holds a `ListTile`, `InkWell`, or other ink-splash
   widget in a `Material`**, not a plain `Container` with a `BoxDecoration`. A bare
   `Container` has no `Material` ancestor to paint tap ripples on, which produces the
   Flutter warning "ListTile background color or ink splashes may be invisible" and
   genuinely invisible tap feedback. Use the shared `GlassCard` widget
   (`lib/core/widgets/glass_card.dart`) for this — it already wraps its child in a
   `Material` with the app's standard surface-container fill and radius.

6. **Manual form validation, not `Form`/`FormField` validators.** Screens like
   `NewEntryScreen` validate fields manually in a `_submitForm` method and show a
   `SnackBar` on failure, rather than using `TextFormField.validator` +
   `_formKey.currentState.validate()`. This is existing convention — follow it for
   consistency rather than mixing both styles in the same screen.

7. **Riverpod provider wiring lives in `lib/core/providers.dart` only.** Don't construct
   repositories/services/notifiers ad hoc inside widgets — add a provider and `ref.watch`/
   `ref.read` it.

## Design system

The app uses a seeded Material 3 theme (seed color `#3B5FE0`, defined in
`lib/core/theme/app_colors.dart` / `app_theme.dart`). Key shape conventions:

- Cards/surfaces: 20-24px corner radius, filled tonal surface (`colorScheme.surfaceContainer`), no border
- Buttons/inputs: 12-14px radius
- FAB: 56×56, 16px rounded-square (not circular)
- Bottom nav: floating pill, rounded top-left/top-right corners only, ~96px tall

If asked to touch UI, match these tokens rather than inventing new radii/colors. There is
no living Figma/design-file reference checked into the repo as of this writing — the
tokens above are the source of truth.

## Known state / things to be aware of

- The database migration story was broken for a while (see `docs/GOTCHAS.md` item 1) —
  if a user reports "can't save," always check for `SqliteException` / "no column named"
  errors first; it usually means schemaVersion needs a bump.
- Filing ("File Claims" screen) only marks claims as `submitted` when actually emailing,
  not when just saving a local ZIP backup — don't change this without discussing it,
  it was an intentional fix (see `docs/GOTCHAS.md` item 4).
- Claim status can be changed manually from the Claim Detail screen's flag-icon menu —
  don't assume claims are stuck at "Submitted" forever, that was a bug that's now fixed.
