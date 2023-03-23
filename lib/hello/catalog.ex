defmodule Hello.Catalog do
  @moduledoc """
  The Catalog context.
  """

  import Ecto.Query, warn: false

  alias Hello.Repo
  alias Hello.Catalog.Location
  alias Hello.Catalog.Lot
  alias Hello.Catalog.Option
  alias Hello.Catalog.OptionSearch
  alias Hello.Catalog.Product
  alias Hello.Catalog.Variant
  alias Hello.Catalog.VariantSearch

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

  def lot_create(%Variant{} = variant, location, qavail) do
    attrs = %{location_id: location.id, qavail: qavail, variant_id: variant.id}

    {:ok, lot} = %Lot{}
      |> Lot.changeset(attrs)
      |> Repo.insert()

    variant_loc_ids = [location.id | variant.loc_ids]
    variant_loc_slugs = [location.slug | variant.loc_slugs]
    variant_lot_ids = [lot.id | variant.lot_ids]
    variant_qavail = qavail + variant.qavail
    variant_attrs = %{
      loc_ids: variant_loc_ids,
      loc_slugs: variant_loc_slugs,
      lot_ids: variant_lot_ids,
      qavail: variant_qavail
    }

    variant_update(variant, variant_attrs)

    {:ok, lot}
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

    # options = Repo.all(Option)

    options = for option <- options do
      variants_count = Repo.one(from v in Variant, where: v.option_id == ^option.id, select: count("*"))
      %{option | variants_count: variants_count}
    end

    options
  end

  @doc """
  Returns the list of products.

  ## Examples

      iex> products_list()
      [%Product{}, ...]

  """
  def products_list do
    products = Repo.all(Product)

    products = for product <- products do
      options_count = Repo.one(from o in Option, where: o.product_id == ^product.id, select: count("*"))
      variants_count = Repo.one(from v in Variant, where: v.product_id == ^product.id, select: count("*"))
      %{product | options_count: options_count, variants_count: variants_count}
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

  def product_find_or_create(name, price \\ :rand.uniform(10000)) do
    product = product_get_by_name(name)

    if product do
      {:ok, product}
    else
      product_create(%{name: name, price: price, views: 0})
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
    query_params = Map.get(params, "query", "")
    query_limit = Map.get(params, "limit", 50)
    query_offset = Map.get(params, "offset", 0)

    VariantSearch.search(query_params, query_limit, query_offset)
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
