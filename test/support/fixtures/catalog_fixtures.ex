defmodule Hello.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hello.Catalog` context.
  """

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

    {:ok, variant} =
      attrs
      |> Enum.into(%{
        lots: [],
        name: "some name",
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
