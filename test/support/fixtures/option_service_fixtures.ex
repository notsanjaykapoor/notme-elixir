defmodule Notme.OptionServiceFixtures do

  def option_fixture(attrs \\ %{}) do
    {:ok, option} =
      attrs
      |> Enum.into(%{
        name: "option name",
        pkg_size: "1g",
        pkg_count: 1,
      })
      |> Notme.OptionService.option_create()

      option
  end

end
