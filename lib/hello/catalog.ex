defmodule Hello.Catalog do
  @moduledoc """
  The Catalog context.
  """

  import Ecto.Query, warn: false

  alias Hello.Repo
  alias Hello.Catalog.Item
  alias Hello.Catalog.ItemSearch
  alias Hello.Catalog.Location
  alias Hello.Catalog.Merchant
  alias Hello.Catalog.MerchantSearch
  alias Hello.Catalog.Option
  alias Hello.Catalog.OptionSearch
  alias Hello.Catalog.Product
  alias Hello.Catalog.ProductSearch

  def location_create(attrs \\ %{}) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  def location_find_or_create(name) do
    location = location_get_by_name(name)

    if location do
      {:ok, location}
    else
      slug = name
      |> String.replace(" ", "-")
      |> String.downcase()

      location_create(%{name: name, slug: slug})
    end
  end

  def location_get_by_name(name) do
    Repo.get_by(Location, [name: name])
  end

  def merchant_create(attrs \\ %{}) do
    %Merchant{}
    |> Merchant.changeset(attrs)
    |> Repo.insert()
  end

  def merchant_find_or_create(name) do
    merchant = merchant_get_by_name(name)

    if merchant do
      {:ok, merchant}
    else
      slug = name
      |> String.replace(",", "")
      |> String.replace(" ", "-")
      |> String.downcase()

      merchant_create(%{name: name, slug: slug, state: "active"})
    end
  end

  def merchant_get_by_name(name) do
    Repo.get_by(Merchant, [name: name])
  end

  def merchants_list(params \\ %{}) do
    query_params = Map.get(params, "query", "")
    query_limit = Map.get(params, "limit", 50)
    query_offset = Map.get(params, "offset", 0)

    merchants = MerchantSearch.search(query_params, query_limit, query_offset)

    merchants = for merchant <- merchants do
      products_count = Repo.one(from o in Product, where: o.merchant_id == ^merchant.id, select: count("*"))
      %{merchant | products_count: products_count}
    end

    merchants
  end

  @spec option_create(:invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          any
  def option_create(attrs \\ %{}) do
    %Option{}
    |> Option.changeset(attrs)
    |> Repo.insert()
  end

  def option_get_by_pkg(pkg_size, pkg_count) do
    Repo.get_by(Option, [pkg_size: pkg_size, pkg_count: pkg_count])
  end

  def options_list(params \\ %{}) do
    query_params = Map.get(params, "query", "")
    query_limit = Map.get(params, "limit", 50)
    query_offset = Map.get(params, "offset", 0)

    options = OptionSearch.search(query_params, query_limit, query_offset)

    options = for option <- options do
      items_count = Repo.one(from v in Item, where: v.option_id == ^option.id, select: count("*"))
      %{option | items_count: items_count}
    end

    options
  end

  @doc """
  Returns the list of products.

  ## Examples

      iex> products_list()
      [%Product{}, ...]

  """
  def products_list(params \\ %{}) do
    query_params = Map.get(params, "query", "")
    query_limit = Map.get(params, "limit", 50)
    query_offset = Map.get(params, "offset", 0)

    products = ProductSearch.search(query_params, query_limit, query_offset)
    products = for product <- products do
      options_count = Repo.one(from o in Option, where: o.product_id == ^product.id, select: count("*"))
      items_count = Repo.one(from o in Item, where: o.product_id == ^product.id, select: count("*"))
      %{product | options_count: options_count, items_count: items_count}
    end

    products
  end


  @doc """
  Creates a product.

  ## Examples

      iex> product_create(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def product_create(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

    @doc """
  Deletes a product.

  ## Examples

      iex> product_delete(product)
      {:ok, %Product{}}

      iex> product_delete(product)
      {:error, %Ecto.Changeset{}}

  """
  def product_delete(%Product{} = product) do
    Repo.delete(product)
  end

  def product_find_or_create(merchant_id, name, price \\ :rand.uniform(10000)) do
    product = product_get_by_name(merchant_id, name)

    if product do
      {:ok, product}
    else
      product_create(%{merchant_id: merchant_id, name: name, price: price, views: 0})
    end
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> product_get!(123)
      %Product{}

      iex> product_get!(456)
      ** (Ecto.NoResultsError)

  """
  def product_get!(id) do
    Repo.get!(Product, id)
  end

  def product_get_by_name(merchant_id, name) do
    Repo.get_by(Product, [merchant_id: merchant_id, name: name])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> product_change(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def product_change(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  def product_inc_page_view(%Product{} = product) do
    {1, [views]} = Repo.update_all((from p in Product, where: p.id == ^product.id, select: p.views), inc: [views: 1])
    put_in(product.views, views)
  end

  @doc """
  Updates a product.

  ## Examples

      iex> product_update(product, %{field: new_value})
      {:ok, %Product{}}

      iex> product_update(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def product_update(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  alias Hello.Catalog.Item

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
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> item_change(item)
      %Ecto.Changeset{data: %item{}}

  """
  def item_change(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end
end
