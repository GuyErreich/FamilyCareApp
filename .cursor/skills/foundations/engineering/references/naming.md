# Naming

Names reveal responsibility. Use domain vocabulary consistently across features.

## File suffixes (this repo)

| Suffix | Meaning |
|---|---|
| `*Page.tsx` in `pages/` | Routable screen |
| `use*.ts` in `hooks/` | Data fetching, mutations, or feature state |
| `*.tsx` in `components/ui/common/` | App-wide reusable component |
| `*.tsx` in `components/ui/<domain>/` | Domain-specific UI |
| `*.ts` in `lib/` | Utilities, types, Supabase client, constants |

## TypeScript conventions

- Components and types: `PascalCase`
- Hooks: `use` prefix + `PascalCase` (`useShiftMutations`)
- Files: match primary export (`DashboardPage.tsx`, `useAuth.tsx`)
- Private helpers: module-local, not exported

## Domain terms

Use consistently: **shift**, **companion**, **family member**, **unavailability**, **slot selection**, **coverage**.

Avoid mixing synonyms (e.g. "caregiver" vs "companion") unless the UI string requires it.
