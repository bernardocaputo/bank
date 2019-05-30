defmodule Bank.Fixtures do
  import Ecto.Query, only: [from: 2]
  alias Bank.Account.User
  alias Bank.BankAccount
  alias Bank.TransactionEventSchema
  alias Bank.Repo

  def create_user() do
    random = 1..1_000_000 |> Enum.random()

    # hash for "password"
    encrypted_password = "$2b$12$n1HA/.LKGJOT4nD5Lr77R.nDv1QJ/GflFYYMsNS7b9PbwX4ptrgQq"

    user =
      %User{email: "#{random}@email.com", encrypted_password: encrypted_password}
      |> Repo.insert!()

    user_two =
      %User{email: "#email@#{random}.com", encrypted_password: encrypted_password}
      |> Repo.insert!()

    {user, user_two}
  end

  def create_user_with_bank_account() do
    {user, user_two} = create_user()
    {:ok, bank_account} = BankAccount.open_bank_account(user)
    {:ok, bank_account_two} = BankAccount.open_bank_account(user_two)

    {bank_account |> Repo.preload(:user), bank_account_two |> Repo.preload(:user)}
  end

  def create_transactions() do
    random = 1..100_000 |> Enum.random()

    {bank_account, bank_account2} = create_user_with_bank_account()
    {bank_account3, bank_account4} = create_user_with_bank_account()

    transaction =
      %TransactionEventSchema{
        from_bank_account_id: bank_account.id,
        to_bank_account_id: bank_account2.id,
        transaction_amount: random
      }
      |> Repo.insert!()

    transaction2 =
      %TransactionEventSchema{
        from_bank_account_id: bank_account3.id,
        to_bank_account_id: bank_account4.id,
        transaction_amount: random
      }
      |> Repo.insert!()

    {transaction, transaction2}
  end

  def daily_transaction_report() do
    from(
      t in TransactionEventSchema,
      group_by: fragment("date_trunc('day', ?)", t.inserted_at),
      select: %{
        day: fragment("date_trunc('day', ?)", t.inserted_at),
        transaction_amount: sum(t.transaction_amount)
      }
    )
    |> Repo.all()
  end

  def monthly_transaction_report do
    from(
      t in TransactionEventSchema,
      group_by: fragment("date_trunc('month', ?)", t.inserted_at),
      select: %{
        month: fragment("date_trunc('month', ?)", t.inserted_at),
        transaction_amount: sum(t.transaction_amount)
      }
    )
    |> Repo.all()
  end

  def yearly_transaction_report do
    from(
      t in TransactionEventSchema,
      group_by: fragment("date_trunc('year', ?)", t.inserted_at),
      select: %{
        year: fragment("date_trunc('year', ?)", t.inserted_at),
        transaction_amount: sum(t.transaction_amount)
      }
    )
    |> Repo.all()
  end

  def all_transactions_report do
    from(
      t in TransactionEventSchema,
      select: %{
        total: sum(t.transaction_amount)
      }
    )
    |> Repo.all()
  end
end
