extends Node
#Acessed as Autoload as SteamManager
var is_owned:bool = false #Do they own the game? Who cares!
var is_online:bool = false
var steam_app_id:int = 480 #Spacewar debug ID
var steam_id:int = 0 #User ID
var steam_username:String = ""
var online = false
var multiplayer_peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()

#Lobby variables

var DATA #Arbitrary lobby data.
var hosted_lobby_id = 0 #Idk if we need one that's separate likt his.
var lobby_members = []
var lobby_invite_arg = false
#Move these configs out probably
var lobby_id = 0
var lobby_max_players = 6
var LOBBY_NAME = "SUBROGUE1"
var LOBBY_MODE = "PRIVATEER"
signal lobby_ready #I'm positive there's a built in way to do this, but I couldn't get it working with GodotSteam
#Actually, it appears that callbacks only work if the peer etc. is in the node, so duplicating these is necessary if I want this global
#The below signals actually work if I wire up UI to the Steam callbacks directly
#But I actually want the global modification of the client variables in one place
#So I duplicate the signals here. This file updates global state. UI implements only UI.

signal lobby_joined
func _init()->void:
    print("Initializing Steam")
    #What's the difference between AppID and GameID?
    OS.set_environment("SteamAppID", str(steam_app_id))
    OS.set_environment("SteamGameID", str(steam_app_id))
    Steam.connect("lobby_joined", on_lobby_joined)

func _process(delta:float)->void:
    Steam.run_callbacks()

func initialize_steam():
    var initialize_response:Dictionary = Steam.steamInitEx()
    print ("Did steam initialize? %s" % initialize_response)
    if initialize_response['status'] > 0:
        print("Steam did not initialize! Perish, fool")
        get_tree().quit()
    
    is_owned = Steam.isSubscribed()
    steam_id = Steam.getSteamID()
    online = Steam.loggedOn()
    steam_username = Steam.getPersonaName()
    
    
func _ready():
    initialize_steam()
    multiplayer_peer.lobby_created.connect(on_lobby_created)
    multiplayer_peer.lobby_joined.connect(on_lobby_joined)

    #THere's some kinda lobby chat methods built in on the peer?


func become_host():
    if SteamManager.hosted_lobby_id != 0:
        print("Lobby already running! It's: ", SteamManager.hosted_lobby_id)
        return
    print("Starting host!")
    #TODO: Make lobby type configurable. Probably has an argument to this function
    multiplayer_peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC, 6)
    #hosted_lobby_id is set by the callback triggered by the above
    if not OS.has_feature("dedicated_server"):  # Not doing this yet.
        pass
        
func join_as_client(_lobby_id):
    #Clear previous lobby members
    lobby_members.clear()
    print("Joining lobby as client, lobby id: ", str(_lobby_id))
    multiplayer_peer.connect_lobby(_lobby_id)
    #TODO: Where to add players to the lobby members array?
    #Tempted to do it here but the tutorial did not...

func _add_player_to_lobby():
    pass

func _disconnect_player():
    # Remove from lobby if a game hasn't started
    # Remove from game if they have
    pass

func on_lobby_created(connect: int, _lobby_id):
    print("On lobby created")
    print("Peer ID", connect)
    print("Lobby ID", lobby_id)
    if connect == 1:
        hosted_lobby_id = _lobby_id
        lobby_id = _lobby_id
        print("Created lobby, lobby id: ", str(hosted_lobby_id))
        
        Steam.setLobbyJoinable(hosted_lobby_id, true)
        Steam.setLobbyData(hosted_lobby_id, "name", LOBBY_NAME)
        Steam.setLobbyData(hosted_lobby_id, "mode", LOBBY_MODE)
        print("Lobby ready should emit")
        lobby_ready.emit(connect, lobby_id)


func list_lobbies():
    print("Listing steam lobbies")
    Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE) #LOBBY_DISTANCE_FILTER_DEFAULT
    Steam.requestLobbyList()
    pass


func on_lobby_joined(lobby: int, permissions: int, locked: bool, response: int):
    print("SteamManager: on lobby joined")

    #LOBBY_NAME = Steam.getLobbyData(lobbyID, "name")
    get_lobby_members()
    lobby_joined.emit(lobby, permissions, locked, response)

    
func get_lobby_members():
    lobby_members.clear()
    var num_members = Steam.getNumLobbyMembers(lobby_id)
    
    for member in range(num_members):
        var member_id = Steam.getLobbyMemberByIndex(lobby_id,member)
        var member_name = Steam.getFriendPersonaName(member_id)
        lobby_members.append({"steam_id":member_id, "steam_name":member_name})

func add_player_list():
    pass
    
func on_lobby_join_requested(_lobbyID, friendID):
    var owner_name = Steam.getFriendPersonaName(friendID)
    
    #Message here if you want
    
    join_as_client(_lobbyID)
