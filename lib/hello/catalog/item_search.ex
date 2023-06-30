defmodule Hello.Catalog.ItemSearch do
  @moduledoc """
  The Catalog ItemSearch context.
  """

  alias Hello.Catalog.{Item, Search, SearchPage}
  alias Hello.Repo

  import Ecto.Query

  @spec search(binary, number, number) :: %Hello.Catalog.SearchPage{
          count: non_neg_integer,
          limit: number,
          objects: list,
          offset: number,
          offset_nxt: 0,
          offset_prv: 0,
          total: any
        }
  def search(search_query, limit_, offset_) do
    {:ok, clauses} = Search.search_clauses(search_query)

    query = _query_base()
    |> _query_build(clauses)

    items = query
    |> _query_sort()
    |> limit(^limit_)
    |> offset(^offset_)
    |> Repo.all

    total = query
    |> _query_count()
    |> Repo.one

    %SearchPage{
      count: length(items),
      limit: limit_,
      objects: items,
      offset: offset_,
      offset_nxt: _offset_next(offset_, limit_, total),
      offset_prv: _offset_prev(offset_, limit_),
      total: total,
    }
  end

  def _offset_next(offset, limit, total) do
    if (offset + limit) < total do
      offset + limit
    else
      0
    end
  end

  def _offset_prev(offset, limit) do
    if (offset - limit) >= 0 do
      offset - limit
    else
      -1
    end
  end

  @spec _query_base() :: Ecto.Query.t()
  def _query_base() do
    from o in Item
  end

  @spec _query_build(Ecto.Query.t(), list) :: Ecto.Query.t()
  def _query_build(query, clauses) do
    Enum.reduce(clauses, query, &_query_compose/2)
  end

  @spec _query_compose(list, Ecto.Query.t()) :: Ecto.Query.t()
  def _query_compose([x, "lot", value], query) do
    _query_compose([x, "lots", value], query)
  end

  def _query_compose([_, "lots", value], query) do
    ids = String.split(value, ",")
    |> Enum.map(&String.to_integer/1)

    where(query, [o], fragment("? && ?", ^ids, o.lot_ids))
  end

  def _query_compose([x, "merchant", value], query) do
    _query_compose([x, "merchants", value], query)
  end

  def _query_compose([_, "merchants", value], query) do
    ids = String.split(value, ",")
    |> Enum.map(&String.to_integer/1)

    where(query, [o], o.merchant_id in ^ids)
  end

  def _query_compose([_, "name", value], query) do
    values_normalized = String.split(value, "+")
    |> Enum.map(fn s -> String.trim(s) end)
    |> Enum.map(fn s -> String.replace(s, "-", " ") end)
    |> Enum.join("|")

    where(query, [o], fragment("lower(name) similar to ?", ^"%(#{values_normalized})%"))
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

  def _query_compose([_, "sort", "random"], query) do
    order_by(query, [o], fragment("RANDOM()"))
  end

  def _query_compose([x, "tag", value], query) do
    _query_compose([x, "tags", value], query)
  end

  def _query_compose([_, "tags", value], query) do
    tags_list = String.split(value, ",")
    where(query, [o], fragment("? && ?", ^tags_list, o.tags))
  end

  def _query_compose([_, "~tags", value], query) do
    where(query, [o], ^value not in o.tags)
  end

  def _query_count(query) do
    select(query, [o], count(o.id))
  end

  @spec _query_sort(Ecto.Query.t()) :: Ecto.Query.t()
  def _query_sort(query) do
    order_by(query, [o], [desc: o.id])
  end
end
