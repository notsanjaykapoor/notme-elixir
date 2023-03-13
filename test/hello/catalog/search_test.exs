defmodule Hello.Catalog.SearchTest do
  use Hello.DataCase, async: true

  alias Hello.Catalog.Search
  alias Hello.Catalog.Variant

  import Hello.CatalogFixtures

  test "search" do
    variant = variant_fixture(%{name: "variant search", price: 1000, tags: ["tag-1", "tag-2"]})

    # matching query on single field
    result = Search.search("search")
    assert [%Variant{}=vsearch] = result
    assert vsearch.id == variant.id

    # matching query on multiple fields, name and tags
    result = Search.search("name:search tags:tag-1,tax-xxx")
    assert [%Variant{}=variant_] = result
    assert variant_.id == variant.id

    # matching query on multiple fields, name and price
    result = Search.search("name:search price_gte:999")
    assert [%Variant{}=variant_] = result
    assert variant_.id == variant.id

    # non-matching query on single field
    result = Search.search("undefined")
    assert [] = result

    # non-matching query on multiple fields
    result = Search.search("name:search tags:xxx")
    assert [] = result
  end
end
