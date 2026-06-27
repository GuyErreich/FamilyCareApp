# Feedback & States

## Every interaction

| Action | Expected feedback |
|---|---|
| Tab / nav item | Haptic light impact + indicator animation |
| Card tap | `AppCard` scale + ink (if Material ancestor) |
| Primary CTA | `FilledButton` theme animation |
| Confirm bar appear | Slide up + fade (`AppMotion.spring`) |
| Route push | Fade + slide (`fadeSlidePage`) |
| Destructive action | Confirm dialog; snackbar on success/failure |

## Async UI

Use `AsyncValueWidget` or explicit `.when()`:

| State | UX |
|---|---|
| Loading | `CircularProgressIndicator` centered, or skeleton if list |
| Error | Message + retry if applicable (`ErrorView`) |
| Empty | Short guidance text — what to do next (see schedule legend pattern) |
| Data | Content |

Avoid `loading: () => const SizedBox.shrink()` unless the section is truly optional chrome.

## Snackbars

- Use theme floating snackbars for confirmations and errors
- One sentence; no stacked duplicates for the same action

## Forms

- Disable submit while saving; show inline progress on button
- Surface validation next to the field, not only in snackbar
