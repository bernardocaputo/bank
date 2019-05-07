defmodule GraphqlWeb.Schema.Types do
  use Absinthe.Schema.Notation

  object :user do
    field(:id, non_null(:id))
    field(:name, non_null(:string))
    field(:email, non_null(:string))
    field(:bank_account, :bank_account)
  end

  object :bank_account do
    field(:id, non_null(:id))
    field(:amount, non_null(:integer))
  end

  scalar :raw_json do
    serialize(fn x -> x end)
  end
end
