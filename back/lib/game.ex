defmodule Crossworld.Game do
	@doc """
	Creates a game with the given 'name'

	Returns :ok
	"""
	def create_game(name) do
		atom_name = String.to_atom(name)
		Crossworld.Supervisor.new_game(atom_name)
	end

	@doc """
	Returns a game 
	"""
	def get_game(name) do
		atom_name = String.to_existing_atom(name)
		game = Crossworld.Worker.get(atom)
		#todo return only game
		game
	end

	@doc """
	Updates a boxid with a letter written by player
	"""
	def update_box(name, boxid, letter, player) do
		atom_name = String.to_existing_atom(name)
		Crossworld.Worker.put(atom_name, boxid, letter, player)
		#todo broadcast new box
		players = get_players(name)
		Enum.each(players, fn(x) -> x ! {:broadcast, boxid, letter, player} end)
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
		game = Crossworld.Worker.get(atom)
		#todo: return only players
		game
	end

end