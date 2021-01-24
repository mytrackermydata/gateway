defmodule Gateway.Parser do
    @moduledoc """
    Parser provides an interface for decoders
    """

    @doc """
    Parses a string and return structured data.
    """
    @callback parse(String.t) :: {:ok, Gateway.Data} | {:error, String.t}

    @callback response(Gateway.Data) :: {:reply, String.t()} | :noreply
end