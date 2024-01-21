defmodule Notme.MerchantService do

  import Ecto.Query, warn: false

  alias Notme.Catalog.{Merchant, MerchantSearch, Product}
  alias Notme.Repo

  require OpenTelemetry.Tracer, as: Tracer

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

  def merchant_get!(id) do
    Repo.get!(Merchant, id)
  end

  def merchant_get_by_name(name) do
    Repo.get_by(Merchant, [name: name])
  end

  @spec merchants_list(map) :: list(Merchant)
  def merchants_list(params \\ %{}) do
    Tracer.with_span("merchant_service.merchants_list") do
      query_params = Map.get(params, "query", "")
      query_limit = Map.get(params, "limit", 50)
      query_offset = Map.get(params, "offset", 0)

      Tracer.set_attributes([{:query_params, query_params}])

      merchant_product_map = _merchant_product_map()

      merchants = MerchantSearch.search(query_params, query_limit, query_offset)

      merchants = for merchant <- merchants do
        products_count = Map.get(merchant_product_map, merchant.id, 0)
        %{merchant | products_count: products_count}
      end

      merchants
    end
  end

  defp _merchant_product_map() do
    merchant_product_list = Product
      |> select([o], {o.merchant_id, count(o.id)})
      |> group_by([o], o.merchant_id)
      |> Repo.all

    Enum.into(merchant_product_list, %{})
  end

end
