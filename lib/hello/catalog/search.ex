defmodule Hello.Catalog.Search do
  @moduledoc """
  The Catalog Search context.
  """

  alias Hello.Catalog.Variant
  alias Hello.Repo

  import Ecto.Query

  def search(search_query) do
    {:ok, clauses} = _search_clauses(search_query)

    _query_base()
    |> _query_build(clauses)
    |> Repo.all
  end

  def _search_clauses(search_query) do
    clauses = Regex.scan(~r/([a-z_~]+):([a-z-0-9,]+)/, search_query)

    case length(clauses) do
      0 -> # default clause uses name field
        {:ok, [["name:#{search_query}", "name", search_query]]}
      _ ->
        {:ok, clauses}
    end
  end


  def _query_base() do
    from o in Variant
  end

  def _query_build(query, clauses) do
    Enum.reduce(clauses, query, &_query_compose/2)
  end

  def _query_compose([_, "name", value], query) do
    name_normalized = String.replace(value, "-", " ")
    where(query, [o], ilike(o.name, ^"%#{name_normalized}%"))
  end

  def _query_compose([_, "price_gte", value], query) do
    where(query, [o], o.price >= ^value)
  end

  def _query_compose([_, "price_lte", value], query) do
    where(query, [o], o.price <= ^value)
  end

  def _query_compose([_, "product", value], query) do
    where(query, [o], o.product_id == ^value)
  end

  def _query_compose([_, "tags", value], query) do
    tags_list = String.split(value, ",")
    where(query, [o], fragment("? && ?", ^tags_list, o.tags))
  end

  def _query_compose([_, "~tags", value], query) do
    where(query, [o], ^value not in o.tags)
  end
end
