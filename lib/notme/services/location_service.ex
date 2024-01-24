defmodule Notme.LocationService do

  import Ecto.Query, warn: false

  alias Notme.Repo
  alias Notme.Model.Location


  def location_create(attrs \\ %{}) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  def location_find_or_create(name) do
    location = location_get_by_name(name)

    if location do
      {:ok, location}
    else
      slug = name
      |> String.replace(" ", "-")
      |> String.downcase()

      location_create(%{name: name, slug: slug})
    end
  end

  def location_get_by_name(name) do
    Repo.get_by(Location, [name: name])
  end

end
