defmodule Gateway.Server.Handler do
    use GenServer
    require Logger

    alias Gateway.{Data, Redis}
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
        Logger.info("Data received from #{inspect(device_id)}: #{inspect(data)}")

        data
        |> decoder.response()
        |> send_reply(socket)

        Redis.subscribe("device_#{device_id}", self())

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

    @impl true
    def handle_info({:redix_pubsub, _, _, :message, %{channel: channel, payload: payload}}, %{device_id: device_id, socket: socket} = state) do
      if String.replace(channel, "device_", "") == device_id do
        Logger.info("Received message for #{device_id}: #{payload}")
        :gen_tcp.send(socket, payload)
      end
      {:noreply, state}
    end

    @impl true
    def handle_info({:redix_pubsub, _, _, :subscribed, %{channel: channel}}, %{device_id: device_id} = state) do
      Logger.info("#{device_id} subscribed on channel #{channel}")
      {:noreply, state}
    end

    def send_data(data) do
      data
      |> Jason.encode!()
      |> Publisher.send_data()
    end

    defp send_reply({:reply, reply}, socket), do: :gen_tcp.send(socket, reply)
    defp send_reply({:noreply, _}, _), do: :ok
  end
  