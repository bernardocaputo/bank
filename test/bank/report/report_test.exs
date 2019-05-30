defmodule Bank.ReportTest do
  use BankWeb.ConnCase
  alias Bank.Fixtures
  alias Bank.Report

  describe "no report" do
    test "when no data" do
      assert {:error, "no transactions found"} == Report.daily_transaction_report()
      assert {:error, "no transactions found"} == Report.monthly_transaction_report()
      assert {:error, "no transactions found"} == Report.yearly_transaction_report()
      assert {:error, "no transactions found"} == Report.all_transactions_report()
    end
  end

  describe "report" do
    test "daily report" do
      {transaction, transaction2} = Fixtures.create_transactions()

      [%{day: {{year, month, day}, _}, transaction_amount: amount}] =
        Fixtures.daily_transaction_report()

      %NaiveDateTime{year: nyear, month: nmonth, day: nday} = transaction.inserted_at
      assert nyear == year
      assert nmonth == month
      assert nday == day
      assert amount == transaction.transaction_amount + transaction2.transaction_amount
    end

    test "monthly report" do
      {transaction, transaction2} = Fixtures.create_transactions()

      [%{month: {{year, month, _day}, _}, transaction_amount: amount}] =
        Fixtures.monthly_transaction_report()

      %NaiveDateTime{year: nyear, month: nmonth} = transaction.inserted_at
      assert nyear == year
      assert nmonth == month
      assert amount == transaction.transaction_amount + transaction2.transaction_amount
    end

    test "yearly report" do
      {transaction, transaction2} = Fixtures.create_transactions()

      [%{year: {{year, _month, _day}, _}, transaction_amount: amount}] =
        Fixtures.yearly_transaction_report()

      %NaiveDateTime{year: nyear} = transaction.inserted_at
      assert nyear == year
      assert amount == transaction.transaction_amount + transaction2.transaction_amount
    end

    test "all transaction report" do
      {transaction, transaction2} = Fixtures.create_transactions()

      [%{total: amount}] = Fixtures.all_transactions_report()

      assert amount == transaction.transaction_amount + transaction2.transaction_amount
    end
  end
end
