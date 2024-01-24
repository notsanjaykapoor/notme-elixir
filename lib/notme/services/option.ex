defmodule Notme.Service.Option do

  import Ecto.Query, warn: false

  alias Notme.Model.{Item, Option, OptionSearch}
  alias Notme.Repo

  require OpenTelemetry.Tracer, as: Tracer

  @pkg_sizes_all ["1g", "3g", "5g", "7g"]
  @pkg_counts_all [1, 5, 12, 20]

  @spec option_create(:invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          any
  def option_create(attrs \\ %{}) do
    %Option{}
    |> Option.changeset(attrs)
    |> Repo.insert()
  end

  def option_get_by_pkg(pkg_size, pkg_count) do
    Repo.get_by(Option, [pkg_size: pkg_size, pkg_count: pkg_count])
  end

  def option_pkg_counts_random(count) do
    Enum.take_random(@pkg_counts_all, count)
  end

  def option_pkg_sizes_random(count) do
    Enum.take_random(@pkg_sizes_all, count)
  end

  def options_list(params \\ %{}) do
    Tracer.with_span("option_service.options_list") do
      query_params = Map.get(params, "query", "")
      query_limit = Map.get(params, "limit", 50)
      query_offset = Map.get(params, "offset", 0)

      Tracer.set_attributes([{:query_params, query_params}])

      option_item_map = _option_item_map()

      options = OptionSearch.search(query_params, query_limit, query_offset)

      options = for option <- options do
        items_count = Map.get(option_item_map, option.id, 0)
        %{option | items_count: items_count}
      end

      options
    end
  end

  defp _option_item_map() do
    option_item_list = Item
      |> select([o], {o.option_id, count(o.id)})
      |> group_by([o], o.option_id)
      |> Repo.all

    Enum.into(option_item_list, %{})
  end

end
