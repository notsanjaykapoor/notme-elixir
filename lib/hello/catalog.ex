defmodule Hello.Catalog do
  @moduledoc """
  The Catalog context.
  """

  import Ecto.Query, warn: false
  alias Hello.Repo
  alias Hello.Catalog.Product
  alias Hello.Catalog.Search
  alias Hello.Catalog.Variant

  @doc """
  Returns the list of products.

  ## Examples

      iex> products_list()
      [%Product{}, ...]

  """
  def products_list do
    Repo.all(Product)
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

  def product_find_or_create(name) do
    product = product_get_by_name(name)

    if product do
      {:ok, product}
    else
      random_price = :rand.uniform(10000)
      {:ok, _product} = product_create(%{name: name, price: random_price, views: 0})
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

  def product_get_by_name(name) do
    Repo.get_by(Product, [name: name])
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

  alias Hello.Catalog.Variant

  @doc """
  Returns the list of variants.

  ## Examples

      iex> variants_list()
      [%Variant{}, ...]

  """
  def variants_list(params \\ %{}) do
    search_query = get_in(params, ["query"]) || ""

    Search.search(search_query)
  end

  @doc """
  Gets a single variant.

  Raises `Ecto.NoResultsError` if the Variant does not exist.

  ## Examples

      iex> variant_get!(123)
      %Variant{}

      iex> variant_get!(456)
      ** (Ecto.NoResultsError)

  """
  def variant_get!(id) do
    Repo.get!(Variant, id)
  end

  def variant_get_by_name(name) do
    Repo.get_by(Variant, [name: name])
  end

  @doc """
  Creates a variant.

  ## Examples

      iex> variant_create(%{field: value})
      {:ok, %Variant{}}

      iex> variant_create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def variant_create(attrs \\ %{}) do
    %Variant{}
    |> Variant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a variant.

  ## Examples

      iex> variant_update(variant, %{field: new_value})
      {:ok, %Variant{}}

      iex> variant_update(variant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def variant_update(%Variant{} = variant, attrs) do
    variant
    |> Variant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a variant.

  ## Examples

      iex> variant_delete(variant)
      {:ok, %Variant{}}

      iex> variant_delete(variant)
      {:error, %Ecto.Changeset{}}

  """
  def variant_delete(%Variant{} = variant) do
    Repo.delete(variant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking variant changes.

  ## Examples

      iex> variant_change(variant)
      %Ecto.Changeset{data: %Variant{}}

  """
  def variant_change(%Variant{} = variant, attrs \\ %{}) do
    Variant.changeset(variant, attrs)
  end
end
