defmodule Bank.Report do
  import Ecto.Query
  alias Bank.Repo
  alias Bank.Exporter
  alias Bank.TransactionEventSchema

  @doc """
  Generates daily report
  """
  @spec daily_transaction_report() :: {:ok, String.t()}
  def daily_transaction_report() do
    result =
      from(
        t in TransactionEventSchema,
        group_by: fragment("date_trunc('day', ?)", t.inserted_at),
        select: %{
          day: fragment("date_trunc('day', ?)", t.inserted_at),
          transaction_amount: sum(t.transaction_amount)
        }
      )
      |> Repo.all()

    parse_result(result, :day)
  end

  @doc """
  Generates monthly report
  """
  @spec monthly_transaction_report() :: {:ok, String.t()}
  def monthly_transaction_report() do
    result =
      from(
        t in TransactionEventSchema,
        group_by: fragment("date_trunc('month', ?)", t.inserted_at),
        select: %{
          month: fragment("date_trunc('month', ?)", t.inserted_at),
          transaction_amount: sum(t.transaction_amount)
        }
      )
      |> Repo.all()

    parse_result(result, :month)
  end

  @doc """
  Generates yearly report
  """
  @spec yearly_transaction_report() :: {:ok, String.t()}
  def yearly_transaction_report() do
    result =
      from(
        t in TransactionEventSchema,
        group_by: fragment("date_trunc('year', ?)", t.inserted_at),
        select: %{
          year: fragment("date_trunc('year', ?)", t.inserted_at),
          transaction_amount: sum(t.transaction_amount)
        }
      )
      |> Repo.all()

    parse_result(result, :year)
  end

  @doc """
  Generates all transactions report
  """
  @spec all_transactions_report() :: {:ok, String.t()}
  def all_transactions_report() do
    result =
      from(
        t in TransactionEventSchema,
        select: %{
          total: sum(t.transaction_amount)
        }
      )
      |> Repo.all()

    parse_result(result, :total)
  end

  defp parse_result([], _), do: {:error, "no transactions found"}
  defp parse_result([%{total: nil}], _), do: {:error, "no transactions found"}

  defp parse_result(result, type) do
    data =
      case type do
        :day ->
          result
          |> Enum.map(fn %{day: {{year, month, day}, _}} = x ->
            x |> Map.put(:day, "#{year}-#{month}-#{day}")
          end)

        :month ->
          result
          |> Enum.map(fn %{month: {{year, month, _}, _}} = x ->
            x |> Map.put(:month, "#{year}-#{month}")
          end)

        :year ->
          result
          |> Enum.map(fn %{year: {{year, _, _}, _}} = x ->
            x |> Map.put(:year, "#{year}")
          end)

        :total ->
          result
      end

    data |> Exporter.create_report(type |> Atom.to_string())
  end
end
