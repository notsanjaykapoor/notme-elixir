defmodule Hello.OrderService do

  alias Hello.ItemService
  alias Hello.Repo

  def order_create(item_id) do
    item = ItemService.item_get!(item_id)

    Repo.transaction(fn ->

      # todo: create order

      # update item
      ItemService.item_update(item, %{qavail: item.qavail - 1, qsold: item.qsold + 1})
    end)

    {:ok, item}
  end

end
