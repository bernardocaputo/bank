defmodule Bank.AuthenticationHelper do
  def authenticate_user(conn, user) do
    {:ok, token, _} = Guardian.encode_and_sign(user)

    conn
    |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")
  end
end
