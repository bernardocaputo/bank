defmodule Bank.BankAccountTest do
  use BankWeb.ConnCase
  alias Bank.Account.User
  alias Bank.BankAccountSchema
  alias Bank.CashOutEventSchema
  alias Bank.Repo

  setup do
    user = %User{id: 1, email: "email@email.com"} |> Repo.insert!()
    %{user: user}
  end

  @bank_account_query """
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
          query: @bank_account_query,
          variables: %{}
        )

      assert response["data"]["openBankAccount"]["amount"] == 100_000
      assert response["data"]["openBankAccount"]["user_id"] == user.id
    end
  end

  describe "do not open bank account" do
    test "when not logged in" do
      response =
        build_conn()
        |> graphql_query(
          query: @bank_account_query,
          variables: %{}
        )

      [error] = response["errors"]
      assert error["message"] == "not_logged_in"
    end

    test "when user already have bank account", %{user: user} do
      %BankAccountSchema{user_id: user.id} |> Repo.insert!()

      response =
        build_conn()
        |> authenticate_user(user)
        |> graphql_query(
          query: @bank_account_query,
          variables: %{}
        )

      [error] = response["errors"]
      assert error["message"] == "user_id: has already been taken"
    end
  end

  @cash_out_query """
  mutation cashOut($value: Int!) {
    cashOut(value: $value) {
      id
      amount
      user_id
    }
  }
  """

  describe "do not cash out" do
    test "when value <= 0", %{user: user} do
      %BankAccountSchema{user_id: user.id, amount: 100_000} |> Repo.insert!()

      response_one =
        build_conn()
        |> authenticate_user(user)
        |> graphql_query(
          query: @cash_out_query,
          variables: %{value: 0}
        )

      [error] = response_one["errors"]
      assert error["message"] == "value cannot be less than or equal to 0"

      response_two =
        build_conn()
        |> authenticate_user(user)
        |> graphql_query(
          query: @cash_out_query,
          variables: %{value: -10}
        )

      [error_two] = response_two["errors"]
      assert error_two["message"] == "value cannot be less than or equal to 0"

      ba = Repo.get_by(BankAccountSchema, %{user_id: user.id})
      assert ba.amount == 100_000
      assert Repo.get_by(CashOutEventSchema, %{bank_account_id: ba.id}) == nil
    end

    test "when value > bank account amount", %{user: user} do
      %BankAccountSchema{user_id: user.id, amount: 100_000} |> Repo.insert!()

      response =
        build_conn()
        |> authenticate_user(user)
        |> graphql_query(
          query: @cash_out_query,
          variables: %{value: 100_001}
        )

      [error] = response["errors"]
      assert error["message"] == "amount negative not allowed | number value: 0"

      ba = Repo.get_by(BankAccountSchema, %{user_id: user.id})
      assert ba.amount == 100_000

      assert Repo.get_by(CashOutEventSchema, %{bank_account_id: ba.id}) == nil
    end
  end

  describe "cashes out" do
    test "when value is valid", %{user: user} do
      ba = %BankAccountSchema{user_id: user.id, amount: 100_000} |> Repo.insert!()

      response =
        build_conn()
        |> authenticate_user(user)
        |> graphql_query(
          query: @cash_out_query,
          variables: %{value: 50000}
        )

      assert response["data"]["cashOut"]["amount"] == 50000
      assert response["data"]["cashOut"]["user_id"] == user.id

      cash_out_event = Repo.get_by(CashOutEventSchema, %{bank_account_id: ba.id})
      assert cash_out_event.cash_out_amount == 50000
    end

    test "when value equal to amount", %{user: user} do
      ba = %BankAccountSchema{user_id: user.id, amount: 100_000} |> Repo.insert!()

      response =
        build_conn()
        |> authenticate_user(user)
        |> graphql_query(
          query: @cash_out_query,
          variables: %{value: 100_000}
        )

      assert response["data"]["cashOut"]["amount"] == 0
      assert response["data"]["cashOut"]["user_id"] == user.id

      cash_out_event = Repo.get_by(CashOutEventSchema, %{bank_account_id: ba.id})
      assert cash_out_event.cash_out_amount == 100_000
    end
  end
end
