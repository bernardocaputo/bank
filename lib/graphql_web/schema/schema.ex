defmodule GraphqlWeb.Schema do
  use Absinthe.Schema
  import_types(GraphqlWeb.Schema.Types)
  alias GraphqlWeb.Resolvers.UserResolver
  alias GraphqlWeb.Resolvers.BankAccountResolver
  alias Bank.Repo

  query do
    field :users, list_of(:user) do
      resolve(fn _params, %{context: %{current_user: _user}} ->
        {:ok, Repo.all(Bank.Account.User) |> Repo.preload(:bank_account)}
      end)
    end
  end

  mutation do
    field :create_user, type: :user do
      arg(:name, non_null(:string))
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(handle_errors(&UserResolver.create_user/2))
    end

    field :login, type: :raw_json do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&UserResolver.login/2)
    end

    field :open_bank_account, type: :bank_account do
      resolve(handle_errors(&BankAccountResolver.open_bank_account/2))
    end

    field :cash_out, type: :bank_account do
      arg(:value, non_null(:integer))
      resolve(handle_errors(&BankAccountResolver.cash_out/2))
    end
  end

  def handle_errors(fun) do
    fn source, args, info ->
      case Absinthe.Resolution.call(fun, source, args, info) do
        {:error, %Ecto.Changeset{} = changeset} -> format_changeset(changeset)
        val -> val
      end
    end
  end

  def format_changeset(%Ecto.Changeset{errors: []} = _changeset),
    do: {:error, "email already registered"}

  def format_changeset(%Ecto.Changeset{errors: errors} = _changeset) do
    {key, {value, context}} =
      errors
      |> List.first()

    _format_changeset(key, value, context)
  end

  def _format_changeset(key, value, []), do: {:error, "#{key}: #{value}"}

  def _format_changeset(key, value, context) do
    {k, v} = context |> List.last()

    {:error, "#{key} #{value} | #{k} value: #{v}"}
  end
end
