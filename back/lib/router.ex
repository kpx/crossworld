defmodule Crossworld.Router do
	@doc """
	DEPRECATED module defining rest api
	"""
  require Poison
  
  alias Crossworld.Game.GameMessage, as: GameMessage	

  def init(_transport, req, []) do
    {:ok, req, nil}
  end


  def handle(req, state) do
	{method, _} = :cowboy_req.method(req)
	{name, _} = :cowboy_req.binding(:name, req)
	case method do
		"POST" -> 
			create_game(name)
			:cowboy_req.reply(201, req)
		"GET" ->
			reply_game = get_game(name)
			:cowboy_req.reply(200, [{"content-type", "application/json; charset=utf-8"}], reply_game, req)
		"PUT" ->
			{:ok, body, _} = :cowboy_req.body(req)
			msg = Poison.decode!(body, as: %GameMessage{})
			atom = String.to_existing_atom(msg.name)
			Crossworld.Game.update_game(atom, msg.boxid, msg.letter, msg.player)
			:cowboy_req.reply(200, req)
	end
    {:ok, req, state}
  end

  def create_game(name) do
  	Crossworld.Supervisor.new_game(name)
  end
  
  def get_game(name) do
  	# assumption: the game is started and thereby the atom exists
	atom = String.to_existing_atom(name)
	game = Crossworld.Game.get_game(atom)
	game1 = List.foldl(game, [], fn ({box_number, {letter, player}}, acc) ->
		[ [ box_number: box_number, letter: letter, player: player ] | acc ]
	end)
	{_, reply_game} = JSON.encode(game1)
	reply_game
  end


  def terminate(_reason, _req, _state), do: :ok

end