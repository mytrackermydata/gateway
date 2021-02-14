use Mix.Config

config :gateway, :server,
  decoders: [
      %{name: TkDecoder, port: 4444, ip: {0,0,0,0}}
  ]

config :gateway, :redis,
  uri: "redis://redis:6379/1"