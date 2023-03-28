defmodule Hello.CatalogTest do
  use Hello.DataCase, async: true

  alias Hello.Catalog

  describe "products" do
    alias Hello.Catalog.Product

    import Hello.CatalogFixtures

    @invalid_attrs %{lot_ids: [], price: nil, name: nil, views: nil}

    test "products_list/0 returns all products" do
      merchant = merchant_fixture()
      product = %{product_fixture(%{merchant_id: merchant.id}) | options_count: 0, items_count: 0}
      assert Catalog.products_list() == [product]
    end

    test "product_get!/1 returns the product with given id" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      assert Catalog.product_get!(product.id) == product
    end

    test "product_create/1 with valid data creates a product" do
      merchant = merchant_fixture()

      valid_attrs = %{merchant_id: merchant.id, price: 12050, name: "some name", views: 0}

      assert {:ok, %Product{} = product} = Catalog.product_create(valid_attrs)
      assert product.name == "some name"
      assert product.price == 12050
      assert product.views == 0
    end

    test "product_create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.product_create(@invalid_attrs)
    end

    test "product_update/2 with valid data updates the product" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      update_attrs = %{price: 45670, name: "some updated title", views: 43}

      assert {:ok, %Product{} = product} = Catalog.product_update(product, update_attrs)
      assert product.name == "some updated title"
      assert product.price == 45670
      assert product.views == 43
    end

    test "product_update/2 with invalid data returns error changeset" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      assert {:error, %Ecto.Changeset{}} = Catalog.product_update(product, @invalid_attrs)
      assert product == Catalog.product_get!(product.id)
    end

    test "product_delete/1 deletes the product" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      assert {:ok, %Product{}} = Catalog.product_delete(product)
      assert_raise Ecto.NoResultsError, fn -> Catalog.product_get!(product.id) end
    end

    test "product_change/1 returns a product changeset" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      assert %Ecto.Changeset{} = Catalog.product_change(product)
    end

    test "product_inc_page_view/1 returns product with view incremented" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      assert product.views == 0
      product = Catalog.product_inc_page_view(product)
      assert product.views == 1
    end
  end

  describe "items" do
    alias Hello.Catalog.Item

    import Hello.CatalogFixtures

    @invalid_attrs %{name: nil, price: nil, tags: nil}

    test "items_list/0 returns all items" do
      item = item_fixture()
      assert Catalog.items_list() == [item]
    end

    test "item_get!/1 returns the item with given id" do
      item = item_fixture()
      assert Catalog.item_get!(item.id) == item
    end

    test "item_create/1 with valid data creates a item" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      option = option_fixture(%{name: product.name, product_id: product.id})

      valid_attrs = %{
        loc_name: "chicago 1",
        lot_id: "12345",
        merchant_id: merchant.id,
        name: "some name",
        option_id: option.id,
        price: 42,
        product_id: product.id,
        qavail: 0,
        qsold: 0,
        tags: ["option1", "option2"],
      }

      assert {:ok, %Item{} = item} = Catalog.item_create(valid_attrs)
      assert item.loc_name == "chicago 1"
      assert item.lot_id == "12345"
      assert item.name == "some name"
      assert item.option_id == option.id
      assert item.price == 42
      assert item.product_id == product.id
      assert item.qavail == 0
      assert item.qsold == 0
      assert item.tags == ["option1", "option2"]
    end

    test "item_create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.item_create(@invalid_attrs)
    end

    test "item_update/2 with valid data updates the item" do
      item = item_fixture()
      update_attrs = %{name: "some updated name", price: 43, tags: ["option1"]}

      assert {:ok, %Item{} = item} = Catalog.item_update(item, update_attrs)
      assert item.name == "some updated name"
      assert item.price == 43
      assert item.tags == ["option1"]
    end

    test "item_update/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.item_update(item, @invalid_attrs)
      assert item == Catalog.item_get!(item.id)
    end

    test "item_delete/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Catalog.item_delete(item)
      assert_raise Ecto.NoResultsError, fn -> Catalog.item_get!(item.id) end
    end

    test "item_change/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Catalog.item_change(item)
    end
  end
end
