defmodule NotmeWeb.ProductController do
  use NotmeWeb, :controller

  alias Notme.Model.Product
  alias Notme.ProductService

  def index(conn, params) do
    products = ProductService.products_list(params)
    render(conn, :index, products: products)
  end

  def new(conn, _params) do
    changeset = ProductService.product_change(%Product{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"product" => product_params}) do
    case ProductService.product_create(product_params) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product created successfully.")
        |> redirect(to: ~p"/products/#{product}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    product = ProductService.product_get!(id) |> ProductService.product_inc_page_view()

    render(conn, :show, product: product)
  end

  def edit(conn, %{"id" => id}) do
    product = ProductService.product_get!(id)
    changeset = ProductService.product_change(product)
    render(conn, :edit, product: product, changeset: changeset)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = ProductService.product_get!(id)

    case ProductService.product_update(product, product_params) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product updated successfully.")
        |> redirect(to: ~p"/products/#{product}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, product: product, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = ProductService.product_get!(id)
    {:ok, _product} = ProductService.product_delete(product)

    conn
    |> put_flash(:info, "Product deleted successfully.")
    |> redirect(to: ~p"/products")
  end
end
