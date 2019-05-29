defmodule Bank.BankAccountTest do
  use BankWeb.ConnCase
  alias Bank.Account.User
  alias Bank.BankAccountSchema
  alias Bank.Repo

  setup do
    user = %User{id: 1, email: "email@email.com"} |> Repo.insert!()
    %{user: user}
  end

  @query """
  mutation openBankAccount {
    openBankAccount {
      id
      amount
      user_id
    }
  }
  """
  describe "open bank account" do
    test "open account", %{user: user} do
      response =
        build_conn()
        |> authenticate_user(user)
        |> graphql_query(
          query: @query,
          variables: %{}
        )

      assert response["data"]["openBankAccount"]["amount"] == 100_000
      assert response["data"]["openBankAccount"]["user_id"] == user.id
    end
  end

  describe "do not open bank account" do
    test "should return not logged in" do
      response =
        build_conn()
        |> graphql_query(
          query: @query,
          variables: %{}
        )

      [error] = response["errors"]
      assert error["message"] == "not_logged_in"
    end

    test "should not created when user already have bank account", %{user: user} do
      %BankAccountSchema{user_id: user.id} |> Repo.insert!()

      response =
        build_conn()
        |> authenticate_user(user)
        |> graphql_query(
          query: @query,
          variables: %{}
        )

      [error] = response["errors"]
      assert error["message"] == "user_id: has already been taken"
    end
  end
end
