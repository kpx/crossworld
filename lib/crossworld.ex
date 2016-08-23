defmodule Crossworld do
  use Application

  def start(_type, _args) do
    websocket_config = {:websocket, "/ws", &Crossworld.Websocket.websocket_handle/1}
    static_config = {:static_priv_dir, :crossworld, "/assets/[...]", "static/assets"}
    index_static_config = {:static_priv, :crossworld, "/", "static/index.html"}
    config = [websocket_config, static_config, index_static_config]
    StateHolder.start_state_holder(config, 8080)
    Crossworld.Supervisor.start_link()
  end
end
