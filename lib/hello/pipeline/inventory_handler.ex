defmodule Hello.Pipeline.InventoryHandler do

  import Ecto.Query

  alias Hello.Catalog.Location
  alias Hello.{ItemService, MerchantService, OptionService, ProductService}
  alias Hello.Repo

  def item_add(%{"event" => "item_add", "merchant_id" => merchant_id, "product_name" => product_name} = _data) do
    merchant = MerchantService.merchant_get!(merchant_id)

    # find or create product

    {:ok, product} = ProductService.product_find_or_create(merchant.id, product_name)

    # create option

    [pkg_size] = OptionService.option_pkg_sizes_random(1)
    [pkg_count] = OptionService.option_pkg_counts_random(1)
    option_name = "#{product.name} - #{pkg_size} - #{pkg_count}"

    {:ok, option} = OptionService.option_create(%{name: option_name, pkg_count: pkg_count, pkg_size: pkg_size, product_id: product.id})

    # get random location

    location = Enum.random(Repo.all(from o in Location))

    %{
      item_name: item_name,
      item_price: item_price,
      item_sku: item_sku,
      lot_id: lot_id,
    } = ItemService.item_create_props(product, option, location)

    {:ok, item} = ItemService.item_create(%{
      loc_name: location.slug,
      lot_id: lot_id,
      merchant_id: merchant.id,
      name: item_name,
      option_id: option.id,
      price: item_price,
      product_id: product.id,
      qavail: :rand.uniform(1000),
      sku: item_sku,
      tags: [],
    })

    Phoenix.PubSub.broadcast(Hello.PubSub, _merchant_topic(merchant.id), %{event: "item_add", id: item.id})

    :ok
  end

  defp _merchant_topic(merchant_id) do
    "merchant:#{merchant_id}"
  end

end
