defmodule Notme.LocationServiceFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Notme.Catalog` context.
  """

  def location_fixture(attrs \\ %{}) do
    {:ok, location} =
      attrs
      |> Enum.into(%{
        name: "location 1",
        slug: "location-1",
      })
      |> Notme.Service.Location.location_create()

    location
  end

end
