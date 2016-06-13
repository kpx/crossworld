defmodule Crossworld.Supervisor do
  use Supervisor

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = []
    supervise(children, strategy: :one_for_one)
  end

  def new_room(name) do
    map = %{}
    Agent.start_link(fn -> map end, name: name)
  	#Crossworld.Worker.start_link(name)
  end
end