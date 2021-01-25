defmodule Gateway.Parser do
    @moduledoc """
    Parser provides an interface for decoders
    """

    @doc """
    Parses a string and return structured data.
    """
    @callback parse(String.t) :: {:ok, Gateway.Data} | {:error, String.t}

    @doc """
    Returns a response to the connected device
    """
    @callback response(Gateway.Data | nil) :: {:reply, String.t()} | :noreply
end