defmodule Notme.MerchantServiceFixtures do

  def merchant_fixture(attrs \\ %{}) do
    {:ok, merchant} =
      attrs
      |> Enum.into(%{
        name: "Merchant",
        slug: "merchant-1",
        state: "active",
      })
      |> Notme.MerchantService.merchant_create()

      merchant
  end

end
