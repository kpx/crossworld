defmodule Crossworld.Websocket do
  require Record
  Record.defrecord :state, Record.extract(:state,
                                from: "deps/cowboy/src/cowboy_websocket.erl")

  def init(_, req, opts) do
  	{:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_type, req, _opts) do
    #todo: add self() to game
    {:ok, req, :undefined_state}
  end


  def websocket_handle({:text, text}, req, state) do
  	{:reply, {:text, "WOW" <> text}, req, state}
  end
  def websocket_handle(data, req, state) do
  	{:ok, req, state}
  end

  def websocket_info({:broadcast, boxid, letter, player}, req, state) do
    msg = box_json(boxid, letter, player)
    {:reply, msg, req, state}
  end
  def websocket_info(data, req, state) do
  	{:ok, req, state}
  end

  defp box_json(boxid, letter, player) do
    box = [ [ boxid: boxid, letter: letter, player: player ] ]
    {:ok, box_json} = JSON.encode(box)
    box_json
  end


end
