use Mix.Config

config :gateway, :server,
  decoders: [
      %{name: TkDecoder, port: 4444, ip: {127,0,0,1}}
  ]