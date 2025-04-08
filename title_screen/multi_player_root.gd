extends Control
@onready var lobby_search = %LobbySearchRoot
@onready var lobby_root = %LobbyUI

func _ready()->void:
    pass
    #SteamManager.initialize_steam()

    
func _on_multiplayer_button_up() -> void:
    
    if lobby_search.visible == false: #&& %LobbyRoot.visible == false:
        Steam.lobby_match_list.connect(_on_lobby_match_list)
        NetworkManager.list_lobbies()
        lobby_search.visible = true
        return
        
    else:
        #Hook up to actual disconnect-from-lobby logic if you're in one
        %LobbySearchRoot.visible = false
        %LobbyRoot.visible = false


func _on_host_button_up() -> void:
    #We don't really want games in which the host isn't present.
    NetworkManager.become_host() #TODO: Dedicated server? idk if we really need/want that
    lobby_search.visible = false
    %TitleLabel.visible = false
    %MenuVBox.visible = false
    #Maybe shouldn't set the lobby root to visible directly, but do some kind of callback?
    lobby_root.visible = true
    

func on_lobby_created()->void:
    print("TITLE SCREEN ON LOBBY CREATED")
    lobby_search.visible = false
    lobby_root.visible = true


func _on_lobby_match_list(lobbies:Array):
    print("On lobby match list")
    print("Lobbies:", lobbies)
    for child in %LobbyList.get_children():
        child.queue_free()
    
    for lobby in lobbies:
        var lobby_name:String = Steam.getLobbyData(lobby, "name")
        #name, mode...
        if lobby_name != "":# &&lobby_name == "SUBROGUE1"
            pass
        var btn:Button = Button.new()
        btn.text = lobby_name
        btn.set_name("lobby_%s" % lobby_name)
        var joincallable:Callable = Callable(self, "join_lobby").bind(lobby)
        btn.button_up.connect(joincallable)
        %LobbyList.add_child(btn)
    pass

func join_lobby(lobby_id)->void:
    NetworkManager.join_as_client(lobby_id)
    var num_mem = Steam.getNumLobbyMembers(lobby_id)
    print("Num members in lobby: ", num_mem)
    for i in range(num_mem):
        var member = Steam.getLobbyMemberByIndex(lobby_id, i)
        var mname = Steam.getFriendPersonaName(member)
        print("mname ", i, "  is ", mname)
        
    


func _on_refresh_button_up() -> void:
    NetworkManager.list_lobbies()
    pass
