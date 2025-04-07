extends Node
class_name SteamNetwork
# var multiplayer_scene = preload(some_multiplayer_player) - Tutorial variable.
var multiplayer_peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()
var hosted_lobby_id = 0

const LOBBY_NAME = "SUBROGUE1"
const LOBBY_MODE = "PRIVATEER"

signal lobby_ready #I'm positive there's a built in way to do this, but I couldn't get it working with GodotSteam

func _ready():
    multiplayer_peer.lobby_created.connect(_on_lobby_created)
    #THere's some kinda lobby chat methods built in on the peer?

func become_host():
    # In my context, this probably means setting up some information
    # About the person who started the game, and later calling a 
    # Create_game_as_host type thing.
    print("Starting host!")
    multiplayer_peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC, 4)
    
    if not OS.has_feature("dedicated_server"):  # ????
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
