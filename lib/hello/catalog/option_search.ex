defmodule Hello.Catalog.OptionSearch do
  @moduledoc """
  The Catalog OptionSearch context.
  """

  alias Hello.Catalog.Option
  alias Hello.Repo

  import Ecto.Query

  def search(search_query, limit_, offset_) do
    {:ok, clauses} = _search_clauses(search_query)

    _query_base()
    |> _query_build(clauses)
    |> _query_sort()
    |> limit(^limit_)
    |> offset(^offset_)
    |> Repo.all
  end

  def _search_clauses(search_query) do
    clauses = Regex.scan(~r/([a-z_~]+):\s*([a-z-0-9,]+)/, search_query)

    case length(clauses) do
      0 -> # default clause uses name field
        {:ok, [["name:#{search_query}", "name", search_query]]}
      _ ->
        {:ok, clauses}
    end
  end

  def _query_base() do
    from o in Option
  end

  def _query_build(query, clauses) do
    Enum.reduce(clauses, query, &_query_compose/2)
  end

  def _query_compose([_, "name", value], query) do
    value_normalized = String.trim(value)
      |> String.replace("-", " ")
    where(query, [o], ilike(o.name, ^"%#{value_normalized}%"))
  end

  def _query_sort(query) do
    order_by(query, [o], o.id)
  end
end
