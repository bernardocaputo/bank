defmodule Bank.ReportTest do
  use BankWeb.ConnCase
  alias Bank.Fixtures

  describe "report" do
    test "daily report" do
      two_days_ago =
        NaiveDateTime.utc_now() |> Timex.shift(days: -2) |> NaiveDateTime.truncate(:second)

      yesterday =
        NaiveDateTime.utc_now() |> Timex.shift(days: -1) |> NaiveDateTime.truncate(:second)

      {_transaction, _transaction2} = Fixtures.create_transactions(two_days_ago, yesterday)

      assert Fixtures.daily_transaction_report() |> is_list
      # start_date = -4 days + today == 5 on fixtures function
      assert Fixtures.daily_transaction_report() |> length == 5
    end

    test "monthly report" do
      two_months_ago =
        NaiveDateTime.utc_now() |> Timex.shift(months: -2) |> NaiveDateTime.truncate(:second)

      yesterday =
        NaiveDateTime.utc_now() |> Timex.shift(days: -1) |> NaiveDateTime.truncate(:second)

      {_transaction, _transaction2} = Fixtures.create_transactions(two_months_ago, yesterday)

      assert Fixtures.monthly_transaction_report() |> is_list
      # start_date = -2 months + this month == 3 on fixtures function
      assert Fixtures.monthly_transaction_report() |> length == 3
    end

    test "yearly report" do
      two_years_ago =
        NaiveDateTime.utc_now() |> Timex.shift(years: -1) |> NaiveDateTime.truncate(:second)

      yesterday =
        NaiveDateTime.utc_now() |> Timex.shift(days: -1) |> NaiveDateTime.truncate(:second)

      {_transaction, _transaction2} = Fixtures.create_transactions(two_years_ago, yesterday)

      assert Fixtures.yearly_transaction_report() |> is_list
      # start_date = -1 year ago + this year == 2 on fixtures function
      assert Fixtures.yearly_transaction_report() |> length == 2
    end

    test "all transaction report" do
      two_days_ago =
        NaiveDateTime.utc_now() |> Timex.shift(days: -2) |> NaiveDateTime.truncate(:second)

      yesterday =
        NaiveDateTime.utc_now() |> Timex.shift(days: -1) |> NaiveDateTime.truncate(:second)

      {_transaction, _transaction2} = Fixtures.create_transactions(two_days_ago, yesterday)

      assert Fixtures.all_transactions_report() |> is_list
      assert Fixtures.all_transactions_report() |> length == 1
    end
  end
end
