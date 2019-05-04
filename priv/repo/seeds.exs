# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Bank.Repo.insert!(%Bank.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

%Bank.Account.User{
  name: "Bernardo",
  email: "bernardocaputo@gmail.com",
  encrypted_password: "teste"
}
|> Bank.Repo.insert!()
