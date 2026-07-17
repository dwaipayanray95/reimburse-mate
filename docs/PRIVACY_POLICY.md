# Privacy Policy — Reimburse Mate

**Last updated:** [DATE — fill in on first publish]

Reimburse Mate is a personal expense-tracking app. This policy explains what data the
app touches, where it goes, and what control you have over it.

## Summary

Reimburse Mate stores your data **only on your device**. There is no backend server,
no account system, and no analytics or tracking of any kind. The only place your data
ever leaves your device is when *you* choose to email or share a filing export — and
that goes through your own device's email/share apps, not through us.

## What data the app collects and stores

All of the following is stored **locally on your device only**, in a local SQLite
database and your device's app storage:

- Expense details you enter: date, project code, particulars/description, amount,
  currency, category, payment method
- Receipt/invoice photos or PDFs and payment proof images/PDFs you attach
- Settings you configure: your name, company name, default currency, default
  recipient email address, and email body template

None of this is transmitted to us or any third party by the app itself.

## Permissions the app requests, and why

| Permission | Why it's requested |
|---|---|
| **Camera** | To let you photograph a receipt or payment proof directly instead of picking an existing photo. Only used when you tap the camera option — the app never accesses the camera in the background. |
| **Photo library / documents access** | To let you attach an existing photo or PDF as a receipt or payment proof. |
| **Internet** | On-device text recognition (via Google's ML Kit) may need a one-time model download the first time OCR is used on a given device. No expense data, receipts, or personal information is sent anywhere as part of this — only the OCR model itself is downloaded, from Google's infrastructure, not ours. |

The app does **not** request location access.

## On-device OCR

Receipt scanning uses Google's ML Kit Text Recognition, which runs entirely on your
device. The image you scan is processed locally to extract text (amount, date,
vendor) — it is not uploaded anywhere as part of this process.

## Sharing / filing claims

When you use the "File Claims" feature:
- **"Save ZIP"** builds a ZIP file (a CSV summary plus your attached receipts) and
  hands it to your device's share sheet or saves it locally. This is entirely
  under your control — you choose the destination.
- **"Send via Mail"** opens your device's own email app (or share sheet as a
  fallback) with the ZIP/CSV attached and a pre-filled recipient, subject, and body,
  which you review before sending. The app does not send anything on your behalf
  without you completing that step yourself.

We (the developer) never receive a copy of anything you file — it goes directly from
your device to whatever email address or destination you choose.

## Data deletion

Since all data lives locally on your device, you control deletion entirely:
- Delete individual claims from within the app (Claim Detail → delete)
- Uninstalling the app removes all locally stored data, including the database and
  any saved receipt images, as with any Android/iOS app

There is no remote copy for us to delete, because none is ever created.

## Children's privacy

This app is not directed at children and does not knowingly collect data from
children. Since no data leaves the device, there is no data collection to speak of
in the first place.

## Changes to this policy

If this policy changes (e.g. a future version adds cloud sync or analytics), this
document will be updated and the "Last updated" date above will reflect that, before
such a change ships.

## Contact

Questions about this policy or the app can be sent to: **[SUPPORT EMAIL — TBD]**

---

*This policy is hosted at: [PUBLIC URL — TBD, e.g. a GitHub Pages link to this file]
and that URL is what should be entered in the Play Console "Privacy Policy" field.*
