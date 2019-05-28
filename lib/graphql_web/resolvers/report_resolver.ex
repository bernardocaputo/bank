defmodule GraphqlWeb.Resolvers.ReportResolver do
  alias Bank.Report

  def daily_transasction_report(_, %{context: %{current_user: _user}}) do
    Report.daily_transaction_report()
  end

  def monthly_transasction_report(_, %{context: %{current_user: _user}}) do
    Report.monthly_transaction_report()
  end

  def yearly_transaction_report(_, %{context: %{current_user: _user}}) do
    Report.yearly_transaction_report()
  end

  def all_transactions_report(_, %{context: %{current_user: _user}}) do
    Report.all_transactions_report()
  end
end
