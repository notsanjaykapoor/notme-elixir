defmodule Hello.CatalogTest do
  use Hello.DataCase, async: true

  alias Hello.Catalog

  describe "products" do
    alias Hello.Catalog.Product

    import Hello.CatalogFixtures

    @invalid_attrs %{price: nil, name: nil, views: nil}

    test "products_list/0 returns all products" do
      product = product_fixture()
      assert Catalog.products_list() == [product]
    end

    test "product_get!/1 returns the product with given id" do
      product = product_fixture()
      assert Catalog.product_get!(product.id) == product
    end

    test "product_create/1 with valid data creates a product" do
      valid_attrs = %{price: 12050, name: "some name", views: 0}

      assert {:ok, %Product{} = product} = Catalog.product_create(valid_attrs)
      assert product.name == "some name"
      assert product.price == 12050
      assert product.views == 0
    end

    test "product_create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.product_create(@invalid_attrs)
    end

    test "product_update/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{price: 45670, name: "some updated title", views: 43}

      assert {:ok, %Product{} = product} = Catalog.product_update(product, update_attrs)
      assert product.name == "some updated title"
      assert product.price == 45670
      assert product.views == 43
    end

    test "product_update/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.product_update(product, @invalid_attrs)
      assert product == Catalog.product_get!(product.id)
    end

    test "product_delete/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Catalog.product_delete(product)
      assert_raise Ecto.NoResultsError, fn -> Catalog.product_get!(product.id) end
    end

    test "product_change/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Catalog.product_change(product)
    end

    test "product_inc_page_view/1 returns product with view incremented" do
      product = product_fixture()
      assert product.views == 0
      product = Catalog.product_inc_page_view(product)
      assert product.views == 1
    end
  end

  describe "variants" do
    alias Hello.Catalog.Variant

    import Hello.CatalogFixtures

    @invalid_attrs %{name: nil, price: nil, tags: nil}

    test "variants_list/0 returns all variants" do
      variant = variant_fixture()
      assert Catalog.variants_list() == [variant]
    end

    test "variant_get!/1 returns the variant with given id" do
      variant = variant_fixture()
      assert Catalog.variant_get!(variant.id) == variant
    end

    test "variant_create/1 with valid data creates a variant" do
      product = product_fixture()

      valid_attrs = %{name: "some name", price: 42, product_id: product.id, tags: ["option1", "option2"]}

      assert {:ok, %Variant{} = variant} = Catalog.variant_create(valid_attrs)
      assert variant.name == "some name"
      assert variant.price == 42
      assert variant.tags == ["option1", "option2"]
    end

    test "variant_create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.variant_create(@invalid_attrs)
    end

    test "variant_update/2 with valid data updates the variant" do
      variant = variant_fixture()
      update_attrs = %{name: "some updated name", price: 43, tags: ["option1"]}

      assert {:ok, %Variant{} = variant} = Catalog.variant_update(variant, update_attrs)
      assert variant.name == "some updated name"
      assert variant.price == 43
      assert variant.tags == ["option1"]
    end

    test "variant_update/2 with invalid data returns error changeset" do
      variant = variant_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.variant_update(variant, @invalid_attrs)
      assert variant == Catalog.variant_get!(variant.id)
    end

    test "variant_delete/1 deletes the variant" do
      variant = variant_fixture()
      assert {:ok, %Variant{}} = Catalog.variant_delete(variant)
      assert_raise Ecto.NoResultsError, fn -> Catalog.variant_get!(variant.id) end
    end

    test "variant_change/1 returns a variant changeset" do
      variant = variant_fixture()
      assert %Ecto.Changeset{} = Catalog.variant_change(variant)
    end

    test "variant_search" do
      variant = variant_fixture(%{name: "variant search", price: 1000, tags: ["tag-1", "tag-2"]})

      # matching query on single fields
      result = Catalog.variants_search("search")
      dbg(result)
      assert [%Variant{}=vsearch] = result
      assert vsearch.id == variant.id

      # matching query on multiple fields
      result = Catalog.variants_search("name:search tags:tag-1")
      dbg(result)
      assert [%Variant{}=vsearch] = result
      assert vsearch.id == variant.id

      # non-matching query
      result = Catalog.variants_search("name:search tags:xxx")
      assert [] = result

      # non-matching query
      result = Catalog.variants_search("undefined")
      assert [] = result
    end
  end
end
