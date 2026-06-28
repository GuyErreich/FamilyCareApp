# UI Folder Agent Notes

Search `src/components/ui/` before creating UI elsewhere.

- Cross-app primitives: `common/`
- Domain UI: `schedule/`, `shifts/`, `family/`, `settings/`
- Responsive variants: `common/`, `mobile/`, `desktop/` under a domain when layout diverges

Skills: `code/web/ui`, `project/ux`, `project/schedule` for planner/month behavior.

## Standard primitives (`common/`)

Reuse these instead of raw class names or one-off markup:

| Component | Use for |
|---|---|
| `Button` | All actions — `primary` / `secondary` / `danger`, loading, icon |
| `IconButton` | Icon-only controls (toolbar, dismiss) |
| `Card` | Grouped content surfaces |
| `Stack` | Vertical spacing (`gap`, optional `stagger`) |
| `FormStack` | Forms with standard vertical spacing |
| `FormPage` | Full-page form shell (bottom padding for action bar) |
| `FormActionBar` | Fixed Save/Delete row above tab bar |
| `SegmentedControl` | Two-or-more-option toggles (Shift/Unavailable, Month/Year, etc.) |
| `MemberChipPicker` | Companion selection chips |
| `WheelPicker` | iOS-style snap wheel for month/year and similar lists |
| `SheetCloseButton` | Cancel in sheets — press feedback, then exit animation |
| `BottomSheet` | Modal sheets portaled above tab bar |
| `TextField` / `TextInput` / `TextArea` | Labelled inputs |

`PrimaryButton` is a deprecated alias for `Button` — prefer `Button` in new code.

Do **not** use raw `className="btn"`, `segmented-control`, or `member-chip` in feature code; compose the components above.
