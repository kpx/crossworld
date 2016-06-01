defmodule Crossworld.Worker do

  def get(game) do
    Agent.get(game, fn x -> x end, 5000)
  end

  def put(game, box_number, letter, player) do
    Agent.update(game, &Map.put(&1, box_number, {letter, player}))
  end

  def add_player(game, player, pid) do
    update_players = fn players -> MapSet.put(players, {player, pid}) end
    Agent.update(game, &Map.update(&1, :players, MapSet.new([{player, pid}]), update_players))
  end
end
