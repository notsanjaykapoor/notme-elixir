defmodule Hello.MessageConsumer do

  import Ecto.Query

  alias Hello.Catalog.{Location, Product}
  alias Hello.{ItemService, MerchantService, OptionService, OrderService, ProductService}
  alias Hello.Repo

  def handle_messages(messages) do
    for %{key: key, value: value_str} = message <- messages do
      IO.inspect(message) # debug

      {:ok, value} = Jason.decode(value_str)

      case key do
        "item_add" ->
          merchant = MerchantService.merchant_get!(value["merchant_id"])

          # find or create product

          {:ok, %Product{} = product} = ProductService.product_find_or_create(merchant.id, value["product_name"])

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
            tags: []
          })

          Phoenix.PubSub.broadcast(Hello.PubSub, _merchant_topic(merchant.id), %{event: "item_add", id: item.id})

        "order_add" ->
          item_id = value["id"]

          {:ok, item} = OrderService.order_create(item_id)

          IO.puts "message_consumer #{key} merchant #{item.merchant_id} item #{item_id}"

          Phoenix.PubSub.broadcast(Hello.PubSub, _merchant_topic(item.merchant_id), %{event: "order_add", id: item_id})
      end
    end

    :ok # Important!
  end

  defp _merchant_topic(merchant_id) do
    "merchant:#{merchant_id}"
  end

end
