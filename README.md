# Scry.Reldoc

The `relational` + `document` composite kind for [Scry](https://github.com/joetjen/scry)
(impl_spec.md §2/§6) -- the canonical dependency name for an application combining a
relational-shaped query (nested-`SELECT` correlation, Scry's own `JOIN` equivalent) with
`DEEP`/`PARENT`/`SIBLINGS`/`ANCESTORS`.

`relational` is a degenerate kind (no grammar of its own) and `Scry.Document.Executor`'s
own `project_body/4` already delegates any body item that isn't one of its own
pseudo-fields -- an ordinary field, a nested `SELECT` included -- straight to
`Scry.Core.QueryOps.run_flat/3`, core's own fully generic per-row projection. So this
package is a thin delegate to `scry_document`, not a fused executor. See `Scry.Reldoc`'s
own moduledoc, and `CHANGELOG.md`, for the full "what we confirmed, not just assumed"
reasoning.
