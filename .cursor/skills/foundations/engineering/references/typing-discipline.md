# Typing Discipline (TypeScript)

- Explicit types on hook return values, public exports, and Supabase row mapping.
- Use generated types from `database.types.ts` at boundaries.
- Handle errors explicitly — do not swallow failures as `null` without intent.
- Avoid `any` and unchecked casts from Supabase responses — validate or type-guard first.

Types document intent. If a type feels wrong, fix the design before adding optional chaining workarounds.
