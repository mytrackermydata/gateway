use Mix.Config

config :gateway,
  amqp_connection: [
    username: "guest",
    password: "guest",
    host: "rabbit",
    virtual_host: "/",
    heartbeat: 30,
    connection_timeout: 10_000
  ]

config :gateway, :producer, %{
  publisher_confirms: false,
  publish_timeout: 0,
  exchanges: [
    %{name: "gps", type: :fanout, opts: [durable: true]}
  ]
}

import_config "#{Mix.env()}.exs"