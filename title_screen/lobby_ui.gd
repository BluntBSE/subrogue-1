extends Control
class_name LobbyUI

enum lobby_status {Private, Friends, Public, Invisible} 
enum search_distance {Close, Default, Far, Worldwide} #Probably dont need this here. Handled by MP Root


@onready var steam_name:Label = %SteamUsername
@onready var lobby_set_name:Button = %SetName
@onready var lobby_name:LineEdit = %LobbyName
@onready var lobby_output:VBoxContainer = %LobbyChatVBox
@onready var chat_input = %SubmitMsg
@onready var player_list = %PlayerVBox


func _ready():
    steam_name.text = SteamManager.steam_username
    Steam.lobby_created.connect(on_lobby_created)
    #Steam.connect("lobby_match_list", self, "on_lobby-Match_list
    Steam.connect("lobby_joined", on_lobby_joined)
    Steam.connect("lobby_chat_update", on_lobby_chat_update)
    Steam.connect("lobby_message", on_lobby_message)
    Steam.connect("join_requested", on_join_requested)
    Steam.connect("lobby_data_update", on_lobby_data_update)
    check_command_line()


func _process(delta:float)->void:
    Steam.run_callbacks()
###
##STEAM CALLBACKS
###
func on_lobby_created(connection, lobby_id):
    print("Lobby UI: On lobby created! If you're seeing this, it means that having Steam.runCallbacks in this node was enough")
    if connection == 1:
        SteamManager.lobby_id = lobby_id
        SteamManager.hosted_lobby_id = lobby_id
        #TODO: Make name configurable at some point
        Steam.setLobbyData(lobby_id, "name", SteamManager.LOBBY_NAME)
        %LobbyName.text = Steam.getLobbyData(lobby_id, "name")
        
        
    print("On lobby created!")

func on_lobby_data_update():
    print("Lobby UI: on lobby data update")

func on_join_requested():
    print("Lobby UI: On join requested")

func on_lobby_message():
    print("Lobby UI: Lobby message")    

func on_lobby_chat_update():
    print("Lobby UI: Lobby chat update")

func on_lobby_joined():
    print("ON lobby joined from Lobby UI")


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
    pass # Replace with function body.
