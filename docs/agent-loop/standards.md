# Coding Standards for Agentic Projects

These standards apply to **all code written or modified in any trial repository**. They are derived from technical debt patterns observed in prior runs and are enforced proactively, not retrospectively. Before closing any task, verify that all code you have touched (and any related code you encountered) conforms to these rules.

---

## 1. No Magic Strings or Numbers Inline

**Rule:** Every string or numeric literal that encodes configuration, identity, or behaviour must be assigned to a named constant before use. Inline literals are only acceptable for values that are intrinsically local (e.g. `0`, `''` as empty sentinels, or a one-off `console.log`).

**Applies to:** UI colours, URL paths, API route names, query parameter keys, CSV column header names, batch sizes, window durations, HTTP status codes, error code strings.

**Pattern:**
```ts
// ❌ Forbidden
const colour = '#dc2626';
const limit = 1000;
const column = record['CRASH DATE'];

// ✅ Required
const MARKER_COLOR_FATAL = '#dc2626';
const BATCH_SIZE = 1000;
const CSV_COLUMNS = { CRASH_DATE: 'CRASH DATE' } as const;
```

**Search instruction:** Before closing a task, run a grep for repeated string/numeric literals across the entire codebase to catch all instances, not just the file you are editing.

---

## 2. Constants Belong at Module Scope

**Rule:** Named constants must be declared at the top level of their module, not inside function bodies. A constant scoped inside a function is invisible to callers, cannot be documented centrally, and risks being silently shadowed.

**Exception:** A value that is genuinely local to a single call (e.g. a `const result = ...` intermediate) may remain local.

**Pattern:**
```ts
// ❌ Forbidden
function saveCollisions(collisions: CollisionDTO[]) {
  const BATCH_SIZE = 1000; // hidden inside function
  ...
}

// ✅ Required
const BATCH_SIZE = 1000;

function saveCollisions(collisions: CollisionDTO[]) { ... }
```

---

## 3. No `any` Without Explicit Justification

**Rule:** TypeScript `any` casts are forbidden unless the type boundary is genuinely unknowable at compile time (e.g. an untyped third-party callback). Every `any` must be accompanied by a comment explaining why a typed alternative is not possible.

**Pattern:**
```ts
// ❌ Forbidden
records.map((record: any) => ...)

// ✅ Required — define the raw shape at the parse boundary
interface CsvRow { [key: string]: string | undefined }
records.map((record: CsvRow) => ...)

// ✅ Acceptable only with justification
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const value = externalLib.getData() as any; // externalLib has no types published
```

**Search instruction:** Before closing a task, grep for `: any` and `as any` across the entire codebase, not only the files you touched.

---

## 4. One Canonical Definition Per Type

**Rule:** Interfaces, types, and enums must be defined in exactly one place and re-exported by any module that needs them. Duplicate definitions that happen to be structurally identical today will silently diverge over time.

**Canonical location:** `src/models/` for domain types shared between backend and frontend. Module-local types that are genuinely not shared may remain local.

**Pattern:**
```ts
// ❌ Forbidden — same interface in two files
// src/services/CollisionRepository.ts
export interface DateRangeMetadata { dateStart: string; dateEnd: string; }

// src/frontend/collisionsApi.ts
export interface DateRangeMetadata { dateStart: string; dateEnd: string; }

// ✅ Required — single source of truth
// src/models/DateRangeMetadata.ts
export interface DateRangeMetadata { dateStart: string; dateEnd: string; }

// consumers re-export or import directly
import type { DateRangeMetadata } from '../models/DateRangeMetadata';
```

**Search instruction:** Before closing a task, search the entire codebase for the name of any interface or type you are working with to confirm it is not already defined elsewhere.

---

## 5. No Duplicated Logic — Shared Helpers Over Copy-Paste

**Rule:** If two functions share more than two lines of identical logic, extract the shared logic into a private helper and have both delegates call it. Copy-pasted guards diverge silently.

**Pattern:**
```ts
// ❌ Forbidden — identical extraction logic duplicated
function createFormFilters(initialFilters) {
  const borough = initialFilters.borough ?? '';
  const dateStart = initialFilters.dateStart ?? '';
  ...
}
function createAnchoredFormFilters(initialFilters, anchor) {
  const borough = initialFilters.borough ?? '';
  const dateStart = initialFilters.dateStart ?? '';
  ...
}

// ✅ Required — one private helper, two callers
function extractRawFilters(initialFilters) {
  return { borough: ..., dateStart: ..., dateEnd: ... };
}
function createFormFilters(initialFilters) { return { ...extractRawFilters(initialFilters), ... }; }
function createAnchoredFormFilters(initialFilters, anchor) { return { ...extractRawFilters(initialFilters), ... }; }
```

---

## 6. API Responses Must Have a Size Cap

**Rule:** Every list endpoint must enforce a `MAX_RESULTS` limit at the repository layer. An uncapped query over a large dataset will degrade or crash the browser. When the result set is truncated, the response envelope must signal this explicitly so the UI can warn the user.

**Pattern:**
```ts
// ❌ Forbidden — unbounded query
return prisma.collision.findMany({ where });

// ✅ Required — capped with truncation signal
const MAX_RESULTS = 5000;
const rows = await prisma.collision.findMany({ where, take: MAX_RESULTS + 1 });
const truncated = rows.length > MAX_RESULTS;
return { results: rows.slice(0, MAX_RESULTS), truncated };
```

---

## 7. Scope Technical Debt Items as Rules, Not Spot-Fixes

**Rule:** When adding a technical debt backlog item, always instruct the agent to search the *entire codebase* for all instances of the described pattern before making any change. A cited example is a **starting point**, not the complete scope.

**Template wording:**
> **Before making any change, search the entire codebase for all instances of [pattern].** The file/line cited below is a known example, not an exhaustive list.
