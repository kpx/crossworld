defmodule Crossworld.Game do
	@doc """
	Creates a game with the given 'name'

	Returns :ok
	"""
	def create_game(name, player, pid) do
		atom_name = String.to_atom(name)
		Crossworld.Supervisor.new_game(atom_name)
		Crossworld.Worker.add_player(atom_name, player, pid)
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
		Enum.each(players, fn({_, x}) -> 
			send(x, {:broadcast, boxid, letter, player}) 
		end)
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