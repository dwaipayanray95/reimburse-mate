# RELEASE.md — cutting a release

This documents how Reimburse Mate is versioned, signed, and shipped. Read this before
your first release, and follow it every time after.

## Versioning

`pubspec.yaml`'s `version:` field is the single source of truth:

```
version: 1.1.5+2
         ^^^^^ ^
         |     └─ build number (versionCode on Android) — must strictly increase
         |         on every single upload to Play Console, forever, even across
         |         different tracks (internal/closed/open/production)
         └─ version name (versionName on Android, what users see) — bump this
             following semver-ish rules: patch for fixes, minor for new features,
             major for breaking/large changes
```

`android/app/build.gradle.kts` reads `versionCode`/`versionName` from this
automatically (`flutter.versionCode`, `flutter.versionName`) — you only ever edit
`pubspec.yaml`.

**Before every release:** bump both the version name (if warranted) and always bump
the build number. Never reuse or decrease a build number — Play Console will reject
the upload outright if you do.

## App signing

Reimburse Mate uses **Play App Signing** (Google's recommended model, and mandatory
for all apps first published after August 2021). You sign release builds with an
**upload key**; Google re-signs the distributed app with its own managed **app
signing key**, which is what stays stable across all future updates.

### One-time setup (do this before the first release)

1. Generate the upload keystore (run this yourself — don't paste the output/passwords
   anywhere, including into an AI assistant):

   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload
   ```

   You'll be prompted for a keystore password, your name/org details, and a key
   password (can be the same as the keystore password). **Store the `.jks` file and
   both passwords in a password manager immediately** — see the "storing secrets"
   note below.

2. Create `android/key.properties` (already gitignored — never commit this):

   ```properties
   storePassword=<your keystore password>
   keyPassword=<your key password>
   keyAlias=upload
   storeFile=/absolute/path/to/upload-keystore.jks
   ```

3. Wire it into `android/app/build.gradle.kts`'s `signingConfigs` block (release
   builds should use this instead of the debug config) — ask for help here if this
   hasn't been done yet, it's a small, one-time code change.

4. First upload: build a release App Bundle and upload it manually through Play
   Console. During that first upload, Play Console will ask you to opt into Play App
   Signing — accept it. From then on, every build you upload (signed with your upload
   key) gets automatically re-signed by Google before reaching users.

### Storing the upload keystore

- Primary copy: a password manager (1Password/Bitwarden), as a secure file
  attachment, alongside both passwords.
- At least one independent backup copy (encrypted cloud backup, or offline), not
  solely on your primary dev machine.
- Never commit `upload-keystore.jks` or `key.properties` to git. Both should already
  be covered by `.gitignore` — double-check before your first `git add` involving
  these files.
- If lost *after* the first successful upload: contact Google Play Console support to
  reset your upload key. Your app's actual signing identity (the app signing key) is
  unaffected, since Google holds that one, not you.

## Build & release checklist

1. Bump `version:` in `pubspec.yaml` (see Versioning above)
2. Update `CHANGELOG.md` with what's new in this version
3. `flutter analyze` — must be clean (no errors)
4. `flutter build appbundle --release` — produces
   `build/app/outputs/bundle/release/app-release.aab`
5. Smoke-test the release build on a real device if this is a meaningful change:
   `flutter install --release` or sideload the built APK
6. Upload the `.aab` to the appropriate Play Console track (Internal testing first for
   anything non-trivial, promote to Production once verified)
7. Tag the release in git: `git tag v1.1.5 && git push --tags`

## CI (planned)

Not yet set up. The intended shape: a GitHub Actions workflow triggered on
`v*` tag pushes that runs `flutter analyze`, then `flutter build appbundle --release`
using a base64-encoded upload keystore + passwords stored as GitHub Encrypted
Secrets, and attaches the resulting `.aab` as a workflow artifact (manual upload to
Play Console for now; automating the actual Play Console upload via the Play
Developer API/fastlane can come later once the manual process is proven a few times).

## Play Console housekeeping

- Data Safety form: keep this in sync with `docs/PRIVACY_POLICY.md` — if what the app
  collects/does ever changes, update both together.
- Store listing privacy policy URL: must point to a **publicly hosted** copy of
  `docs/PRIVACY_POLICY.md` (e.g. GitHub Pages), not the raw GitHub file view.
- Target API level: Play Console enforces a minimum `targetSdk` on a rolling basis
  (currently Android 14/API 34 minimum as of writing, moving to 35). Keep
  `android/app/build.gradle.kts`'s `targetSdk` current — see
  `docs/GOTCHAS.md` for what happens when this falls behind (black status bar scrim
  on newer Android versions was one real symptom of this).
