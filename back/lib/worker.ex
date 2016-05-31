defmodule Crossworld.Worker do
  def start_link(name) do
    map = %{}
    Agent.start_link(fn -> map end, name: name)
  end

  def get(game) do
    g = Agent.get(game, fn x -> x end, 5000)
    Map.to_list(g)
  end

  def put(game, box_number, letter, player) do
    Agent.update(game, &Map.put(&1, box_number, {letter, player}))
  end

  def add_player(game, player) do
    Agent.update(game, &Map.update(&1, :players, MapSet.new(), fn current_players ->
      MapSet.put(current_players, player)
    end))

  end

  def get_players(game) do
    IO.puts game
    g = Agent.get(game, fn x -> x end, 5000)
    IO.puts(g)
    MapSet.to_list(Map.get(g, :players))
  end
end
