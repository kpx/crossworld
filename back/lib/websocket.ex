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
    case decoded["action"] do
      "create" ->
        game = decoded["name"]
        Crossworld.Supervisor.new_game(game)
        #players = Crossworld.Router.get_game(game)
        #{:reply, {:text, players},req, state}
        {:reply, {:text, player},req, state}
      "join" -> 
        IO.puts "join 1"
        game = String.to_atom(decoded["name"])
        IO.puts "join 2"
        Crossworld.Worker.add_player(game, player)
        IO.puts "Jion 3"
        players = Crossworld.Router.get_game(game)
        {:reply, {:text, players},req, state}
    end
    
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
