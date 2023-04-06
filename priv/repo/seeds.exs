# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Hello.Repo.insert!(%Hello.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query

alias Hello.Catalog.Item
alias Hello.Catalog.Location
alias Hello.Catalog.Merchant
alias Hello.Catalog.Option
alias Hello.Catalog.Product
alias Hello.{ItemService, LocationService, MerchantService, OptionService, ProductService}
alias Hello.Repo

Faker.start()

merchants = Repo.all(from o in Merchant)

if length(merchants) == 0 do
  for _id <- Enum.to_list(1..3) do
    merchant_name = Faker.Pokemon.name()

    {:ok, %Merchant{} = _merchant} = MerchantService.merchant_find_or_create(merchant_name)
  end
end

merchants = Repo.all(from o in Merchant)

for id <- Enum.to_list(1..5) do
  location_name = "Warehouse #{id}"
  {:ok, %Location{} = _location} = LocationService.location_find_or_create(location_name)
end

locations = Repo.all(from o in Location)

for merchant <- merchants do
  for _id <- Enum.to_list(1..10) do
    product_name = Faker.Superhero.name()

    {:ok, %Product{} = product} = ProductService.product_find_or_create(merchant.id, product_name)

    options = Repo.all(from o in Option, where: o.product_id == ^product.id)

    if length(options) == 0 do
      # initialize product options
      pkg_sizes = OptionService.option_pkg_sizes_random(2)
      pkg_counts = OptionService.option_pkg_counts_random(2)

      for id <- Enum.to_list(1..2) do
        pkg_size = Enum.at(pkg_sizes, id-1)
        pkg_count = Enum.at(pkg_counts, id-1)
        option_name = "#{product.name} - #{pkg_size} - #{pkg_count}"
        {:ok, _} = OptionService.option_create(%{name: option_name, pkg_count: pkg_count, pkg_size: pkg_size, product_id: product.id})
      end
    end

    options = Repo.all(from o in Option, where: o.product_id == ^product.id)
    items = Repo.all(from o in Item, where: o.product_id == ^product.id)

    if length(items) == 0 do
      # initialize items
      for option <- options do
        product = ProductService.product_get!(option.product_id)

        location = Enum.random(locations)

        %{
          item_name: item_name,
          item_price: item_price,
          item_sku: item_sku,
          lot_id: lot_id,
        } = ItemService.item_create_props(product, option, location)

        {:ok, _} = ItemService.item_create(%{
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
      end
    end
  end
end
