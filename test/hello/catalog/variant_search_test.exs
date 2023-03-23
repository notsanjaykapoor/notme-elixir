defmodule Hello.Catalog.VariantSearchTest do
  use Hello.DataCase, async: true

  alias Hello.Catalog.Variant
  alias Hello.Catalog.VariantSearch

  import Hello.CatalogFixtures

  test "search" do
    variant = variant_fixture(%{name: "variant search", price: 1000, tags: ["tag-1", "tag-2"]})

    # matching query on single field
    result = VariantSearch.search("search", 10, 0)
    assert [%Variant{}=vsearch] = result
    assert vsearch.id == variant.id

    # matching query on multiple fields, name and tags
    result = VariantSearch.search("name:search tags:tag-1,tax-xxx", 10, 0)
    assert [%Variant{}=variant_] = result
    assert variant_.id == variant.id

    # matching query on multiple fields, name and price
    result = VariantSearch.search("name:search price_gte:999", 10, 0)
    assert [%Variant{}=variant_] = result
    assert variant_.id == variant.id

    # non-matching query on single field
    result = VariantSearch.search("undefined", 10, 0)
    assert [] = result

    # non-matching query on multiple fields
    result = VariantSearch.search("name:search tags:xxx", 10, 0)
    assert [] = result
  end
end
