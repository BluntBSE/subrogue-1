extends Control
class_name LobbyRoot



func unpack(lobby_id):
    # Clear existing children in %LobbyPlayers to avoid duplicates
    for child in %LobbyPlayers.get_children():
        child.queue_free()

    var num_mem = Steam.getNumLobbyMembers(lobby_id)
    print("Num members in lobby: ", num_mem)
    for i in range(num_mem):
        var member = Steam.getLobbyMemberByIndex(lobby_id, i)
        var mname = Steam.getFriendPersonaName(member)
        print("mname ", i, "  is ", mname)
        var label = Label.new()
        label.text = mname if mname != "" else "Unnamed Player"
        %LobbyPlayers.add_child(label)  # Add the label to the LobbyPlayers container
# Called when a player submits a message
func _on_line_edit_text_submitted(new_text):
    print("Text submitted:", new_text)
    # Send the message to all players, including yourself
    submit_chat_rpc(multiplayer.get_unique_id(), new_text)

# Submits a chat message locally and displays it
func submit_chat(sender_id: int, contents: String):
    #TODO Honestly we'll have to rewrite this with the steam chat I guess
    
    # Create a new chat entry
    #Id 1 == host
    var SN:SteamNetwork = get_tree().root.find_child("SteamNetwork", true, false)
    
    var member = Steam.getLobbyMemberByIndex(SN.hosted_lobby_id, sender_id - 1)
    var member_name = Steam.getFriendPersonaName(member)

    # Create a new label for the message
    var label: Label = Label.new()
    label.text = "[" + str(member_name) + "]: " + contents
    %ChatVBox.add_child(label)

# Sends the chat message to all players in the lobby
@rpc("any_peer", "reliable")
func submit_chat_rpc(sender_id: int, contents: String):
    # Call the local `submit_chat` function to display the message
    submit_chat(sender_id, contents)


func on_player_joined_lobby(player)->void:
    pass
