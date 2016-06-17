defmodule Crossworld.Websocket do
  require Poison

  defmodule Result do
      @derive [Poison.Encoder]
      defstruct result: "ok", code: 200
  end

  defmodule GameMessage do
    @derive [Poison.Encoder]
    defstruct [:action, :game, :box, :letter, :player]
  end

  def websocket_handle(text_msg) do
    msg = Poison.decode!(text_msg, as: %GameMessage{})
    handle_action(msg)
  end

  @spec handle_action(%GameMessage{}) :: {:reply, String.t} | :no_reply
  defp handle_action(%GameMessage{action: "create"} = msg) do
    result = StateHolder.Room.create_room(msg.game, msg.player, self())
    reply_msg = case result do
      :ok -> create_result_msg("ok", 201)
      :already_exists -> create_result_msg("error", 406)
    end
    {:reply, reply_msg}
  end
  defp handle_action(%GameMessage{action: "join"} = msg) do
    players = StateHolder.Room.get_members(msg.game)
    reply_msg = case List.keymember?(players, msg.player, 0) do
      true -> 
        create_result_msg("error", 406)
      false -> 
        StateHolder.Room.add_member(msg.game, msg.player, self())
        game = StateHolder.Room.get_room_info(msg.game)
        create_game_msg(msg.game, game) 
    end
    {:reply, reply_msg}
  end
  defp handle_action(%GameMessage{action: "put"} = msg) do
    StateHolder.update_room(msg.game, msg.box, {msg.letter, msg.player})
    broadcast_update(msg.game, msg.box, msg.letter, msg.player)
    :no_reply
  end

  defp broadcast_update(room_name, boxid, letter, player) do
    # Broadcast to all players
    game_msg = %GameMessage{action: "update", game: room_name, box: boxid, letter: letter, player: player}
    encoded_msg = Poison.encode!(game_msg)
    StateHolder.Room.broadcast(room_name, encoded_msg)
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
