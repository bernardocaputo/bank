defmodule Bank.Fixtures do
  @moduledoc false

  import Ecto.Query, only: [from: 2]
  alias Bank.Account.User
  alias Bank.BankAccount
  alias Bank.TransactionEventSchema
  alias Bank.Repo

  @today Date.utc_today()

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

  def create_transactions(date, date2) do
    random = 1..100_000 |> Enum.random()

    {bank_account, bank_account2} = create_user_with_bank_account()
    {bank_account3, bank_account4} = create_user_with_bank_account()

    transaction =
      %TransactionEventSchema{
        from_bank_account_id: bank_account.id,
        to_bank_account_id: bank_account2.id,
        transaction_amount: random,
        inserted_at: date
      }
      |> Repo.insert!()

    transaction2 =
      %TransactionEventSchema{
        from_bank_account_id: bank_account3.id,
        to_bank_account_id: bank_account4.id,
        transaction_amount: random,
        inserted_at: date2
      }
      |> Repo.insert!()

    {transaction, transaction2}
  end

  defp parse_daily_result(result, _date, _today, :eq) do
    result
    |> Enum.map(fn {date, value} -> %{date: date, value: value} end)
    |> Enum.sort_by(fn %{date: d} = _x -> {d.year, d.month, d.day} end)
  end

  defp parse_daily_result(result, date, today, _comparison) do
    # if date == today, it is the last time running this function (comparison == :eq)
    comparison = Date.compare(date, today)

    case result[date] do
      nil ->
        result |> Map.put(date, 0)

      _ ->
        result
    end
    |> parse_daily_result(date |> Timex.shift(days: 1), today, comparison)
  end

  def daily_transaction_report() do
    startdate = @today |> Timex.shift(days: -4)

    from(
      t in TransactionEventSchema,
      group_by: fragment("date_trunc('day', ?)", t.inserted_at),
      select: {
        fragment("date_trunc('day', ?)", t.inserted_at),
        sum(t.transaction_amount)
      }
    )
    |> Repo.all()
    |> Map.new(fn {date, value} -> {date |> Timex.to_date(), value} end)
    |> parse_daily_result(startdate, @today, :lt)
  end

  def monthly_transaction_report do
    startdate = @today |> Timex.shift(months: -2)

    from(
      t in TransactionEventSchema,
      group_by: fragment("date_trunc('month', ?)", t.inserted_at),
      select: {
        fragment("date_trunc('month', ?)", t.inserted_at),
        sum(t.transaction_amount)
      }
    )
    |> Repo.all()
    |> Map.new(fn {date, value} -> {date |> Timex.to_date(), value} end)
    |> parse_daily_result(startdate, @today, :lt)
    |> Enum.filter(fn %{date: date} = _x -> date.day == 1 end)
    |> Enum.map(fn %{date: date} = x ->
      %{x | date: "#{date.year}/#{date.month |> Timex.month_shortname()}"}
    end)
  end

  def yearly_transaction_report do
    startdate = @today |> Timex.shift(years: -1)

    from(
      t in TransactionEventSchema,
      group_by: fragment("date_trunc('year', ?)", t.inserted_at),
      select: {
        fragment("date_trunc('year', ?)", t.inserted_at),
        sum(t.transaction_amount)
      }
    )
    |> Repo.all()
    |> Map.new(fn {date, value} -> {date |> Timex.to_date(), value} end)
    |> parse_daily_result(startdate, @today, :lt)
    |> Enum.filter(fn %{date: date} = _x -> date.day == 1 && date.month == 1 end)
    |> Enum.map(fn %{date: date} = x ->
      %{x | date: date.year}
    end)
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
