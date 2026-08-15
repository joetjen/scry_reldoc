# Changelog

## [Unreleased]

### Added

- The `relational` + `document` composite kind -- a thin delegate, not a fused executor: `Scry.Reldoc.parse/1`/`Scry.Reldoc.Executor.run/3` both call straight through to `Scry.Document.parse/1`/`Scry.Document.Executor.run/3`. `relational` is a degenerate kind (no EP1/EP2 grammar/execution vocabulary of its own).
  **Building this found a real, pre-existing gap in `scry_document` itself, not already-working behavior**: `Scry.Document.Executor`'s own `run_flat/3` delegation is explicitly "flat" and genuinely could not resolve a nested `%Scry.Core.Query{}` body item at all -- a real `FunctionClauseError`, confirmed directly. Fixed at the source, in `scry_document` (via `scry_core`'s new `Scry.Core.QueryOps.resolve_correlated_nested/5`) -- see that package's own `CHANGELOG.md` for the full mechanics. Also surfaced a genuine, pre-existing `scry_core` correlation limit worth restating here since document sources are frequently multi-segment: correlation only ever matches against the *last* segment of the enclosing query's own source (`WHERE book_id = fiction.id` against a `catalog.fiction` source, not `WHERE book_id = catalog.fiction.id`).
  Confirmed with a real end-to-end test, not just asserted: a relational-shaped correlated nested `SELECT` (Scry's own `JOIN` equivalent) composes correctly alongside `PARENT`, in the same body.
  `test/scry/reldoc_test.exs`.
