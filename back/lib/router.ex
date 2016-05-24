defmodule Crossworld.Router do
  def init(_transport, req, []) do
    {:ok, req, nil}
  end

  def handle(req, state) do
	{method, _} = :cowboy_req.method(req)
	{name, _} = :cowboy_req.binding(:name, req)
	case method do
		"POST" -> 
			Crossworld.Supervisor.new_game(name)
			:cowboy_req.reply(201, req)
		"GET" ->
			# assumption: the game is started and thereby the atom exists
			atom = String.to_existing_atom(name)
			game = Crossworld.Worker.get(atom)
			game1 = List.foldl(game, [], fn ({box_number, {letter, player}}, acc) ->
				[ [ box_number: box_number, letter: letter, player: player ] | acc ]
			end)
			{_, reply_game} = JSON.encode(game1)
			:cowboy_req.reply(200, [{"content-type", "application/json; charset=utf-8"}], reply_game, req)
		"PUT" ->
			{:ok, body, _} = :cowboy_req.body(req)
			{_, decoded} = JSON.decode(body)
			box_number = decoded["box_number"]
			letter = decoded["letter"]
			player = decoded["player"]
			atom = String.to_existing_atom(name)
			Crossworld.Worker.put(atom, box_number, letter, player)
			:cowboy_req.reply(200, req)
	end
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state), do: :ok

end