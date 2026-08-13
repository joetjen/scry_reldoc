defmodule Scry.Reldoc.Executor do
  @moduledoc """
  A direct delegation to `Scry.Document.Executor.run/3` -- see
  `Scry.Reldoc`'s own moduledoc for why this composite needs no
  execution logic of its own at all.
  """

  alias Scry.Core.{Cursor, Query}
  alias Scry.Document.Conn

  @doc "Identical to `Scry.Document.Executor.run/3`."
  @spec run(Query.t() | Scry.Core.CombinedQuery.t(), Conn.t(), map()) ::
          {:ok, Cursor.t()} | {:error, term()}
  def run(query, conn, params \\ %{}) do
    Scry.Document.Executor.run(query, conn, params)
  end
end
