FROM elixir:1.7.4

WORKDIR /app

RUN mix local.hex --force

RUN mix local.rebar --force

COPY mix.exs .

RUN mix deps.get

COPY . .

CMD ["iex", "-S", "mix", "phx.server"]