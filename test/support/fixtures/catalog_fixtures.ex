defmodule Hello.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hello.Catalog` context.
  """

  def location_fixture(attrs \\ %{}) do
    {:ok, location} =
      attrs
      |> Enum.into(%{
        name: "location 1",
        slug: "location-1",
      })
      |> Hello.Catalog.location_create()

    location
  end

  def merchant_fixture(attrs \\ %{}) do
    {:ok, merchant} =
      attrs
      |> Enum.into(%{
        name: "Merchant",
        slug: "merchant-1",
        state: "active",
      })
      |> Hello.Catalog.merchant_create()

      merchant
  end

  def option_fixture(attrs \\ %{}) do
    {:ok, option} =
      attrs
      |> Enum.into(%{
        name: "option name",
        pkg_size: "1g",
        pkg_count: 1,
      })
      |> Hello.Catalog.option_create()

      option
  end

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        name: "some title",
        price: 120500,
        views: 0
      })
      |> Hello.Catalog.product_create()

    product
  end

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    merchant = merchant_fixture()
    product = product_fixture(%{merchant_id: merchant.id})
    option = option_fixture(%{product_id: product.id})

    {:ok, item} =
      attrs
      |> Enum.into(%{
        loc_name: "chicago 1",
        lot_id: ExULID.ULID.generate(),
        merchant_id: merchant.id,
        name: "some name",
        option_id: option.id,
        price: 42,
        product_id: product.id,
        qavail: 0,
        qsold: 0,
        tags: ["option1", "option2"]
      })
      |> Hello.Catalog.item_create()

    item
  end
end
