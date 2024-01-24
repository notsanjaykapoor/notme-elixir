defmodule NotmeWeb.ProductController do
  use NotmeWeb, :controller

  alias Notme.Model.Product
  alias Notme.Service

  def index(conn, params) do
    products = Service.Product.products_list(params)
    render(conn, :index, products: products)
  end

  def new(conn, _params) do
    changeset = Service.Product.product_change(%Product{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"product" => product_params}) do
    case Service.Product.product_create(product_params) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product created successfully.")
        |> redirect(to: ~p"/products/#{product}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Service.Product.product_get!(id) |> Service.Product.product_inc_page_view()

    render(conn, :show, product: product)
  end

  def edit(conn, %{"id" => id}) do
    product = Service.Product.product_get!(id)
    changeset = Service.Product.product_change(product)
    render(conn, :edit, product: product, changeset: changeset)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Service.Product.product_get!(id)

    case Service.Product.product_update(product, product_params) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product updated successfully.")
        |> redirect(to: ~p"/products/#{product}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, product: product, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Service.Product.product_get!(id)
    {:ok, _product} = Service.Product.product_delete(product)

    conn
    |> put_flash(:info, "Product deleted successfully.")
    |> redirect(to: ~p"/products")
  end
end
