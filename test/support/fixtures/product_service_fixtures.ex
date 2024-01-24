defmodule Notme.ProductServiceFixtures do

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
      |> Notme.Service.Product.product_create()

    product
  end

end
