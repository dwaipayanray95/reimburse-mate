# GOTCHAS — bugs already found and fixed once

This is a changelog of real bugs found in this codebase, kept so future agents (human or
AI) don't reintroduce the same mistakes. If you find yourself about to write a pattern
described here, stop and read the fix.

## 1. Silent exception swallowing (found in 4 separate files)

**Symptom:** user reports "I tapped X and nothing happened" — no crash, no error, no
visible feedback, just... nothing.

**Root cause:** a recurring pattern across the codebase of

```dart
try {
  final result = await someOperation();
  return result;
} catch (_) {
  return null; // or a default/empty value
}
```

in service and notifier layers. This makes a genuine failure (DB write error, file pick
permission denial, OCR failure, ZIP encode failure) indistinguishable from "there was
nothing to do" (e.g. user cancelled a picker, which legitimately returns `null` without
throwing). The UI layer had no way to tell the two apart, so it just... did nothing.

**Found in:**
- `EntryNotifier.saveClaim` — a failed `insertClaim` (e.g. a SQL error, see #2 below)
  was swallowed; Save button just re-enabled with zero feedback.
- `FilePickerService` (all three pick methods) — a genuine picker error was
  indistinguishable from user cancellation.
- `OcrService.processImage` — caught its own exception and returned a fake "successful"
  empty `OcrResult`, so the `OcrError` state in `OcrNotifier` was structurally
  unreachable — errors could never surface even after the notifier layer was fixed to
  handle them.
- `ZipExportService.createReimbursementsZip` — wrapped the whole method in try/catch
  returning `null` on any failure, including ZIP encoding failures that should be loud.

**Fix pattern:** rethrow (or throw a domain-specific exception like
`AttachmentPickException`) from the service/data layer. Catch and convert to a
user-visible message one layer up, in the notifier or the widget's error handler. Never
let `catch (_) { return null; }` be the last word for anything that isn't a genuine,
expected "no-op" case (e.g. a picker legitimately returning null because the user backed
out — that's fine to treat as null, since it never throws for that case).

## 2. Database schema silently drifted from code (schemaVersion never bumped)

**Symptom:** `SqliteException(1): ... table reimbursements has no column named
particulars ... Causing statement: INSERT INTO "reimbursements" (...)`. New Entry Save
appeared completely broken.

**Root cause:** `lib/core/database/app_database.dart` had `schemaVersion => 1` since the
table was first created, but the `Reimbursements` table definition gained more columns
over time (`particulars`, `note`, etc.) without ever bumping the version. Drift only runs
`onCreate`/`onUpgrade` migrations based on the stored SQLite `user_version` vs. the
declared `schemaVersion` — since the version never changed, Drift assumed the on-disk
table already matched the code and never reconciled it. The on-disk `reimbursements.db`
file (created by an earlier build) was missing columns the current code expected to
insert into.

**Fix:** bumped `schemaVersion` to 2 and added a real `MigrationStrategy`:
- `onUpgrade` diffs the on-disk table (via `PRAGMA table_info`) against the current
  `Reimbursements.$columns` and adds whatever's missing via `Migrator.addColumn`.
- `beforeOpen` runs the same reconciliation unconditionally on every launch, as a
  defensive net in case a future change forgets to bump the version again.

**Rule going forward:** any change to the `Reimbursements` table (new column, changed
default, etc.) must bump `schemaVersion`. The `beforeOpen` safety net will catch missing
*columns*, but it will not handle renames, type changes, or data backfills — those still
need an explicit `onUpgrade` case.

## 3. OCR results could apply to the wrong attachment

**Symptom:** scan the invoice, then scan the payment proof before the first OCR finishes
— the payment scan's result silently overwrites the invoice scan's in-flight state, and
"Apply Details" could fill the form from the wrong image.

**Root cause:** `OcrNotifier` had a single undifferentiated state shared by both the
invoice and payment-proof attachment slots in `NewEntryScreen`.

**Fix:** added `OcrTarget { invoice, payment }`, threaded through `scanImage(path,
target)` and every `OcrState` subclass. `OcrNotifier.scanImage` also now no-ops if a scan
is already in progress, instead of starting a second concurrent scan that could finish in
either order.

## 4. Filing marked claims "submitted" even for a local-only ZIP export

**Symptom:** tapping "Save ZIP" (meant to be a local backup with no side effects) also
flipped the claim status to `submitted`, same as actually emailing it.

**Fix:** `FilingNotifier.fileClaims` now only calls `batchUpdateStatus(..., submitted)`
on the "Send via Mail" path (`exportOnly == false`). A local ZIP export leaves status
untouched. If you touch this logic again: `exportOnly` means "just write files
somewhere," not "file this claim."

## 5. Monthly spend chart merged different years into the same bar

**Root cause:** `DashboardNotifier.updateStats` bucketed claims by month *name only*
(`"Jan"`, `"Feb"`, ...), so a January 2025 claim and a January 2026 claim landed in the
same bar.

**Fix:** bucket by a sortable `"YYYY-MM"` key first, take the most recent 6 buckets
chronologically, then relabel each for display as `"MMM 'yy"` (e.g. `"Jan '26"`). Don't
go back to bucketing by bare month name.

## 6. Ink splashes / tap ripples invisible on several cards

**Symptom:** Flutter debug console warning `"ListTile background color or ink splashes
may be invisible"`, and in practice: tapping list rows on cards produced no visible
ripple feedback.

**Root cause:** several screens built their surface-container cards as a plain
`Container(decoration: BoxDecoration(color: ..., borderRadius: ...))` rather than a
`Material`. A `ListTile`/`InkWell` inside paints its ink splash onto the nearest
`Material` ancestor — with no `Material` in between, the splash painted on whatever
`Material` was way up the tree (e.g. the `Scaffold`), not on the visible colored card, so
ripples looked disabled.

**Found and fixed in:** New Entry's details form container, Settings' section cards
(both now use the shared `GlassCard` widget, which wraps its child in a `Material`).

**Rule going forward:** see root `AGENTS.md` convention #5 — always use `GlassCard` (or
another `Material`-backed wrapper) for any card containing tappable list content, not a
raw `Container`.

## 7. Attachments stored in OS-clearable temp/cache paths

**Symptom:** receipt images/PDFs would eventually go missing — broken image icon in
Claim Detail, or silently dropped from a filed ZIP export.

**Root cause:** `image_picker`/`file_picker` return a path into the OS's temp directory
(iOS) or app cache (Android), both of which the OS is free to clear at any time. The app
stored that raw path directly in the database instead of copying the file somewhere
permanent.

**Fix:** `FilePickerService._persistFile` now copies (and compresses, for images) every
picked attachment into `<app documents dir>/attachments/` before returning its path.
There was also a fully-built-but-never-called `ImageService` doing something similar
that had been abandoned; it was deleted once its logic was folded into
`FilePickerService` — don't reintroduce a second, unused persistence path.

**Rule going forward:** never store a path returned directly from `image_picker` or
`file_picker` in the database. Always go through `FilePickerService`.
