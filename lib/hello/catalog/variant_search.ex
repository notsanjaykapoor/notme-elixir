defmodule Hello.Catalog.VariantSearch do
  @moduledoc """
  The Catalog VariantSearch context.
  """

  alias Hello.Catalog.Variant
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
    from o in Variant
  end

  def _query_build(query, clauses) do
    Enum.reduce(clauses, query, &_query_compose/2)
  end

  def _query_compose([x, "lot", value], query) do
    _query_compose([x, "lots", value], query)
  end

  def _query_compose([_, "lots", value], query) do
    ids = String.split(value, ",")
      |> Enum.map(&String.to_integer/1)
    where(query, [o], fragment("? && ?", ^ids, o.lot_ids))
  end

  def _query_compose([_, "name", value], query) do
    value_normalized = String.trim(value)
      |> String.replace("-", " ")
    where(query, [o], ilike(o.name, ^"%#{value_normalized}%"))
  end

  def _query_compose([_, "options", value], query) do
    ids = String.split(value, ",")
      |> Enum.map(&String.to_integer/1)
    where(query, [o], o.option_id in ^ids)
  end

  def _query_compose([_, "price_gte", value], query) do
    where(query, [o], o.price >= ^value)
  end

  def _query_compose([_, "price_lte", value], query) do
    where(query, [o], o.price <= ^value)
  end

  def _query_compose([x, "product", value], query) do
    _query_compose([x, "products", value], query)
  end

  def _query_compose([_, "products", value], query) do
    ids = String.split(value, ",")
      |> Enum.map(&String.to_integer/1)
    where(query, [o], o.product_id in ^ids)
  end

  def _query_compose([_, "tags", value], query) do
    tags_list = String.split(value, ",")
    where(query, [o], fragment("? && ?", ^tags_list, o.tags))
  end

  def _query_compose([_, "~tags", value], query) do
    where(query, [o], ^value not in o.tags)
  end

  def _query_sort(query) do
    order_by(query, [o], o.id)
  end
end
