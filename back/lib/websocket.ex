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
        reply_msg = case result do
          :ok -> create_result_msg("ok", 201)
          :already_exists -> create_result_msg("error", 406)
        end
        {:reply, {:text, reply_msg}, req, state}
      "join" -> 
        game = Crossworld.Game.get_game(msg.game)
        players = MapSet.to_list(Map.fetch!(game, :players))
        reply_msg = case List.keymember?(players, msg.player, 0) do
          true -> 
            create_result_msg("error", 406)
          false -> 
            Crossworld.Game.add_player(msg.game, msg.player, self())
            create_game_msg(msg.game, game) 
        end
        {:reply, {:text, reply_msg}, req, state}
      "put" ->
        Crossworld.Game.update_box(msg.game, msg.box, msg.letter, msg.player)
        {:ok, req, state}
    end
  end

  def websocket_handle(_data, req, state) do
  	{:ok, req, state}
  end

  def websocket_info({:broadcast, broadcast_msg }, req, state) do
    encoded_msg = Poison.encode!(broadcast_msg)
    {:reply, {:text, encoded_msg}, req, state}
  end
  def websocket_info(_data, req, state) do
  	{:ok, req, state}
  end

  def broadcast(pids, msg) do
    Enum.each(pids, fn(pid) -> send(pid, msg) end)
  end

  defp create_game_msg(game_name, game) do
    boxes = 
      for {key, value} <- Map.to_list(game), 
          key != :players,
          {letter, player} = value, 
          do: %GameMessage{action: "update", game: game_name, box: key, letter: letter, player: player}
    Poison.encode!(boxes)
  end

  defp create_result_msg(result, code) do
    Poison.encode!(%Result{result: result, code: code})
  end


end
