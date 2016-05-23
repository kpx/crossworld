defmodule Crossworld.Router do
  def init(_transport, req, []) do
    {:ok, req, nil}
  end

  def handle(req, state) do
	{method, req} = :cowboy_req.method(req)
	{name, _} = :cowboy_req.binding(:name, req)
	case method do
		"POST" -> 
			Crossworld.Supervisor.new_game(name)
		"GET" ->
			atom = String.to_atom(name)
			game = Crossworld.Worker.get(atom)
			reply_game = :io_lib.format("~p",[game])
			:cowboy_req.reply(200, [{"content-type", "text/plain; charset=utf-8"}], reply_game, req)
	end
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state), do: :ok

end