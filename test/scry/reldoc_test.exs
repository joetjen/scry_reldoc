defmodule Scry.ReldocTest do
  @moduledoc """
  The real proof this composite doesn't need a fused executor: a
  relational-shaped nested-`SELECT` correlation (Scry's own `JOIN`
  equivalent) composed in the *same body* as `PARENT`, executed end to
  end against `Scry.Document.Conn` -- `Scry.Document.Executor`'s own
  `project_body/4` cleanly separates the two (`Scry.Reldoc`'s own
  moduledoc has the full mechanics), so a passing test here proves that
  separation actually holds, not just that it reads correctly.
  """

  use ExUnit.Case, async: true

  alias Scry.Core.Cursor
  alias Scry.Document.Conn

  @document %{
    ["catalog"] => [%{"name" => "Catalog"}],
    ["catalog", "fiction"] => [
      %{"id" => 1, "title" => "Book One"},
      %{"id" => 2, "title" => "Book Two"}
    ]
  }

  # An ordinary flat source, no document-tree nesting of its own --
  # correlated to catalog.fiction's own "id" the same way any ordinary
  # relational nested SELECT correlates to an outer row's own field.
  @reviews [
    %{"book_id" => 1, "stars" => 5},
    %{"book_id" => 2, "stars" => 3}
  ]

  defp conn, do: Conn.new(Map.put(@document, ["reviews"], @reviews))

  test "a correlated nested SELECT composes correctly alongside PARENT, in the same body" do
    # Correlation only ever matches against the *last* segment of the
    # enclosing query's own source (`Scry.Core.QueryOps.run_document/4`'s
    # own documented "not a two-or-more-segment path under the ancestor"
    # limit) -- `fiction.id`, not `catalog.fiction.id`, is the correct/
    # only way to correlate against this multi-segment document source.
    {:ok, query} =
      Scry.Reldoc.parse("""
      SELECT catalog.fiction ORDER BY id { title,
        PARENT { name },
        SELECT reviews WHERE book_id = fiction.id { stars }
      }
      """)

    assert {:ok, cursor} = Scry.Reldoc.Executor.run(query, conn())
    rows = Cursor.to_list(cursor)

    assert rows == [
             %{
               "title" => "Book One",
               "parent" => %{"name" => "Catalog"},
               "reviews" => [%{"stars" => 5}]
             },
             %{
               "title" => "Book Two",
               "parent" => %{"name" => "Catalog"},
               "reviews" => [%{"stars" => 3}]
             }
           ]
  end

  test "an ordinary query with no pseudo-field at all still works, unaffected" do
    {:ok, query} = Scry.Reldoc.parse("SELECT catalog.fiction ORDER BY id { title }")
    assert {:ok, cursor} = Scry.Reldoc.Executor.run(query, conn())

    assert Cursor.to_list(cursor) == [
             %{"title" => "Book One"},
             %{"title" => "Book Two"}
           ]
  end
end
