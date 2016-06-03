defmodule Crossworld.Websocket do
  require Poison
  alias Crossworld.Game.GameMessage, as: GameMessage

  defmodule Result do
      @derive [Poison.Encoder]
      defstruct result: "ok", code: 200
  end

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
        result = Crossworld.Game.create_game(msg.game, msg.player, self())
        case result do
          :ok -> {:reply, {:text, create_result_msg("ok", 201)}, req, state}
          :already_exists -> {:reply, {:text, create_result_msg("error", 406)}, req, state}
        end
      "join" -> 
        Crossworld.Game.add_player(msg.game, msg.player, self())
        {:ok, req, state}
      "put" ->
        Crossworld.Game.update_box(msg.game, msg.box, msg.letter, msg.player)
        {:ok, req, state}
    end
  end

  def websocket_handle(_data, req, state) do
  	{:ok, req, state}
  end

  def websocket_info({:broadcast, name, boxid, letter, player}, req, state) do
    msg = create_update_msg(name, boxid, letter, player)
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


  defp create_update_msg(game, boxid, letter, player) do
    Poison.encode!(%GameMessage{action: "update", game: game, box: boxid, letter: letter, player: player})
  end

  defp create_result_msg(result, code) do
    Poison.encode!(%Result{result: result, code: code})
  end


end
