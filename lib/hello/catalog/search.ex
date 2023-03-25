defmodule Hello.Catalog.Search do
  @moduledoc """
  The Catalog Search context.
  """

  alias Hello.Catalog.Option
  alias Hello.Repo

  import Ecto.Query

  def search_clauses(search_query) do
    clauses = Regex.scan(~r/([a-z_~]+):\s*([a-z-0-9,]+)/, search_query)

    case length(clauses) do
      0 -> # default clause uses name field
        {:ok, [["name:#{search_query}", "name", search_query]]}
      _ ->
        {:ok, clauses}
    end
  end

end
