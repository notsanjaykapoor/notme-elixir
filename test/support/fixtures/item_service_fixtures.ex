defmodule Notme.ItemServiceFixtures do

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    # merchant = merchant_fixture()
    # product = product_fixture(%{merchant_id: merchant.id})
    # option = option_fixture(%{product_id: product.id})

    {:ok, item} =
      attrs
      |> Enum.into(%{
        loc_name: "chicago 1",
        lot_id: ExULID.ULID.generate(),
        # merchant_id: merchant.id,
        name: "some name",
        # option_id: option.id,
        price: 42,
        # product_id: product.id,
        qavail: 0,
        qsold: 0,
        sku: "sku",
        tags: ["option1", "option2"]
      })
      |> Notme.Service.Item.item_create()

    item
  end

end
