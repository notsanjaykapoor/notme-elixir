defmodule NotmeWeb.PageControllerTest do
  use NotmeWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert redirected_to(conn) == ~p"/merchants"
    # assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end
end
