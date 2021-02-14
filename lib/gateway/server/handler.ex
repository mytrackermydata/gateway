defmodule Gateway.Server.Handler do
    use GenServer
    require Logger

    alias Gateway.Data
    alias Gateway.Rabbit.Publisher
  
    def start_link(args, options) do
      GenServer.start_link(__MODULE__, args, options)
    end
  
    @impl true
    def init(args) do
      socket = Map.get(args, :socket)
      :inet.setopts(socket, active: true)
      {:ok, args}
    end
  
    @impl true
    def handle_info({:tcp, socket, packet}, %{decoder: decoder} = state) do
      with {:ok, %Data{device_id: device_id} = data} <- decoder.parse(packet),
            :ok <- send_data(data)
      do
        Logger.info("Data received from #{inspect(device_id)}")

        data
        |> decoder.response()
        |> send_reply(socket)

        {:noreply, %{state | device_id: device_id}}
      else
        e ->
          Logger.error("An error occurred: #{inspect(e)}")
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

    def send_data(data) do
      data
      |> Jason.encode!()
      |> Publisher.send_data()
    end

    defp send_reply({:reply, reply}, socket) do
      Logger.info("Send reply: #{inspect(reply)}")
      :gen_tcp.send(socket, reply)
    end

    defp send_reply({:noreply, _}, _), do: :ok
  end
  