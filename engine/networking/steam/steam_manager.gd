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

func _init()->void:
    print("Initializing Steam")
    #What's the difference between AppID and GameID?
    OS.set_environment("SteamAppID", str(steam_app_id))
    OS.set_environment("SteamGameID", str(steam_app_id))

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
    multiplayer_peer.lobby_created.connect(_on_lobby_created)
    #THere's some kinda lobby chat methods built in on the peer?

func on_lobby_created(peer_id, lobby_id): #peer id (0  for server, 1, for host...), lobby id
    print("peer ID:", peer_id)
    print("lobby id: ", lobby_id)

func become_host():

    print("Starting host!")
    multiplayer_peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC, 4)
    multiplayer_peer.lobby_created.connect(on_lobby_created)
    if not OS.has_feature("dedicated_server"):  # Not doing this yet.
        pass
        
func join_as_client(lobby_id):
    print("Joining lobby as client, lobby id: ", str(lobby_id))
    multiplayer_peer.connect_lobby(lobby_id)

func _add_player_to_lobby():
    pass

func _disconnect_player():
    # Remove from lobby if a game hasn't started
    # Remove from game if they have
    pass

func _on_lobby_created(connect: int, lobby_id):
    print("On lobby created")
    if connect == 1:
        hosted_lobby_id = lobby_id
        print("Created lobby, lobby id: ", str(hosted_lobby_id))
        
        Steam.setLobbyJoinable(hosted_lobby_id, true)
        Steam.setLobbyData(hosted_lobby_id, "name", LOBBY_NAME)
        Steam.setLobbyData(hosted_lobby_id, "mode", LOBBY_MODE)
        print("Should be emitting right now. The heck?")
        lobby_ready.emit()


func list_lobbies():
    print("Listing steam lobbies")
    Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE) #LOBBY_DISTANCE_FILTER_DEFAULT
    Steam.requestLobbyList()
    pass
