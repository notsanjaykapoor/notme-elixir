defmodule Hello.ProductService do

  import Ecto.Query, warn: false

  alias Hello.Catalog.{Item, Option, Product, ProductSearch}
  alias Hello.Repo

  require OpenTelemetry.Tracer, as: Tracer

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> product_change(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def product_change(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
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

  @doc """
  Returns the list of products.

  ## Examples

      iex> products_list()
      [%Product{}, ...]

  """
  def products_list(params \\ %{}) do
    Tracer.with_span("product_service.products_list") do
      query_params = Map.get(params, "query", "")
      query_limit = Map.get(params, "limit", 50)
      query_offset = Map.get(params, "offset", 0)

      Tracer.set_attributes([{:query_params, query_params}])

      products = ProductSearch.search(query_params, query_limit, query_offset)
      products = for product <- products do
        options_count = Repo.one(from o in Option, where: o.product_id == ^product.id, select: count("*"))
        items_count = Repo.one(from o in Item, where: o.product_id == ^product.id, select: count("*"))
        %{product | options_count: options_count, items_count: items_count}
      end

      products
    end
  end

end
