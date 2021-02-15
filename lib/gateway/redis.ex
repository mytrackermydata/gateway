defmodule Gateway.Redis do
    @moduledoc false
    use GenServer
  
    def start_link(opts) do
      GenServer.start_link(__MODULE__, opts, name: :pubsub)
    end
  
    @impl true
    def init(opts) do
        {:ok, pubsub} = Redix.PubSub.start_link(opts)
        {:ok, %{pubsub: pubsub}}
    end

    @impl true
    def handle_call({:subscribe, channel, process}, _from, %{pubsub: pubsub} = state) do
        {:reply, Redix.PubSub.subscribe(pubsub, channel, process), state}
    end

    @impl true
    def handle_call({:unsubscribe, channel, process}, _from, %{pubsub: pubsub} = state) do
        {:reply, Redix.PubSub.unsubscribe(pubsub, channel, process), state}
    end

    def subscribe(channel, process) do
        GenServer.call(:pubsub, {:subscribe, channel, process})
    end

    def unsubscribe(channel, process) do
        GenServer.call(:pubsub, {:unsubscribe, channel, process})
    end

end