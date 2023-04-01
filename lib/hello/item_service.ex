defmodule Hello.ItemService do

  import Ecto.Query, warn: false

  alias Hello.Catalog.{Item, ItemSearch}
  alias Hello.Repo

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> item_change(item)
      %Ecto.Changeset{data: %item{}}

  """
  def item_change(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end

  @doc """
  Creates a item.

  ## Examples

      iex> item_create(%{field: value})
      {:ok, %Item{}}

      iex> item_create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def item_create(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> item_delete(item)
      {:ok, %Item{}}

      iex> item_delete(item)
      {:error, %Ecto.Changeset{}}

  """
  def item_delete(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> item_get!(123)
      %Item{}

      iex> item_get!(456)
      ** (Ecto.NoResultsError)

  """
  def item_get!(id) do
    Repo.get!(Item, id)
  end

  def item_get_by_name(name) do
    Repo.get_by(Item, [name: name])
  end

  def item_get_by_sku(sku) do
    Repo.get_by(Item, [sku: sku])
  end

  @doc """
  Updates a item.

  ## Examples

      iex> item_update(item, %{field: new_value})
      {:ok, %Item{}}

      iex> item_update(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def item_update(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns the list of items.

  ## Examples

      iex> items_list()
      [%Item{}, ...]

  """
  def items_list(params \\ %{}) do
    query_params = Map.get(params, "query", "")
    query_limit = Map.get(params, "limit", 100)
    query_offset = Map.get(params, "offset", 0)

    ItemSearch.search(query_params, query_limit, query_offset)
  end

end
