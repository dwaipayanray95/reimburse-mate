# Reimburse Mate

_Reimburse Mate_ is a tiny iOS app to track and file your personal reimbursements.

It lets you quickly log each expense with project code, amount, location and both
the **invoice** and **payment screenshot**, then batch-export everything as a
single ZIP you can attach to an email (e.g. `accounts@tcustudios.com`).

Built with **SwiftUI + SwiftData** for iOS 17+.

---

## Features

### Logging

- **Fast add form**
  - Date & time (editable)
  - Project code (e.g. `ACC-2025-07`)
  - Expense description
  - Amount in INR
- **Images**
  - Separate **Invoice** and **Payment** images
  - Choose from Photos **or** capture from rear camera
  - Images are aggressively downscaled and JPEG-compressed to keep the DB and
    exports small
- **Location**
  - One-tap “Use current location”
  - Stores both human-readable place name and coordinates
- All new entries start as **“Yet to Claim”** (unclaimed)

### Browsing & Management

- **Tab bar**
  - `Log` – add new reimbursement
  - `All` – list all reimbursements
- **List view**
  - Shows thumbnail, project code, description, amount, place & status tag
  - Filter by status: `All / Yet to Claim / Claimed`
  - Text search across project code, note and place name
  - Swipe to delete entries
- **Detail view**
  - Side-by-side thumbnails for **Invoice** and **Payment**
  - Tap to open **full-screen, zoomable** preview
  - Shows date, project, amount, place, coordinates and current status
  - “Copy text” button for description
  - One-tap toggle between **Claimed / Yet to Claim**
  - Delete entry with confirmation

### Claiming & Export

- **Claim all unclaimed**
  - From the `All` tab, tap **Claim Unclaimed**
  - Builds a ZIP on a background queue:
    - `reimbursements.csv` with all visible unclaimed entries
    - One summary `.txt` per entry
    - Invoice and payment images per entry (`*-invoice.jpg`, `*-payment.jpg`)
  - Opens **Mail composer** to `accounts@tcustudios.com` when available,
    otherwise falls back to the system share sheet
  - After a successful send/share, all included entries are auto-marked **Claimed**
- **Share a single entry**
  - From the detail screen, tap the share icon
  - Builds a small ZIP containing:
    - `reimbursement.csv` with just that entry
    - A summary `.txt`
    - Invoice & payment images
  - Again prefers Mail, falls back to the share sheet

### Extras

Accessible via the **info (i)** button on the Log screen.

- **Donate (UPI)**
  - Shows a UPI deep link and QR for `9916268695@ptaxis`
  - “Pay via UPI” button opens the UPI link in a compatible app
- **Changelog**
  - In-app view of all versions and what changed
  - Latest version: **v0.54**
- **Open Source**
  - Link to this repo:  
    `https://github.com/dwaipayanray95/reimburse-mate`

---

## Requirements

- Xcode 16+ (or 15.4+ with iOS 17 SDK)
- iOS 17+ (deployment target)
- SwiftUI
- SwiftData enabled for the target

---

## Getting Started

1. **Clone**

   ```bash
   git clone https://github.com/dwaipayanray95/reimburse-mate.git
   cd reimburse-mate
