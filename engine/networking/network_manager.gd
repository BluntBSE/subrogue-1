extends Node
#NetworkManager in Autoload

enum MULTIPLAYER_NETWORK_TYPE {ENET, STEAM} #tbh we're only using steam but yknow
var steam_manager:SteamManager
var ref_enet #as yet unused
var host_mode = false
var multiplayer_enabled = false

var active_network_type: MULTIPLAYER_NETWORK_TYPE = MULTIPLAYER_NETWORK_TYPE.STEAM
var active_network #ENET or Steam. Not really useful until we decide to do ENET separatelyt. 

func _ready():
    #If you wanted dedicated server functionality, it'd go here.
    steam_manager = get_tree().root.find_child("SteamManager", true, false)
    pass

func build_multiplayer_network():
    if not active_network:
        print("Setting active network")
        multiplayer_enabled = true
        match active_network_type:
            MULTIPLAYER_NETWORK_TYPE.ENET:
                print("ENET NOT IMPLEMENTED")
            MULTIPLAYER_NETWORK_TYPE.STEAM:
                set_active_network(steam_manager)
                print("Setting network type to Steam")
            _:
                print("No matching network type")

func set_active_network(active_network_node):
    SteamManager
    active_network = active_network_node
    

func become_host(is_dedicated_server = false):
    if is_dedicated_server == false:
        host_mode = true
    build_multiplayer_network()
    active_network.become_host()
    
func join_as_client(lobby_id = 0): #0 == ?
    join_lobby(lobby_id)
    
    

func list_lobbies():
    print("Listing lobbies again")
    build_multiplayer_network()
    active_network.list_lobbies()
    

func join_lobby(lobby_id)->void:
    build_multiplayer_network()
    active_network.join_as_client(lobby_id)
    
