defmodule Hello.LocationServiceFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hello.Catalog` context.
  """

  def location_fixture(attrs \\ %{}) do
    {:ok, location} =
      attrs
      |> Enum.into(%{
        name: "location 1",
        slug: "location-1",
      })
      |> Hello.Catalog.location_create()

    location
  end

end
