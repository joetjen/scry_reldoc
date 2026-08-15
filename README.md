# Scry.Reldoc

The `relational` + `document` composite kind for Scry -- the canonical dependency name for an application combining a
relational-shaped query (nested-`SELECT` correlation, Scry's own `JOIN` equivalent) with
`DEEP`/`PARENT`/`SIBLINGS`/`ANCESTORS`.

`relational` is a degenerate kind (no grammar of its own), so this package is a thin
delegate to `scry_document`, not a fused executor -- `Scry.Reldoc.parse/1`/`Scry.Reldoc.
Executor.run/3` call straight through to `Scry.Document`'s own.

**That delegation only actually works because of a real fix, not because it was already
true.** `Scry.Document.Executor`'s own `project_body/4` used to hand a nested `SELECT`
body item (Scry's own `JOIN` equivalent) straight to `Scry.Core.QueryOps.run_flat/3` --
which is explicitly "flat" and has no clause for a bare nested `%Scry.Core.Query{}` at
all, so it crashed with a real `FunctionClauseError`, found building this very package.
Fixed at the source, in `scry_document` itself (via `scry_core`'s new
`Scry.Core.QueryOps.resolve_correlated_nested/5`) -- see that package's own
`CHANGELOG.md` for the full mechanics, and this package's own `CHANGELOG.md`/`Scry.
Reldoc`'s moduledoc for the "what we confirmed, not just assumed" story, including a
genuine, pre-existing `scry_core` correlation limit that surfaced along the way:
correlation only ever matches the *last* segment of a multi-segment document source
(`fiction.id` against a `catalog.fiction` source, not `catalog.fiction.id`).
