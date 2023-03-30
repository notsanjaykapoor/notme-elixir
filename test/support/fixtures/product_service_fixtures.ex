defmodule Hello.ProductServiceFixtures do

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
      |> Hello.ProductService.product_create()

    product
  end

end
