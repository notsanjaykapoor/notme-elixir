defmodule Hello.OptionService do

  import Ecto.Query, warn: false

  alias Hello.Catalog.{Item, Option, OptionSearch}
  alias Hello.Repo

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
    query_params = Map.get(params, "query", "")
    query_limit = Map.get(params, "limit", 50)
    query_offset = Map.get(params, "offset", 0)

    options = OptionSearch.search(query_params, query_limit, query_offset)

    options = for option <- options do
      items_count = Repo.one(from v in Item, where: v.option_id == ^option.id, select: count("*"))
      %{option | items_count: items_count}
    end

    options
  end

end
