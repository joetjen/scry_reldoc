defmodule Scry.Reldoc do
  @moduledoc """
  The `relational` + `document` composite kind for Scry -- a
  relational-shaped nested-`SELECT` correlation (Scry's own `JOIN`
  equivalent) alongside `DEEP`/`PARENT`/`SIBLINGS`/`ANCESTORS`.

  **A thin delegate, not a fused executor** -- unlike `scry_docgraph`
  (document + graph both bypass `Scry.Core.EngineBehaviour` with their
  own bespoke, whole-space-needing executors, each recognizing only its
  *own* `{:variant, ...}` tags, so composing them for real needs a
  genuinely new dispatcher), `relational` is a *degenerate* kind (§2:
  no EP1/EP2 grammar or execution vocabulary of its own at all), so
  once `Scry.Document.Executor` itself correctly resolves a nested
  `SELECT` body item sitting alongside `PARENT`/`SIBLINGS`/`ANCESTORS`,
  there is nothing left for this package to add.

  **That "once" was a real, found-not-assumed gap, not already true**:
  `Scry.Document.Executor`'s own `run_flat/3` delegation is explicitly
  "flat" and genuinely could not resolve a nested `%Scry.Core.Query{}`
  body item at all -- confirmed via a real `FunctionClauseError`
  building this very package, not assumed from reading the code. Fixed
  at the source, in `scry_document` itself (via `scry_core`'s new
  `Scry.Core.QueryOps.resolve_correlated_nested/5`) -- see that
  package's own `CHANGELOG.md` for the full story. This package's own
  end-to-end test is what actually proves the fix holds for the
  relational-plus-document combination specifically, not just asserted
  from the spec's own prose.

  `parse/1` mirrors `Scry.Document.parse/1` (there is no grammar
  fragment of this package's own to compose in); use `Scry.Document.
  Executor.run/3` directly to execute what it returns.
  """

  alias Scry.Core.{CombinedQuery, Query}

  @doc """
  Parses `source` (Scry query text) into a `%Scry.Core.Query{}` (or a
  `%Scry.Core.CombinedQuery{}`) -- a direct delegation to `Scry.
  Document.parse/1`, since this composite has no grammar fragment of
  its own: `relational` contributes nothing syntactically, so the
  merged grammar `scry_document` already ships *is* this composite's
  own grammar, unchanged.
  """
  @spec parse(String.t()) :: {:ok, Query.t() | CombinedQuery.t()} | {:error, term()}
  def parse(source) when is_binary(source) do
    Scry.Document.parse(source)
  end
end
