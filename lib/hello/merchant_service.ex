defmodule Hello.MerchantService do

  import Ecto.Query, warn: false

  alias Hello.Catalog.{Merchant, MerchantSearch, Product}
  alias Hello.Repo

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

end
