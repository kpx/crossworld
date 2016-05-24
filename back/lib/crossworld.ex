defmodule Crossworld do
  use Application

  def start(_type, _args) do
    dispatch = :cowboy_router.compile([
                {:_, [{"/ws", Crossworld.Websocket, []}]},
                {:_, [{"/game/:name", Crossworld.Router, []}]}
               ])
    {:ok, _} = :cowboy.start_http(:http, 100,
                                  [port: 8080],
                                  [env: [dispatch: dispatch]])
    Crossworld.Supervisor.start_link()

  end
end
