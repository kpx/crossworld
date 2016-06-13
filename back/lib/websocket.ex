defmodule Crossworld.Websocket do
  use WebsocketHandler
  require Poison
  alias Crossworld.Game.GameMessage, as: GameMessage

  defmodule Result do
      @derive [Poison.Encoder]
      defstruct result: "ok", code: 200
  end

  def websocket_handle({:text, text}, req, state) do
    msg = Poison.decode!(text, as: %GameMessage{})

    case msg.action do
      "create" ->
        result = Crossworld.Game.create_room(msg.game, msg.player, self())
        reply_msg = case result do
          :ok -> create_result_msg("ok", 201)
          :already_exists -> create_result_msg("error", 406)
        end
        {:reply, {:text, reply_msg}, req, state}
      "join" -> 
        game = Crossworld.Game.get_room_info(msg.game)
        players = MapSet.to_list(Map.fetch!(game, :members))
        reply_msg = case List.keymember?(players, msg.player, 0) do
          true -> 
            create_result_msg("error", 406)
          false -> 
            Crossworld.Game.add_member(msg.game, msg.player, self())
            create_game_msg(msg.game, game) 
        end
        {:reply, {:text, reply_msg}, req, state}
      "put" ->
        Crossworld.Game.update_room(msg.game, msg.box, {msg.letter, msg.player})
        broadcast_update(msg.game, msg.box, msg.letter, msg.player)
        {:ok, req, state}
    end
  end

  defp broadcast_update(room_name, boxid, letter, player) do
    players = Crossworld.Game.get_members(room_name)
    # Broadcast to all players
    game_msg = %GameMessage{action: "update", game: room_name, box: boxid, letter: letter, player: player}
    encoded_msg = Poison.encode!(game_msg)
    msg = {:broadcast, encoded_msg}
    pids = Enum.map(players, fn({_, pid}) -> pid end)
    Crossworld.Websocket.broadcast(pids, msg)
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
