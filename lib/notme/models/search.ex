defmodule Notme.Model.Search do

  @spec search_clauses(String.t) :: {:ok, list}
  def search_clauses(search_query) do
    clauses = Regex.scan(~r/([a-z_~]+):\s*([a-z0-9,+-]+)/, search_query)

    case length(clauses) do
      0 -> # default clause uses name field
        {:ok, [["name:#{search_query}", "name", search_query]]}
      _ ->
        {:ok, clauses}
    end
  end

end
