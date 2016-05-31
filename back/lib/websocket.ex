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


  #def websocket_handle({:text, text}, req, state) do
  #	{:reply, {:text, "WOW" <> text}, req, state}
  #end
  def websocket_handle({:text, text}, req, state) do
    # {{box_number: 2222, player: 'jjussoi', letter:'a', game: 'superspel'}
    
    {_, decoded} = JSON.decode(text)
    #box_number = decoded["box_number"]
    #letter = decoded["letter"]
    player = decoded["player"]
    #game = decoded["game"]
    game = decoded["name"]
    case decoded["action"] do
      "create" ->
        Crossworld.Game.create_game(game, player, self())
        {:reply, {:text, player},req, state}
      "join" -> 
        Crossworld.Game.add_player(game, player, self())
        {:reply, {:text, player}, req, state}
      "put" ->
        boxid = decoded["boxid"]
        letter = decoded["letter"]
        Crossworld.Game.update_box(game, boxid, letter, player)
    end
    {:ok, req, state}
  end

  def websocket_handle(data, req, state) do
  	{:ok, req, state}
  end

  def websocket_info({:broadcast, boxid, letter, player}, req, state) do
    msg = box_json(boxid, letter, player)
    {:reply, {:text, msg}, req, state}
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
