---
name: No 'any' type in TypeScript
description: Never use 'any' type — always create proper type interfaces instead
type: feedback
---

Never use `any` type for type declarations. Always create explicit type interfaces.

**Why:** Maintains type safety and code quality. `any` defeats the purpose of TypeScript's type system.

**How to apply:** When writing or modifying TypeScript code, define proper interfaces/types for all data structures. If the shape is unknown, use `unknown` with type guards or create a specific interface. This applies to function parameters, return types, variable declarations, and generic type arguments.
