extends Control
class_name LobbyUI

enum lobby_status {Private, Friends, Public, Invisible} 
enum search_distance {Close, Default, Far, Worldwide} #Probably dont need this here. Handled by MP Root


@onready var steam_name:Label = %SteamUsername
@onready var lobby_set_name:Button = %SetName
@onready var lobby_name:LineEdit = %LobbyName
@onready var lobby_output:RichTextLabel = %LobbyChatRTL
@onready var chat_input = %SubmitMsg
@onready var player_list = %PlayerVBox


func _ready():
    steam_name.text = SteamManager.steam_username
    SteamManager.lobby_ready.connect(on_lobby_created) #See callback for why this isnt direct
    SteamManager.lobby_joined.connect(on_lobby_joined)
    SteamManager.self_joined_new_lobby.connect(on_self_joined_new_lobby)
    Steam.connect("lobby_chat_update", on_lobby_chat_update)
    Steam.connect("lobby_message", on_lobby_message)
    Steam.connect("join_requested", on_join_requested)
    Steam.lobby_data_update.connect(on_lobby_data_update)
    check_command_line()


func _process(delta:float)->void:
    pass
###
##STEAM CALLBACKS
###


func on_lobby_created(connection, lobby_id):
    #It actually looks like this one callback isn't firing unless I provide it 
    #A separate signal from the SteamManager. Doing #Steam.lobby_created.connect...No funcione
    print("Lobby UI: On Lobby Created")
    if connection == 1:
        SteamManager.lobby_id = lobby_id
        SteamManager.hosted_lobby_id = lobby_id
        #TODO: Make name configurable at some point
        Steam.setLobbyData(lobby_id, "name", SteamManager.LOBBY_NAME)
        %LobbyName.text = Steam.getLobbyData(lobby_id, "name")
        display_message("Created Lobby: " + str(Steam.getLobbyData(lobby_id, "name")))
        
        
    print("On lobby created!")

func on_lobby_data_update(_success, _lobby_id, _member_id):
    print("Lobby metadata updated")
    print(str(_success), str(_lobby_id), str(_member_id))

func on_join_requested():
    print("Lobby UI: On join requested")

func on_lobby_message(result, user, message, type):
    print("Lobby UI: Lobby message")    
    var sender = Steam.getFriendPersonaName(user)
    display_message(str(sender)+ ": " + str(message))

func on_self_joined_new_lobby(_lobby_id):
    render_players()

#Anyone joined the lobby
func on_lobby_joined(_lobby: int, _permissions: int, _locked: bool, _response: int):
    #SteamManager should have already set our variables so..
    render_players()

func render_players():
    for child in %PlayerVBox.get_children():
        child.queue_free()
        
    for member:Dictionary in SteamManager.lobby_members: #{"steam_id":member_id, "steam_name":member_name}
        var player_label := RichTextLabel.new()
        player_label.fit_content = true
        player_label.text = Steam.getFriendPersonaName(member["steam_id"])
        print("Made a label for ", player_label.text)
        %PlayerVBox.add_child(player_label)

func display_message(message):
    lobby_output.add_text("\n" + str(message))
    pass


func send_chat_message():
    var msg = %ChatInput.text
    var sent = Steam.sendLobbyChatMsg(SteamManager.lobby_id, msg)
    
    if not sent:
        display_message("message failed to send")
        
    %ChatInput.text = ""
    
    
    pass

func on_lobby_chat_update(lobby_id, changed_id, making_change_id, chat_state):
    print("Lobby UI: Chat Update")
    var changer = Steam.getFriendPersonaName(making_change_id)
    
    if chat_state == 1:
        display_message(str(changer)+" has joined the lobby")
    if chat_state == 2:
        display_message(str(changer)+ "has left the lobby")
    elif chat_state == 8:
        display_message(str(changer) + " has been kicked from the lobby")

    
    #Is this good?
    SteamManager.get_lobby_members()
    render_players()
### Command Line ###
## Probably this doesn't belong in LobbyUI but in lobby creation
func check_command_line():
    
    var arguments = OS.get_cmdline_args() 
    
    if arguments.size()>0:
        for argument in arguments:
          #  if SteamManager.lobby_invite_arg:
              #  join_lobby(int(argument))
            if argument == "+connect_lobby":
                SteamManager.lobby_invite_arg = true

###
##BUTTONS
###

func _on_set_name_button_up() -> void:
    print("Lobby UI: Set name button")
    pass # Replace with function body.


func _on_leave_lobby_button_up() -> void:
    print("Lobby UI: On lobby leave b utton")
    pass # Replace with function body.


func _on_submit_msg_button_up() -> void:
    print("Lobby UI: On submit msg button up")
    send_chat_message()
    pass # Replace with function body.
