defmodule Gateway.Server.Handler do
    use GenServer
    require Logger

    alias Gateway.Data
  
    def start_link(args, options) do
      GenServer.start_link(__MODULE__, args, options)
    end
  
    @impl true
    def init(args) do
      socket = Map.get(args, :socket)
      :inet.setopts(socket, active: true)
      {:ok, %{socket: socket, device_id: nil}}
    end
  
    @impl true
    def handle_info({:tcp, socket, packet}, %{decoder: decoder} = state) do
      Logger.info("Received: #{packet}")
      Logger.info("State: #{inspect(state)}")
  
      try do
        case decoder.dispatch(packet) do
          {:reply, response, %Data{device_id: device_id} = data} ->
            :gen_tcp.send(socket, response)
            Logger.info("Protocol data: #{inspect(data)}")
            Logger.info("Response: #{response}")
            # Publish.send_data(Jason.encode!(data))
            {:noreply, %{state | device_id: device_id}}
  
          {:noreply, %Data{device_id: device_id} = data} ->
            Logger.info("Protocol data: #{inspect(data)}")
            # Publish.send_data(Jason.encode!(data))
            {:noreply, %{state | device_id: device_id}}
        end
      rescue
        e ->
          Logger.error("Error: #{inspect(e)}")
          {:noreply, state}
      end
    end
  
    @impl true
    def handle_info({:tcp_closed, _socket}, %{decoder: decoder} = state) do
      Logger.info("Socket is closed for decoder #{decoder}")
      {:stop, {:shutdown, "Socket is closed"}, state}
    end
  
    @impl true
    def handle_info({:tcp_error, _socket, reason}, %{decoder: decoder} = state) do
      Logger.error("TCP Socket error: #{inspect(reason)} for decoder #{decoder}")
      {:stop, {:shutdown, "TCP error: #{inspect(reason)}"}, state}
    end
  end
  