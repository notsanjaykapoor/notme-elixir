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

alias Hello.Catalog
alias Hello.Catalog.Location
alias Hello.Catalog.Merchant
alias Hello.Catalog.Option
alias Hello.Catalog.Product
alias Hello.Catalog.Variant
alias Hello.Repo

Faker.start()

merchants = Repo.all(from o in Merchant)

if length(merchants) == 0 do
  for _id <- Enum.to_list(1..3) do
    merchant_name = Faker.Pokemon.name()

    {:ok, %Merchant{} = _merchant} = Catalog.merchant_find_or_create(merchant_name)
  end
end

merchants = Repo.all(from o in Merchant)

for id <- Enum.to_list(1..5) do
  location_name = "Warehouse #{id}"
  {:ok, %Location{} = _location} = Catalog.location_find_or_create(location_name)
end

locations = Repo.all(from o in Location)

pkg_sizes_all = ["1g", "3g", "5g"]
pkg_counts_all = [1, 5, 12]

for merchant <- merchants do
  for _id <- Enum.to_list(1..10) do
    product_name = Faker.Superhero.name()

    {:ok, %Product{} = product} = Catalog.product_find_or_create(merchant.id, product_name)

    options = Repo.all(from o in Option, where: o.product_id == ^product.id)

    if length(options) == 0 do
      # initialize product options
      pkg_sizes = Enum.take_random(pkg_sizes_all, 2)
      pkg_counts = Enum.take_random(pkg_counts_all, 2)

      for id <- Enum.to_list(1..2) do
        pkg_size = Enum.at(pkg_sizes, id-1)
        pkg_count = Enum.at(pkg_counts, id-1)
        option_name = "#{product.name} - #{pkg_size} - #{pkg_count}"
        {:ok, _} = Catalog.option_create(%{name: option_name, pkg_count: pkg_count, pkg_size: pkg_size, product_id: product.id})
      end
    end

    options = Repo.all(from o in Option, where: o.product_id == ^product.id)
    variants = Repo.all(from v in Variant, where: v.product_id == ^product.id)

    if length(variants) == 0 do
      # initialize variants
      for option <- options do
        location = Enum.random(locations)
        lot_id = ExULID.ULID.generate()

        product = Catalog.product_get!(option.product_id)

        variant_name = "#{product.name} - #{option.pkg_size} - #{option.pkg_count} count"
        variant_price = product.price + :rand.uniform(1000)

        {:ok, _} = Catalog.variant_create(%{
            loc_name: location.slug,
            lot_id: lot_id,
            merchant_id: merchant.id,
            name: variant_name,
            option_id: option.id,
            price: variant_price,
            product_id: product.id,
            qavail: :rand.uniform(1000),
            tags: []
          })
      end
    end
  end
end
