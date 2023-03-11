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

alias Hello.Catalog
alias Hello.Catalog.Product

for id <- Enum.to_list(1..10) do
  product_name = "Product #{id}"
  {:ok, %Product{} = product} = Catalog.product_find_or_create(product_name)

  variant_sha = :crypto.hash(:md5, product.name) |> Base.encode16()
  variant_name = "#{product.name} - #{variant_sha}"

  variant = Catalog.variant_get_by_name(variant_name)

  unless variant do
    {:ok, _} = Catalog.variant_create(%{name: variant_name, price: product.price, product_id: product.id, tags: ["p-#{product.id}"]})
  end
end
