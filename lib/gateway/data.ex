defmodule Gateway.Data do
    @moduledoc """
    Data struct defines which kind of data should be encoded in JSON format and send over Rabbit
    """
    @derive Jason.Encoder

    defstruct [
        :firm,
        :device,
        :device_id,
        :lenght,
        :content,
        :content_type,
        :steps,
        :battery,
        :acc,
        :device_timestamp,
        :located,
        :latitude,
        :latitude_mark,
        :longitude,
        :longitude_mark,
        :speed,
        :direction,
        :altitude,
        :satellites,
        :gsm_signal,
        :roll,
        :status,
        :lbs_stations
      ]
end