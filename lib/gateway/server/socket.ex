defmodule Gateway.Server.Socket do
    @moduledoc """
    TCP socket to handle incoming data
    """
  
    require Logger
    alias Gateway.Server.Handler
  
    def accept({ip, port, decoder}) do
      {:ok, socket} =
        :gen_tcp.listen(port, [:binary, packet: 0, active: false, reuseaddr: true, ip: ip])
  
      Logger.info("Accepting connections on #{Enum.join(Tuple.to_list(ip), ".")}:#{port} for decoder #{decoder}")
      loop_acceptor(socket, decoder)
    end
  
    defp loop_acceptor(socket, decoder) do
      {:ok, client} = :gen_tcp.accept(socket)
      Logger.info("Accepted new connection")
  
      {:ok, pid} =
        DynamicSupervisor.start_child(Handler.DynamicSupervisor, %{
          id: Handler,
          start: {Handler, :start_link, [%{socket: client, decoder: decoder, device_id: nil}, []]},
          type: :worker
        })
  
      :gen_tcp.controlling_process(client, pid)
      loop_acceptor(socket, decoder)
    end
  end
  