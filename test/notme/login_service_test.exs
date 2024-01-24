defmodule Notme.LoginServiceTest do
  use Notme.DataCase, async: true

  alias Notme.LoginService

  test "password_validate/2 with invalid password returns error" do
    assert {:error, "password invalid"} == LoginService.password_validate("password", "")
    assert {:error, "password invalid"} == LoginService.password_validate("password", "notme-tst")
  end

  test "password_validate/2 with valid password returns error" do
    assert {:ok, "ok"} == LoginService.password_validate("notme-tst", "notme-tst")
  end

end
