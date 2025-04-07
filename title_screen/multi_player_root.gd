extends Control
@onready var lobby_search = %LobbySearchRoot
@onready var lobby_root = %LobbyRoot

func _ready()->void:
    SteamManager.initialize_steam()

    
func _on_multiplayer_button_up() -> void:
    
    if lobby_search.visible == false && %LobbyRoot.visible == false:
        Steam.lobby_match_list.connect(_on_lobby_match_list)
        NetworkManager.list_lobbies()
        lobby_search.visible = true
        return
        

    if %LobbySearchRoot.visible == true && %LobbyRoot.visible == false:
        %LobbySearchRoot.visible = false
        return
    else:
        #Hook up to actual disconnect-from-lobby logic if you're in one
        %LobbySearchRoot.visible = false
        %LobbyRoot.visible = false


func _on_host_button_up() -> void:
    #We don't really want games in which the host isn't present.
    NetworkManager.become_host() #TODO: Dedicated server? idk if we really need/want that
    #Refresh list
    var SN:SteamNetwork = get_tree().root.find_child("SteamNetwork", true, false)
    print(SN)
    SN.lobby_ready.connect(on_lobby_created)
    var hosted_id = SN.hosted_lobby_id
    var self_peer = SN.multiplayer_peer
    var nums
    #lobby_root.unpack(hosted_id)
    

func on_lobby_created()->void:
    print("TITLE SCREEN ON LOBBY CREATED")
    lobby_search.visible = false
    lobby_root.visible = true
    var SN:SteamNetwork = get_tree().root.find_child("SteamNetwork", true, false)
    
    lobby_root.unpack(SN.hosted_lobby_id)

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
    #Just to see if we do in fact automatically joint he lobby we create.
    var SN:SteamNetwork = get_tree().root.find_child("SteamNetwork", true, false)
    var lobby_id = SN.hosted_lobby_id
    var num_mem = Steam.getNumLobbyMembers(lobby_id)
    print("Num members in lobby: ", num_mem)
    for i in range(num_mem):
        var member = Steam.getLobbyMemberByIndex(lobby_id, i)
        var mname = Steam.getFriendPersonaName(member)
        print("mname ", i, "  is ", mname)
