defmodule Gateway.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = load_server()
    opts = [strategy: :one_for_one, name: Gateway.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp load_server() do
    Enum.reduce(
      Application.fetch_env!(:gateway, :server)[:decoders],
      [],
      fn %{name: name, ip: ip, port: port}, acc ->
        children = [
          {DynamicSupervisor, strategy: :one_for_one, name: Gateway.Server.Handler.DynamicSupervisor},
          {Task, fn -> Gateway.Server.Socket.accept({ip, port, name}) end}
        ]
        Enum.concat(children, acc)
      end
    )
  end
end
