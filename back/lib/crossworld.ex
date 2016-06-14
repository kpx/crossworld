defmodule Crossworld do
  use Application

  def start(_type, _args) do
    StateHolder.start_state_holder("/ws", Crossworld.Websocket)
    Crossworld.Supervisor.start_link()
  end
end
