defmodule WebsocketHandler do
  #@callback websocket_handle({:text, String.t}, any, any) :: {:reply, {:text, String.t}, any, any} | {:ok, any, any}
  defmacro __using__(_opts) do
  	quote do
  	  def init(_, _req, _opts) do
	  	{:upgrade, :protocol, :cowboy_websocket}
	  end

	  def websocket_init(_type, req, _opts) do
	    {:ok, req, :undefined_state}
	  end

	  def websocket_handle(data, req, state) when not is_tuple(data) do
	  	{:ok, req, state}
	  end

	  def websocket_info({:broadcast, broadcast_msg }, req, state) do
	    {:reply, {:text, broadcast_msg}, req, state}
	  end
	  def websocket_info(_data, req, state) do
	  	{:ok, req, state}
	  end

	  def broadcast(pids, msg) do
	    Enum.each(pids, fn(pid) -> send(pid, msg) end)
	  end
  		
  	end
  end


end
