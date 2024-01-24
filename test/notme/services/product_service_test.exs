defmodule Notme.ProductServiceTest do
  use Notme.DataCase, async: true

  alias Notme.Service

  describe "products" do
    alias Notme.Model.Product

    import Notme.MerchantServiceFixtures
    import Notme.ProductServiceFixtures

    @invalid_attrs %{lot_ids: [], price: nil, name: nil, views: nil}

    test "products_list/0 returns all products" do
      merchant = merchant_fixture()
      product = %{product_fixture(%{merchant_id: merchant.id}) | options_count: 0, items_count: 0}
      assert Service.Product.products_list() == [product]
    end

    test "product_get!/1 returns the product with given id" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      assert Service.Product.product_get!(product.id) == product
    end

    test "product_create/1 with valid data creates a product" do
      merchant = merchant_fixture()

      valid_attrs = %{merchant_id: merchant.id, price: 12050, name: "some name", views: 0}

      assert {:ok, %Product{} = product} = Service.Product.product_create(valid_attrs)
      assert product.name == "some name"
      assert product.price == 12050
      assert product.views == 0
    end

    test "product_create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Service.Product.product_create(@invalid_attrs)
    end

    test "product_update/2 with valid data updates the product" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      update_attrs = %{price: 45670, name: "some updated title", views: 43}

      assert {:ok, %Product{} = product} = Service.Product.product_update(product, update_attrs)
      assert product.name == "some updated title"
      assert product.price == 45670
      assert product.views == 43
    end

    test "product_update/2 with invalid data returns error changeset" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      assert {:error, %Ecto.Changeset{}} = Service.Product.product_update(product, @invalid_attrs)
      assert product == Service.Product.product_get!(product.id)
    end

    test "product_delete/1 deletes the product" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      assert {:ok, %Product{}} = Service.Product.product_delete(product)
      assert_raise Ecto.NoResultsError, fn -> Service.Product.product_get!(product.id) end
    end

    test "product_change/1 returns a product changeset" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      assert %Ecto.Changeset{} = Service.Product.product_change(product)
    end

    test "product_inc_page_view/1 returns product with view incremented" do
      merchant = merchant_fixture()
      product = product_fixture(%{merchant_id: merchant.id})
      assert product.views == 0
      product = Service.Product.product_inc_page_view(product)
      assert product.views == 1
    end
  end

end
