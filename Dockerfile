FROM hexpm/elixir:1.15.6-erlang-26.1.1-alpine-3.18.2 AS base

# Install hex + rebar
RUN MIX_HOME=/app mix do local.hex --force, local.rebar --force

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    git

FROM base as dev

ENTRYPOINT ["/app/docker-entrypoint.sh"]

FROM base AS build

ENV MIX_ENV=prod

# Install project dependencies
WORKDIR /app
COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# build app
COPY . .
RUN mix do compile, release

FROM alpine:3.18.2 AS release

RUN apk add --update --no-cache \
  libgcc \
  libstdc++ \
  ncurses-libs \
  make \
  curl

WORKDIR /app

COPY docker-entrypoint.sh ./
COPY Makefile ./
COPY --from=build /app/_build/prod/rel/rinha ./

ENTRYPOINT ["/app/docker-entrypoint.sh"]
