use Mix.Config

config :gateway,
  amqp_connection: [
    username: System.get_env("RABBITMQ_USER"),
    password: System.get_env("RABBITMQ_PASSWORD"),
    host: System.get_env("RABBITMQ_HOST"),
    virtual_host: "/",
    heartbeat: 30,
    connection_timeout: 10_000
  ]

config :gateway, :server,
  decoders: [
      %{name: TkDecoder, port: 4444, ip: {0,0,0,0}}
  ]

config :gateway, :redis,
  uri: System.get_env("REDIS_URI")