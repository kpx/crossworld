defmodule Crossworld.Game do
	@agent_timeout 5000

  	defmodule GameMessage do
    	@derive [Poison.Encoder]
    	defstruct [:action, :game, :box, :letter, :player]
  	end
	
	@doc """
	Creates a game with the given 'name' and adds the creating player
	to that game

	Returns :ok or :already_exists if there exists a game with that name
	"""
	def create_game(name, player, pid) do
		atom_name = String.to_atom(name)
		case exists?(atom_name) do
			false -> 
				Crossworld.Supervisor.new_game(atom_name)
				#Autojoin player that creates a game
				add_player_(atom_name, player, pid)
				:ok
			true ->
				:already_exists
		end
	end


	@doc """
	Returns a game 
	"""
	def get_game(name) do
		atom_name = String.to_existing_atom(name)
		get_game_(atom_name)
	end

	@doc """
	Updates a boxid with a letter written by player. Also broadcast
	that update to all websockets connected to that game.

	"""
	def update_box(name, boxid, letter, player) do
		atom_name = String.to_existing_atom(name)
		update_game(atom_name, boxid, letter, player)
		players = get_players(atom_name)
		# Broadcast to all players
		msg = {:broadcast, %GameMessage{action: "update", game: name, box: boxid, letter: letter, player: player}}
		pids = Enum.map(players, fn({_, pid}) -> pid end)
		Crossworld.Websocket.broadcast(pids, msg)
		:ok
	end

	
	@doc """
	Adds a player and its websocket to the game
	"""
	def add_player(name, player, pid) do
		atom_name = String.to_existing_atom(name)
		add_player_(atom_name, player, pid)
	end

	defp add_player_(atom_name, player, pid) do
		update_players = fn players -> MapSet.put(players, {player, pid}) end
    	Agent.update(atom_name, &Map.update(&1, :players, MapSet.new([{player, pid}]), update_players))
		:ok
	end

	@doc """
	Returns all players for a game
	"""
	def get_players(atom_name) do
		game = get_game_(atom_name)
		players = Map.get(game, :players)
		MapSet.to_list(players)
	end

	defp update_game(game, box_number, letter, player) do
    	
    	Agent.update(game, &Map.put(&1, box_number, {letter, player}))
  	end

	defp exists?(atom_name) do
		Process.whereis(atom_name) != nil
	end

	defp get_game_(atom_name) do
		Agent.get(atom_name, fn x -> x end, @agent_timeout)		
	end
  	
end