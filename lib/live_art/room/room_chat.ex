defmodule LiveArt.Room.RoomChat do

  def send_chat(room_id, category, message) do
    broadcast(room_id, category, :new_chat, message)
  end

  def subscribe(room_id, category) do
    Phoenix.PubSub.subscribe(LiveArt.PubSub, "room_events:#{room_id}:chat-#{category}")
  end

  defp broadcast(room_id, category, event, data) do
    Phoenix.PubSub.broadcast(LiveArt.PubSub, "room_events:#{room_id}:chat-#{category}", {event, category, data})
  end
end
