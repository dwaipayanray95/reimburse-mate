# CI actions

These composite GitHub Actions are vendored from
[dwaipayanray95/ez-github-scripts](https://github.com/dwaipayanray95/ez-github-scripts)
(same author, separate toolkit repo — Beerware licensed).

- `flutter-build` — runs `flutter analyze` + `flutter test`, builds and (if secrets are
  present) signs a release Android App Bundle/APK, uploads it as a workflow artifact
- `security-scan` — greps PR/push diffs for common leaked-credential patterns
- `license-guard` — checks `pubspec.lock` dependency licenses against an allow/block
  list (blocks copyleft licenses like GPL/AGPL by default)
- `pr-pilot` — labels PRs by size based on lines changed

`auto-changelog` and `ai-release-notes` from the source toolkit were intentionally
**not** vendored here — both assume a `package.json`/Node project for version
detection, which doesn't apply to this Flutter app, and `auto-changelog` would
overwrite the manually-curated `CHANGELOG.md` at the repo root on every tagged
release. `CHANGELOG.md` is maintained by hand.

To pull in an updated version of a vendored action, copy the relevant folder from
the source repo's `actions/<name>/` into `.github/actions/<name>/` here.

See `docs/RELEASE.md` for how these are wired into the actual workflows
(`.github/workflows/pr-checks.yml`, `.github/workflows/release.yml`) and what
repository secrets `release.yml` requires.
