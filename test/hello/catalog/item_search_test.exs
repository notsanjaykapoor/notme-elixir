defmodule Hello.Catalog.ItemSearchTest do
  use Hello.DataCase, async: true

  alias Hello.Catalog.Item
  alias Hello.Catalog.ItemSearch

  import Hello.ItemServiceFixtures
  import Hello.MerchantServiceFixtures
  import Hello.OptionServiceFixtures
  import Hello.ProductServiceFixtures

  test "search" do
    merchant = merchant_fixture()
    product = product_fixture(%{merchant_id: merchant.id})
    option = option_fixture(%{product_id: product.id})

    item = item_fixture(%{
      merchant_id: merchant.id,
      name: "item search",
      option_id: option.id,
      price: 1000,
      product_id: product.id,
      tags: ["tag-1", "tag-2"]
    })

    # matching query on single field
    result = ItemSearch.search("search", 10, 0)
    assert [%Item{} = item_] = result
    assert item_.id == item.id

    # matching query on multiple fields, name and tags
    result = ItemSearch.search("name:search tags:tag-1,tax-xxx", 10, 0)
    assert [%Item{} = item_] = result
    assert item_.id == item.id

    # matching query on multiple fields, name and price
    result = ItemSearch.search("name:search price_gte:999", 10, 0)
    assert [%Item{} = item_] = result
    assert item_.id == item.id

    # non-matching query on single field
    result = ItemSearch.search("undefined", 10, 0)
    assert [] = result

    # non-matching query on multiple fields
    result = ItemSearch.search("name:search tags:xxx", 10, 0)
    assert [] = result
  end
end
