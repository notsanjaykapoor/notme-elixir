defmodule Notme.Model.UserSearch do

  alias Notme.Model
  alias Notme.Repo
  alias Notme.Search

  import Ecto.Query

  @spec search(String.t, integer, integer) :: Enum.User
  def search(search_query, limit_, offset_) do
    {:ok, clauses} = Search.Base.search_clauses(search_query)

    _query_base()
    |> _query_build(clauses)
    |> _query_sort()
    |> limit(^limit_)
    |> offset(^offset_)
    |> Repo.all
  end

  @spec _query_base() :: Ecto.Query.t()
  def _query_base() do
    from o in Model.User
  end

  @spec _query_build(Ecto.Query.t(), list) :: Ecto.Query.t()
  def _query_build(query, clauses) do
    Enum.reduce(clauses, query, &_query_compose/2)
  end

  @spec _query_compose(list, Ecto.Query.t()) :: Ecto.Query.t()
  def _query_compose([x, "id", value], query) do
    _query_compose([x, "ids", value], query)
  end

  def _query_compose([_, "ids", value], query) do
    ids = String.split(value, ",")
      |> Enum.map(&String.to_integer/1)

    where(query, [o], o.id in ^ids)
  end

  def _query_compose([_, "email", value], query) do
    value_normalized = String.trim(value)
      |> String.replace("-", " ")

    where(query, [o], ilike(o.email, ^"%#{value_normalized}%"))
  end

  def _query_compose([_, "name", value], query) do
    value_normalized = String.trim(value)
      |> String.replace("-", " ")

    where(query, [o], ilike(o.email, ^"%#{value_normalized}%"))
  end

  def _query_compose([_, "state", value], query) do
    value_normalized = String.trim(value)
      |> String.replace("-", " ")

    where(query, [o], ilike(o.state, ^"%#{value_normalized}%"))
  end

  def _query_count(query) do
    select(query, [o], count(o.id))
  end

  @spec _query_sort(Ecto.Query.t()) :: Ecto.Query.t()
  def _query_sort(query) do
    order_by(query, [o], [asc: o.id])
  end
end
