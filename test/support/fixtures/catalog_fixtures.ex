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
  Generate a variant.
  """
  def variant_fixture(attrs \\ %{}) do
    product = product_fixture()
    option = option_fixture(%{product_id: product.id})

    {:ok, variant} =
      attrs
      |> Enum.into(%{
        loc_name: "chicago 1",
        lot_id: ExULID.ULID.generate(),
        name: "some name",
        option_id: option.id,
        price: 42,
        product_id: product.id,
        qavail: 0,
        qsold: 0,
        tags: ["option1", "option2"]
      })
      |> Hello.Catalog.variant_create()

    variant
  end
end
