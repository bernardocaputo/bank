defmodule Bank.Exporter do
  @moduledoc false

  @doc """
  Creates a csv report
  """

  @spec create_report(list(map()), String.t()) :: {:ok, String.t()}
  def create_report(data, file_name) do
    file_path = "tmp/#{file_name}.csv"
    file_path |> Path.dirname() |> File.mkdir_p()
    file = File.open!(file_path, [:write, :utf8])
    data |> map_to_csv |> Enum.each(&IO.write(file, &1))
    File.close(file)
    {:ok, "report can be found at " <> file_path}
  end

  defp map_to_csv(data) do
    keys = data |> List.first() |> Map.keys()
    data |> CSV.encode(headers: keys) |> Enum.to_list()
  end
end
