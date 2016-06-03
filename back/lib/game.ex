defmodule Crossworld.Game do
  	defmodule GameMessage do
    	@derive [Poison.Encoder]
    	defstruct [:action, :game, :box, :letter, :player]
  	end
	@doc """
	Creates a game with the given 'name'

	Returns :ok
	"""
	def create_game(name, player, pid) do
		atom_name = String.to_atom(name)
		case exists?(atom_name) do
			false -> 
				Crossworld.Supervisor.new_game(atom_name)
				Crossworld.Worker.add_player(atom_name, player, pid)
				:ok
			true ->
				:already_exists
		end
	end

	defp exists?(atom_name) do
		Process.whereis(atom_name) != nil
	end

	@doc """
	Returns a game 
	"""
	def get_game(name) do
		atom_name = String.to_existing_atom(name)
		game = Crossworld.Worker.get(atom_name)
		#todo remove players 
		game
	end

	@doc """
	Updates a boxid with a letter written by player
	"""
	def update_box(name, boxid, letter, player) do
		atom_name = String.to_existing_atom(name)
		Crossworld.Worker.put(atom_name, boxid, letter, player)
		players = get_players(name)
		# Broadcast to all players
		msg = {:broadcast, name, boxid, letter, player}
		pids = Enum.map(players, fn({_, pid}) -> pid end)
		Crossworld.Websocket.broadcast(pids, msg)
		:ok
	end

	
	@doc """
	Adds a player websocket to the game
	"""
	def add_player(name, player, pid) do
		atom_name = String.to_existing_atom(name)
		Crossworld.Worker.add_player(atom_name, player, pid)
		:ok
	end

	@doc """
	Returns all players for a game
	"""
	def get_players(name) do
		atom_name = String.to_existing_atom(name)
		game = Crossworld.Worker.get(atom_name)
		players = Map.get(game, :players)
		MapSet.to_list(players)
	end

end