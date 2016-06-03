defmodule Crossworld.Websocket do
  require Poison
  alias Crossworld.Game.GameMessage, as: GameMessage

  def init(_, _req, _opts) do
  	{:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_type, req, _opts) do
    {:ok, req, :undefined_state}
  end

  def websocket_handle({:text, text}, req, state) do
    msg = Poison.decode!(text, as: %GameMessage{})

    case msg.action do
      "create" ->
        Crossworld.Game.create_game(msg.game, msg.player, self())
      "join" -> 
        Crossworld.Game.add_player(msg.game, msg.player, self())
      "put" ->
        Crossworld.Game.update_box(msg.game, msg.box, msg.letter, msg.player)
    end
    {:ok, req, state}
  end

  def websocket_handle(_data, req, state) do
  	{:ok, req, state}
  end

  def websocket_info({:broadcast, name, boxid, letter, player}, req, state) do
    msg = create_msg(name, boxid, letter, player)
    {:reply, {:text, msg}, req, state}
  end
  def websocket_info(_data, req, state) do
  	{:ok, req, state}
  end

  def broadcast(pids, msg) do
    Enum.each(pids, fn(pid) -> 
      send(pid, msg) 
    end)
  end


  defp create_msg(game, boxid, letter, player) do
    Poison.encode!(%GameMessage{game: game, box: boxid, letter: letter, player: player})
  end


end
