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
alias Hello.Catalog.Product
alias Hello.Catalog.Variant
alias Hello.Repo

Faker.start()

for id <- Enum.to_list(1..25) do
  product_name = "Product #{id}"
  {:ok, %Product{} = product} = Catalog.product_find_or_create(product_name)

  variants = Repo.all(from v in Variant, where: v.product_id == ^product.id)

  if length(variants) == 0 do
    for id <- Enum.to_list(1..2) do
      # create variants iff product has no variants yet
      variant_id = Faker.Superhero.name()
      # variant_id = ExULID.ULID.generate()
      variant_name = "#{product.name} - #{variant_id}"

      variant = Catalog.variant_get_by_name(variant_name)

      unless variant do
        variant_price = product.price + :rand.uniform(1000)
        {:ok, _} = Catalog.variant_create(%{name: variant_name, price: variant_price, product_id: product.id, tags: []})
      end
    end
  end

  variants = Repo.all(from v in Variant, where: v.lots == [])

  for variant <- variants do
    Catalog.lot_create(variant, :rand.uniform(1000))
  end
end
