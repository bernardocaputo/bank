defmodule Bank.AccountTest do
  use BankWeb.ConnCase

  @query """
  mutation createUser($name: String!, $password: String!, $email: String!) {
    createUser(name: $name, email: $email, password: $password) {
      id
      name
      email
    }
  }
  """
  describe "creates user" do
    test "should create user" do
      response =
        build_conn()
        |> graphql_query(
          query: @query,
          variables: %{
            name: "name surname",
            password: "greater-than-8",
            email: "valid@email.com"
          }
        )

      assert response["data"]["createUser"]["email"] == "valid@email.com"
      assert response["data"]["createUser"]["name"] == "name surname"
    end
  end

  describe "should not create user" do
    test "email not valid" do
      response =
        build_conn()
        |> graphql_query(
          query: @query,
          variables: %{
            name: "name surname",
            password: "greater-than-8",
            email: ".not_validemail.com"
          }
        )

      assert response["data"]["createUser"] == nil

      assert response["errors"] == [
               %{
                 "locations" => [%{"column" => 0, "line" => 2}],
                 "message" => "email email not valid | format value: wrong",
                 "path" => ["createUser"]
               }
             ]
    end

    test "name not valid" do
      response =
        build_conn()
        |> graphql_query(
          query: @query,
          variables: %{
            name: "na",
            password: "greater-than-8",
            email: "valid@email.com"
          }
        )

      assert response["data"]["createUser"] == nil

      assert response["errors"] == [
               %{
                 "locations" => [%{"column" => 0, "line" => 2}],
                 "message" =>
                   "name should be at least %{count} character(s) | type value: string",
                 "path" => ["createUser"]
               }
             ]
    end

    test "password not valid" do
      response =
        build_conn()
        |> graphql_query(
          query: @query,
          variables: %{
            name: "name surname",
            password: "le8",
            email: "valid@email.com"
          }
        )

      assert response["data"]["createUser"] == nil

      assert response["errors"] == [
               %{
                 "locations" => [%{"column" => 0, "line" => 2}],
                 "message" =>
                   "password should be at least %{count} character(s) | type value: string",
                 "path" => ["createUser"]
               }
             ]
    end
  end
end
