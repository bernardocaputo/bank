defmodule GraphqlWeb.Schema.Types do
  use Absinthe.Schema.Notation

  object :user do
    field(:id, non_null(:id))
    field(:name, non_null(:string))
    field(:email, non_null(:string))
  end

  scalar :raw_json do
    serialize(fn x -> x end)
  end
end
