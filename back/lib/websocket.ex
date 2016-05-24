defmodule Crossworld.Websocket do
  require Record
  Record.defrecord :state, Record.extract(:state,
                                from: "deps/cowboy/src/cowboy_websocket.erl")

  def init(_, req, opts) do
  	{:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_type, req, _opts) do
    {:ok, req, :undefined_state}
  end


  def websocket_handle({:text, text}, req, state) do
  	{:reply, {:text, "WOW" <> text}, req, state}
  end
  def websocket_handle(data, req, state) do
  	{:ok, req, state}
  end

  def websocket_info(data, req, state) do
  	{:ok, req, state}
  end

end
