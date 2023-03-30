defmodule Hello.CatalogTest do
  use Hello.DataCase, async: true

  alias Hello.ItemService

  describe "items" do
    alias Hello.Catalog.Item

    import Hello.ItemServiceFixtures
    import Hello.MerchantServiceFixtures
    import Hello.OptionServiceFixtures
    import Hello.ProductServiceFixtures

    @invalid_attrs %{name: nil, price: nil, tags: nil}

    test "items_list/0 returns all items" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      option = option_fixture(%{product_id: product.id})

      item = item_fixture(%{merchant_id: merchant.id, product_id: product.id, option_id: option.id})

      assert ItemService.items_list() == [item]
    end

    test "item_get!/1 returns the item with given id" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      option = option_fixture(%{product_id: product.id})

      item = item_fixture(%{merchant_id: merchant.id, product_id: product.id, option_id: option.id})

      assert ItemService.item_get!(item.id) == item
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
        sku: "sku",
        tags: ["option1", "option2"],
      }

      assert {:ok, %Item{} = item} = ItemService.item_create(valid_attrs)
      assert item.loc_name == "chicago 1"
      assert item.lot_id == "12345"
      assert item.name == "some name"
      assert item.option_id == option.id
      assert item.price == 42
      assert item.product_id == product.id
      assert item.qavail == 0
      assert item.qsold == 0
      assert item.sku == "sku"
      assert item.tags == ["option1", "option2"]
    end

    test "item_create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ItemService.item_create(@invalid_attrs)
    end

    test "item_update/2 with valid data updates the item" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      option = option_fixture(%{product_id: product.id})

      item = item_fixture(%{merchant_id: merchant.id, product_id: product.id, option_id: option.id})

      update_attrs = %{name: "some updated name", price: 43, tags: ["option1"]}

      assert {:ok, %Item{} = item} = ItemService.item_update(item, update_attrs)
      assert item.name == "some updated name"
      assert item.price == 43
      assert item.tags == ["option1"]
    end

    test "item_update/2 with invalid data returns error changeset" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      option = option_fixture(%{product_id: product.id})

      item = item_fixture(%{merchant_id: merchant.id, product_id: product.id, option_id: option.id})

      assert {:error, %Ecto.Changeset{}} = ItemService.item_update(item, @invalid_attrs)
      assert item == ItemService.item_get!(item.id)
    end

    test "item_delete/1 deletes the item" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      option = option_fixture(%{product_id: product.id})

      item = item_fixture(%{merchant_id: merchant.id, product_id: product.id, option_id: option.id})

      assert {:ok, %Item{}} = ItemService.item_delete(item)
      assert_raise Ecto.NoResultsError, fn -> ItemService.item_get!(item.id) end
    end

    test "item_change/1 returns a item changeset" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      option = option_fixture(%{product_id: product.id})

      item = item_fixture(%{merchant_id: merchant.id, product_id: product.id, option_id: option.id})

      assert %Ecto.Changeset{} = ItemService.item_change(item)
    end
  end
end
