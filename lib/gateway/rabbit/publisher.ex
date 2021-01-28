defmodule Gateway.Rabbit.Publisher do
    @moduledoc false

    alias Amqpx.Gen.Producer

    def send_data(payload) do
        Producer.publish("gps", "", payload)
    end

end