# Reimburse Mate

_Reimburse Mate_ is a personal expense reimbursement tracker for Android (and iOS).
Log an expense with a project code, receipt photo/PDF, and payment proof, track its
status from Draft through Paid, and batch-export claims as a CSV + receipts ZIP to
email to your accounts team.

Built with **Flutter** (Material 3) and a local **SQLite** database (via Drift) — your
data lives entirely on your device.

---

## Features

### Logging
- Fast entry form: date, project code, particulars, amount, currency, expense category
- Attach an invoice/receipt (photo or PDF) and a separate payment proof
- On-device OCR (ML Kit) reads the receipt and pre-fills amount, vendor, date, and
  currency where it can
- Every new entry starts as **Yet to Claim**

### Browsing & management
- **Dashboard**: pending/claimed totals, this-month count, average claim size, a
  6-month spend chart, and a per-project spend breakdown
- **Claims list**: filter by status (Draft / Yet to Claim / Submitted / Paid /
  Rejected), search by project code or particulars, multi-select for batch actions
- **Claim detail**: full attachment previews (image or PDF), and a status menu to move
  a claim through Draft → Yet to Claim → Submitted → Paid/Rejected manually

### Filing & export
- Select one or more claims and file them: builds a ZIP (CSV summary + every attached
  receipt/proof) and either emails it directly or hands off to the system share sheet
- A local "Save ZIP" export is available as a backup without changing any claim's status
- Sending via email marks the included claims **Submitted**

### Settings
- User info, filing defaults (recipient email, email body template)
- Default currency
- Light / Dark / System theme toggle, persisted across launches

---

## Tech stack

| Concern | Library |
|---|---|
| State management | `flutter_riverpod` |
| Local database | `drift` (SQLite) |
| OCR | `google_mlkit_text_recognition` (on-device) |
| File/image picking | `image_picker`, `file_picker`, `flutter_image_compress` |
| PDF viewing | `pdfrx` |
| Export | `archive` (ZIP), `csv` |
| Email/share | `flutter_email_sender`, `share_plus` |
| Theming | Material 3, seeded `ColorScheme`, `google_fonts` (Inter) |

See [`AGENTS.md`](AGENTS.md) and [`lib/AGENTS.md`](lib/AGENTS.md) for the full
architecture map, and [`docs/GOTCHAS.md`](docs/GOTCHAS.md) for a history of real bugs
found and fixed in this codebase — useful context before making changes.

---

## Requirements

- Flutter SDK (Dart ^3.5.0) — see [flutter.dev/get-started](https://flutter.dev/get-started)
- Android Studio / Xcode for platform toolchains
- Android: `minSdk 24`, `targetSdk 36`
- iOS: 13+ (via Flutter's default deployment target, adjust as needed)

## Getting started

```bash
git clone https://github.com/dwaipayanray95/reimburse-mate.git
cd reimburse-mate
flutter pub get
flutter run
```

To sanity-check a change without a device:

```bash
flutter analyze
flutter build apk --debug
```

There is no automated test suite yet — verifying a change means running the app on a
real device/emulator and exercising the affected flow.

## Contributing / working on this repo

This project uses `AGENTS.md`-style documentation aimed at both human and AI
contributors:

- [`AGENTS.md`](AGENTS.md) — orientation, conventions, commands
- [`lib/AGENTS.md`](lib/AGENTS.md) — provider graph and feature-by-feature notes
- [`docs/GOTCHAS.md`](docs/GOTCHAS.md) — bugs already found and fixed once; read this
  before touching database, file-picking, or OCR code
- [`docs/RELEASE.md`](docs/RELEASE.md) — how a release is cut and signed
- [`docs/PRIVACY_POLICY.md`](docs/PRIVACY_POLICY.md) — what data the app touches and
  where it goes (short answer: nowhere but your own outgoing email)

## License

[The Awesome License v1 (TALv1)](LICENSE) — free for personal, educational, and
non-profit use. If you're building something revenue-generating with this code (or
using it internally at a for-profit company), see the license for your two options:
open-source your project back, or reach out about a commercial license. This is a
**source-available** license, not an OSI-approved open source license.
