defmodule Notme.Service.Order do

  alias Notme.Model
  alias Notme.Service
  alias Notme.Repo

  require OpenTelemetry.Tracer, as: Tracer

  @spec order_create(integer) :: {:ok, Model.Item}
  def order_create(item_id) do
    Tracer.with_span("order_service.order_create") do
      item = Service.Item.item_get!(item_id)

      Repo.transaction(fn ->
        # todo: create order

        # update item
        Service.Item.item_update(item, %{qavail: item.qavail - 1, qsold: item.qsold + 1})
      end)

      {:ok, item}
    end
  end

end
