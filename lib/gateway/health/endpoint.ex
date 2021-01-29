defmodule Gateway.Health.Endpoint do
    use Plug.Router

    require Logger

    # This module is a Plug, that also implements it's own plug pipeline, below:

    # Using Plug.Logger for logging request information
    plug(Plug.Logger)
    # responsible for matching routes
    plug(:match)
    # Using Poison for JSON decoding
    # Note, order of plugs is important, by placing this _after_ the 'match' plug,
    # we will only parse the request AFTER there is a route match.
    plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
    # responsible for dispatching responses
    plug(:dispatch)

    # A simple route to test that the server is up
    # Note, all routes must return a connection as per the Plug spec.
    get "/health" do
        Gateway.Supervisor
        |> Supervisor.which_children()
        |> get_all_childrens()
        |> childrens_alive?()
        |> make_response(conn)
    end

    defp get_all_childrens([]), do: nil
    defp get_all_childrens(childrens) do
        childrens
        |> Enum.reduce([], fn {_, pid, _, _}, acc ->
            [pid | acc]
        end)
    end

    defp childrens_alive?(nil), do: false
    defp childrens_alive?(pids) do
        pids
        |> Enum.filter(fn pid ->
            Logger.info("Process #{inspect(pid)} alive? #{Process.alive?(pid)}")
            Process.alive?(pid)
        end)
        |> case do
            [] ->
                false
            list ->
                if Enum.sort(pids) == Enum.sort(list) do
                    true
                else
                    false
                end
        end
    end

    defp make_response(false, conn), do: send_resp(conn, 503, "not ready")
    defp make_response(true, conn), do: send_resp(conn, 200, "")

    match _ do
        send_resp(conn, 404, "not found")
    end
end