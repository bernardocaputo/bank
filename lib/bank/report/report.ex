defmodule Bank.Report do
  import Ecto.Query, only: [from: 2]
  alias Bank.Repo
  alias Bank.Exporter
  alias Bank.TransactionEventSchema

  @today Date.utc_today()
  @startdate ~D[2018-01-01]

  @doc """
  Generates daily report
  """
  @spec daily_transaction_report() :: {:ok, String.t()}
  def daily_transaction_report() do
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
    |> parse_daily_result(@startdate, @today, :lt)
    |> Exporter.create_report("daily-report-#{@today |> Date.to_string()}")

    # :lt means that startdate < today (less than)
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

  @doc """
  Generates monthly report
  """
  @spec monthly_transaction_report() :: {:ok, String.t()}
  def monthly_transaction_report() do
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
    |> parse_daily_result(@startdate, @today, :lt)
    |> Enum.filter(fn %{date: date} = _x -> date.day == 1 end)
    |> Enum.map(fn %{date: date} = x ->
      %{x | date: "#{date.year}/#{date.month |> Timex.month_shortname()}"}
    end)
    |> Exporter.create_report("monthly-report-#{@today |> Date.to_string()}")
  end

  @doc """
  Generates yearly report
  """
  @spec yearly_transaction_report() :: {:ok, String.t()}
  def yearly_transaction_report() do
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
    |> parse_daily_result(@startdate, @today, :lt)
    |> Enum.filter(fn %{date: date} = _x -> date.day == 1 && date.month == 1 end)
    |> Enum.map(fn %{date: date} = x ->
      %{x | date: date.year}
    end)
    |> Exporter.create_report("yearly-report-#{@today |> Date.to_string()}")

    # :lt means that startdate < today (less than)
  end

  @doc """
  Generates all transactions report
  """
  @spec all_transactions_report() :: {:ok, String.t()}
  def all_transactions_report() do
    from(
      t in TransactionEventSchema,
      select: %{
        total: sum(t.transaction_amount)
      }
    )
    |> Repo.all()
    |> Exporter.create_report("all-transactions-report-#{@today |> Date.to_string()}")
  end
end
