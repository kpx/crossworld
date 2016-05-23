defmodule Crossworld.Worker do
  def start_link(name) do
    Agent.start_link(fn -> %{} end, name: name)
  end

  def get(game) do
    g = Agent.get(game, fn x -> x end, 5000)
    Map.to_list(g)
  end

  def put(game, box_number, letter, player) do
    Agent.update(game, &Map.put(&1, box_number, {letter, player}))
  end
end