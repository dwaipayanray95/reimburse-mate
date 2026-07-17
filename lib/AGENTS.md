# lib/AGENTS.md — Architecture map

Scoped notes for the `lib/` source tree. Read `../AGENTS.md` first for conventions.

## Provider graph (`core/providers.dart`)

All providers are declared in one file — check it before adding a new
service/repository/notifier instead of instantiating things inline in widgets.

```
sharedPreferencesProvider   (overridden in main.dart with the real SharedPreferences instance)
  └─ settingsRepositoryProvider → settingsProvider (SettingsNotifier)
       - holds: userName, defaultCurrency, recipientEmail, emailBody, themeMode
       - main.dart watches settingsProvider.themeMode to drive MaterialApp.themeMode

databaseProvider (AppDatabase, singleton, closed on dispose)
  └─ claimsRepositoryProvider (ClaimsRepository)
       └─ claimsNotifierProvider (ClaimsNotifier: AsyncValue<List<Reimbursement>>)
            - loadClaims/addClaim/updateClaim/deleteClaim/updateStatus/batchUpdateStatus/batchDelete
            - the single source of truth for the claims list; dashboardProvider listens to it
       └─ entryNotifierProvider (EntryNotifier: EntrySaveState{isSaving, errorMessage})
            - used only by NewEntryScreen to insert a new claim

filterProvider (FilterNotifier)        — Claims screen status filter + search text
multiSelectProvider (MultiSelectNotifier) — Claims screen multi-select mode

dashboardProvider (DashboardNotifier: DashboardStats)
  - NOT driven by ref.watch — uses ref.listen on claimsNotifierProvider so stats
    recompute whenever claims change, without dashboardProvider itself depending
    on the claims AsyncValue type

ocrServiceProvider (OcrService, disposes its TextRecognizer)
  └─ ocrNotifierProvider (OcrNotifier: OcrState — Idle/Processing(target)/Done(result,target)/Error(msg,target))
       - `target` is OcrTarget.invoice | OcrTarget.payment — this exists specifically
         to stop a second scan (e.g. payment proof) from overwriting an in-flight
         invoice scan's result. See docs/GOTCHAS.md item 3.

zipExportServiceProvider (ZipExportService)
emailServiceProvider (EmailService)
  └─ filingNotifierProvider (FilingNotifier: FilingState{status, errorMessage, missingAttachmentCount})
       - used only by FileClaimsScreen
```

## Feature-by-feature notes

### `features/new_entry/`
Entry point: FAB on `home_screen.dart` → `NewEntryScreen` (pushed as a full-screen dialog
route, not a tab). Validation is manual in `_submitForm` (see convention #6 in root
AGENTS.md) — required: invoice attachment, project code, particulars, amount > 0, payment
proof (unless payment method is cash). Picking a photo/PDF auto-triggers OCR via
`ocrNotifierProvider`, and `OcrResultBanner` lets the user apply detected amount/vendor/
date/currency into the form fields.

### `features/claims/`
`ClaimsScreen` is the list (filterable by `ClaimStatus`, searchable, multi-selectable for
batch delete or "File Claims"). `ClaimDetailScreen` shows one claim, lets you delete it or
change its status via the flag-icon menu in the AppBar (`PopupMenuButton<ClaimStatus>` →
`claimsNotifierProvider.notifier.updateStatus`).

### `features/dashboard/`
Read-only aggregation view (`DashboardNotifier.updateStats`) — pending/claimed totals,
this-month count, average claim size, last-6-months spend chart (bucketed by `YYYY-MM`
then relabeled `"MMM 'yy"` for display — do not bucket by month name alone, see
`docs/GOTCHAS.md` item 5), and per-project spend breakdown. All currency amounts should be
formatted using `ref.watch(settingsProvider).defaultCurrency`, not a hardcoded symbol.

### `features/filing/`
`FileClaimsScreen` takes a list of selected `Reimbursement`s, builds a ZIP
(`ZipExportService` → `csv` + per-claim invoice/payment files, skipping — and now
counting — any attachment file that no longer exists on disk) and either shares it
directly ("Save ZIP") or emails it via `flutter_email_sender` with a `share_plus`
fallback ("Send via Mail"). Only the email path marks claims `submitted`.

### `features/ocr/`
`OcrService.processImage` runs ML Kit text recognition and heuristically extracts vendor
name, amount, currency, and date from receipt text. It throws on failure — do not make it
swallow exceptions and return an empty/default `OcrResult`, that was bug #3 in
`docs/GOTCHAS.md` and made OCR failures silently indistinguishable from "receipt with no
readable text."

### `features/settings/`
`SettingsRepository` wraps `shared_preferences` directly (no DB). `SettingsNotifier`
exposes user name, company, default currency, recipient email, email body template, and
`ThemeMode` (persisted as a string key, read by `main.dart`).

## Database (`core/database/app_database.dart`)

Single Drift table `Reimbursements`. `AppDatabase.migration` has:
- `onCreate`: `m.createAll()`
- `onUpgrade`: reconciles any column present in the Dart table definition but missing
  from the on-disk SQLite table (via `PRAGMA table_info` diff + `Migrator.addColumn`)
- `beforeOpen`: runs the same reconciliation unconditionally, as a safety net

**When you add/rename/remove a column on `Reimbursements`, bump `schemaVersion`.** Do not
rename or remove columns casually — this table is the user's only copy of their claims
data (see root AGENTS.md convention #3, and `docs/GOTCHAS.md` item 1 for what happens if
you don't).

## Models (`lib/models/`)

- `ClaimStatus` — draft/yetToClaim/submitted/paid/rejected, each with a fixed color/icon/
  emoji and a `nextStatus` workflow hint (not currently enforced — status can be set to
  any value via the detail screen's menu).
- `ExpenseCategory` — travel/food/accommodation/transport/office/software/communication/
  medical/general, each with a fixed color/icon.
- `PaymentMethod` — upi/card/cash/bank_transfer, `requiresPaymentProof` is false only for
  cash.

Status and category colors are intentionally fixed (not theme-derived) so they stay
consistent and legible across light/dark mode — don't route them through `ColorScheme`.
