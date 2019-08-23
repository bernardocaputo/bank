defmodule Bank.BankAccountTest do
  use BankWeb.ConnCase
  alias Bank.BankAccountSchema
  alias Bank.CashOutEventSchema
  alias Bank.TransactionEventSchema
  alias Bank.Fixtures
  alias Bank.Repo

  setup do
    {user, user2} = Fixtures.create_user()
    {user_with_bank_account, user_with_bank_account2} = Fixtures.create_user_with_bank_account()

    %{
      user: {user, user2},
      user_with_bank_account: {user_with_bank_account, user_with_bank_account2}
    }
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
    test "open account", %{user: {user, _}} do
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

    test "when user already have bank account", %{
      user_with_bank_account: {user_with_bank_account, _}
    } do
      response =
        build_conn()
        |> authenticate_user(user_with_bank_account.user)
        |> graphql_query(
          query: @bank_account_query,
          variables: %{}
        )

      [error] = response["errors"]

      assert error["message"] ==
               "user_id has already been taken | constraint_name value: bank_accounts_user_id_index"
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
    test "when not logged in", %{user: {_user, _}} do
      response_one =
        build_conn()
        |> graphql_query(
          query: @cash_out_query,
          variables: %{value: 100}
        )

      [error] = response_one["errors"]
      assert error["message"] == "not_logged_in"
    end

    test "when value <= 0", %{user_with_bank_account: {user_with_bank_account, _}} do
      response_one =
        build_conn()
        |> authenticate_user(user_with_bank_account.user)
        |> graphql_query(
          query: @cash_out_query,
          variables: %{value: 0}
        )

      [error] = response_one["errors"]
      assert error["message"] == "value cannot be less than or equal to 0"

      response_two =
        build_conn()
        |> authenticate_user(user_with_bank_account.user)
        |> graphql_query(
          query: @cash_out_query,
          variables: %{value: -10}
        )

      [error_two] = response_two["errors"]
      assert error_two["message"] == "value cannot be less than or equal to 0"

      ba = Repo.get_by(BankAccountSchema, %{user_id: user_with_bank_account.user.id})
      assert ba.amount == 100_000
      assert Repo.get_by(CashOutEventSchema, %{bank_account_id: ba.id}) == nil
    end

    test "when value > bank account amount", %{
      user_with_bank_account: {user_with_bank_account, _}
    } do
      response =
        build_conn()
        |> authenticate_user(user_with_bank_account.user)
        |> graphql_query(
          query: @cash_out_query,
          variables: %{value: 100_001}
        )

      [error] = response["errors"]
      assert error["message"] == "amount negative not allowed | number value: 0"

      ba = Repo.get_by(BankAccountSchema, %{user_id: user_with_bank_account.user.id})
      assert ba.amount == 100_000

      assert Repo.get_by(CashOutEventSchema, %{bank_account_id: ba.id}) == nil
    end
  end

  describe "cashes out" do
    test "when value is valid", %{user_with_bank_account: {user_with_bank_account, _}} do
      response =
        build_conn()
        |> authenticate_user(user_with_bank_account.user)
        |> graphql_query(
          query: @cash_out_query,
          variables: %{value: 50000}
        )

      assert response["data"]["cashOut"]["amount"] == 50000
      assert response["data"]["cashOut"]["user_id"] == user_with_bank_account.user.id

      cash_out_event =
        Repo.get_by(CashOutEventSchema, %{bank_account_id: user_with_bank_account.id})

      assert cash_out_event.cash_out_amount == 50000
    end

    test "when value equal to amount", %{user_with_bank_account: {user_with_bank_account, _}} do
      response =
        build_conn()
        |> authenticate_user(user_with_bank_account.user)
        |> graphql_query(
          query: @cash_out_query,
          variables: %{value: 100_000}
        )

      assert response["data"]["cashOut"]["amount"] == 0
      assert response["data"]["cashOut"]["user_id"] == user_with_bank_account.user.id

      cash_out_event =
        Repo.get_by(CashOutEventSchema, %{bank_account_id: user_with_bank_account.id})

      assert cash_out_event.cash_out_amount == 100_000
    end
  end

  @transfer_money_query """
  mutation transferMoney($value: Int!, $email_account: String!) {
    transferMoney(value: $value, email_account: $email_account) {
      id
      amount
      user_id
    }
  }
  """

  describe "do not transfer money" do
    test "when not logged in", %{
      user_with_bank_account: {_, user_with_bank_account2}
    } do
      response_one =
        build_conn()
        |> graphql_query(
          query: @transfer_money_query,
          variables: %{value: 0, email_account: user_with_bank_account2.user.email}
        )

      [error] = response_one["errors"]
      assert error["message"] == "not_logged_in"
    end

    test "when value <= 0", %{
      user_with_bank_account: {user_with_bank_account, user_with_bank_account2}
    } do
      response_one =
        build_conn()
        |> authenticate_user(user_with_bank_account.user)
        |> graphql_query(
          query: @transfer_money_query,
          variables: %{value: 0, email_account: user_with_bank_account2.user.email}
        )

      [error] = response_one["errors"]
      assert error["message"] == "value cannot be less than or equal to 0"

      response_two =
        build_conn()
        |> authenticate_user(user_with_bank_account.user)
        |> graphql_query(
          query: @transfer_money_query,
          variables: %{value: -10, email_account: user_with_bank_account2.user.email}
        )

      [error_one] = response_one["errors"]
      assert error_one["message"] == "value cannot be less than or equal to 0"

      [error_two] = response_two["errors"]
      assert error_two["message"] == "value cannot be less than or equal to 0"

      ba = Repo.get_by(BankAccountSchema, %{user_id: user_with_bank_account.user.id})
      assert ba.amount == 100_000
      ba2 = Repo.get_by(BankAccountSchema, %{user_id: user_with_bank_account2.user.id})
      assert ba2.amount == 100_000
    end

    test "when value > bank account amount", %{
      user_with_bank_account: {user_with_bank_account, user_with_bank_account2}
    } do
      response =
        build_conn()
        |> authenticate_user(user_with_bank_account.user)
        |> graphql_query(
          query: @transfer_money_query,
          variables: %{value: 100_001, email_account: user_with_bank_account2.user.email}
        )

      [error] = response["errors"]
      assert error["message"] == "amount negative not allowed | number value: 0"

      ba = Repo.get_by(BankAccountSchema, %{user_id: user_with_bank_account.user.id})
      assert ba.amount == 100_000
      ba2 = Repo.get_by(BankAccountSchema, %{user_id: user_with_bank_account2.user.id})
      assert ba2.amount == 100_000

      assert Repo.get_by(TransactionEventSchema, %{from_bank_account_id: ba.id}) == nil
    end

    test "when sender == receiver", %{
      user_with_bank_account: {user_with_bank_account, _}
    } do
      response =
        build_conn()
        |> authenticate_user(user_with_bank_account.user)
        |> graphql_query(
          query: @transfer_money_query,
          variables: %{value: 100_001, email_account: user_with_bank_account.user.email}
        )

      [error] = response["errors"]
      assert error["message"] == "you cannot transfer money to yourself"

      ba = Repo.get_by(BankAccountSchema, %{user_id: user_with_bank_account.user.id})
      assert ba.amount == 100_000

      assert Repo.get_by(TransactionEventSchema, %{from_bank_account_id: ba.id}) == nil
    end

    test "when sender does not have bank account", %{
      user: {user, _},
      user_with_bank_account: {user_with_bank_account, _}
    } do
      response =
        build_conn()
        |> authenticate_user(user)
        |> graphql_query(
          query: @transfer_money_query,
          variables: %{value: 100_001, email_account: user_with_bank_account.user.email}
        )

      [error] = response["errors"]

      assert error["message"] ==
               "you do not have a bank account. Please open a Bank Account first"

      ba = Repo.get(BankAccountSchema, user_with_bank_account.id)
      assert ba.amount == 100_000

      assert Repo.get_by(TransactionEventSchema, %{to_bank_account_id: user_with_bank_account.id}) ==
               nil
    end

    test "when receiver does not have bank account", %{
      user: {user, _},
      user_with_bank_account: {user_with_bank_account, _}
    } do
      response =
        build_conn()
        |> authenticate_user(user_with_bank_account.user)
        |> graphql_query(
          query: @transfer_money_query,
          variables: %{value: 50000, email_account: user.email}
        )

      [error] = response["errors"]

      assert error["message"] == "Receiver does not have a bank account"

      ba = Repo.get(BankAccountSchema, user_with_bank_account.id)
      assert ba.amount == 100_000

      assert Repo.get_by(TransactionEventSchema, %{
               from_bank_account_id: user_with_bank_account.id
             }) == nil
    end
  end

  describe "transfer money" do
    test "when value is valid", %{
      user_with_bank_account: {user_with_bank_account, user_with_bank_account2}
    } do
      response =
        build_conn()
        |> authenticate_user(user_with_bank_account.user)
        |> graphql_query(
          query: @transfer_money_query,
          variables: %{value: 60000, email_account: user_with_bank_account2.user.email}
        )

      assert response["data"]["transferMoney"]["amount"] == 40000
      assert response["data"]["transferMoney"]["user_id"] == user_with_bank_account.user.id

      transaction_event =
        Repo.get_by(TransactionEventSchema, %{
          from_bank_account_id: user_with_bank_account.id,
          to_bank_account_id: user_with_bank_account2.id
        })

      ba2 = Repo.get_by(BankAccountSchema, %{user_id: user_with_bank_account2.user.id})
      assert ba2.amount == 160_000

      assert transaction_event.transaction_amount == 60000
    end

    test "when value is equal to amount", %{
      user_with_bank_account: {user_with_bank_account, user_with_bank_account2}
    } do
      response =
        build_conn()
        |> authenticate_user(user_with_bank_account.user)
        |> graphql_query(
          query: @transfer_money_query,
          variables: %{value: 100_000, email_account: user_with_bank_account2.user.email}
        )

      assert response["data"]["transferMoney"]["amount"] == 0
      assert response["data"]["transferMoney"]["user_id"] == user_with_bank_account.user.id

      transaction_event =
        Repo.get_by(TransactionEventSchema, %{
          from_bank_account_id: user_with_bank_account.id,
          to_bank_account_id: user_with_bank_account2.id
        })

      ba2 = Repo.get_by(BankAccountSchema, %{user_id: user_with_bank_account2.user.id})
      assert ba2.amount == 200_000

      assert transaction_event.transaction_amount == 100_000
    end
  end
end
