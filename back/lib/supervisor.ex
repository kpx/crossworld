defmodule Crossworld.Supervisor do
  use Supervisor

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = []

    supervise(children, strategy: :one_for_one)
  end

  def new_game(name) do
  	atom = String.to_atom(name)
  	Crossworld.Worker.start_link(atom)
  end
end