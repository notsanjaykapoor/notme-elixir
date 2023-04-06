defmodule Hello.Catalog.MerchantSearch do
  @moduledoc """
  The Catalog MerchantSearch context.
  """

  alias Hello.Catalog.Merchant
  alias Hello.Catalog.Search
  alias Hello.Repo

  import Ecto.Query

  def search(search_query, limit_, offset_) do
    {:ok, clauses} = Search.search_clauses(search_query)

    _query_base()
    |> _query_build(clauses)
    |> _query_sort()
    |> limit(^limit_)
    |> offset(^offset_)
    |> Repo.all
  end

  def _query_base() do
    from o in Merchant
  end

  def _query_build(query, clauses) do
    Enum.reduce(clauses, query, &_query_compose/2)
  end

  def _query_compose([x, "id", value], query) do
    _query_compose([x, "ids", value], query)
  end

  def _query_compose([_, "ids", value], query) do
    ids = String.split(value, ",")
      |> Enum.map(&String.to_integer/1)
    where(query, [o], o.id in ^ids)
  end

  def _query_compose([x, "merchant", value], query) do
    _query_compose([x, "ids", value], query)
  end

  def _query_compose([x, "merchants", value], query) do
    _query_compose([x, "ids", value], query)
  end

  def _query_compose([_, "name", value], query) do
    value_normalized = String.trim(value)
      |> String.replace("-", " ")
    where(query, [o], ilike(o.name, ^"%#{value_normalized}%"))
  end

  def _query_sort(query) do
    order_by(query, [o], [asc: o.id])
  end
end
