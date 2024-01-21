defmodule Notme.Catalog.ItemSearchTest do
  use Notme.DataCase, async: true

  alias Notme.Catalog.Item
  alias Notme.Catalog.ItemSearch

  import Notme.ItemServiceFixtures
  import Notme.MerchantServiceFixtures
  import Notme.OptionServiceFixtures
  import Notme.ProductServiceFixtures

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
    item_page = ItemSearch.search("search", 10, 0)
    assert [%Item{} = item_] = item_page.objects
    assert item_.id == item.id
    assert 1 == item_page.total

    # matching query on multiple fields, name and tags
    item_page = ItemSearch.search("name:search tags:tag-1,tax-xxx", 10, 0)
    assert [%Item{} = item_] = item_page.objects
    assert item_.id == item.id
    assert 1 == item_page.total

    # matching query on multiple fields, name and price
    item_page = ItemSearch.search("name:search price_gte:999", 10, 0)
    assert [%Item{} = item_] = item_page.objects
    assert item_.id == item.id
    assert 1 == item_page.total

    # non-matching query on single field
    item_page = ItemSearch.search("undefined", 10, 0)
    assert [] = item_page.objects
    assert 0 == item_page.total

    # non-matching query on multiple fields
    item_page = ItemSearch.search("name:search tags:xxx", 10, 0)
    assert [] = item_page.objects
    assert 0 == item_page.total
  end
end
