# `/migrate-to-shoehorn` — Migrate `as` Assertions to Shoehorn

## What it is

A skill that migrates test files with TypeScript `as` assertions to `@total-typescript/shoehorn`, a library that allows passing partial data in tests in a type-safe way.

## What it's for

- When your tests are full of `as Type` or `as unknown as Type`
- When you want to pass partial objects in tests without faking all properties
- For TypeScript tests where you need intentionally wrong data (to test errors)
- As part of a test code cleanup

**Important**: Only for test code. Never use shoehorn in production code.

## How to invoke

```
/migrate-to-shoehorn
```

## Why use it

Problems with `as` in tests:
- You were trained not to use `as`
- Need to manually specify the target type
- `as unknown as Type` is verbose for intentionally wrong data

### Comparison

**Before (with `as`):**
```ts
// Large object, only body.id matters
getUser({ body: { id: "123" } } as Request);

// Intentionally wrong data
getUser({ body: { id: 123 } } as unknown as Request);
```

**After (with shoehorn):**
```ts
import { fromPartial, fromAny } from "@total-typescript/shoehorn";

// Type-safe partial object
getUser(fromPartial({ body: { id: "123" } }));

// Intentionally wrong data, but with autocomplete
getUser(fromAny({ body: { id: 123 } }));
```

## How it works

### Available functions

| Function | Use |
|----------|-----|
| `fromPartial()` | Partial data that still type-checks |
| `fromAny()` | Intentionally wrong data (keeps autocomplete) |
| `fromExact()` | Forces complete object (swap with fromPartial later) |

### Process

**1. Collects requirements** — asks:
- Which test files have `as` assertions causing problems?
- Are they dealing with large objects where only a few properties matter?
- Do they need to pass intentionally wrong data for error tests?

**2. Installs and migrates:**
```bash
npm i @total-typescript/shoehorn
```

- Finds test files with `as` assertions:
  ```bash
  grep -r " as [A-Z]" --include="*.test.ts" --include="*.spec.ts"
  ```
- Replaces `as Type` with `fromPartial()`
- Replaces `as unknown as Type` with `fromAny()`
- Adds imports from `@total-typescript/shoehorn`
- Runs type check to verify

## Usage example

```
My tests have lots of `as Request` and `as unknown as Response`. I want to migrate to shoehorn.

/migrate-to-shoehorn
```

The agent will ask which files have the problem, install the lib, and do the migration with type checking at the end.
