extends Node
#NetworkManager in Autoload

enum MULTIPLAYER_NETWORK_TYPE {ENET, STEAM} #tbh we're only using steam but yknow
var ref_steam:SteamNetwork
var ref_enet #as yet unused
var host_mode = false
var multiplayer_enabled = false

var active_network_type: MULTIPLAYER_NETWORK_TYPE = MULTIPLAYER_NETWORK_TYPE.STEAM
var steam_network_scene := preload("res://engine/networking/steam/steam_network.tscn")
var active_network #ENET or Steam. Not really useful until we decide to do ENET separatelyt. 

func _ready():
    #If you wanted dedicated server functionality, it'd go here.
    pass

func build_multiplayer_network():
    if not active_network:
        print("Setting active network")
        multiplayer_enabled = true
        match active_network_type:
            MULTIPLAYER_NETWORK_TYPE.ENET:
                print("ENET NOT IMPLEMENTED")
                print("Setting network to ENET")
            MULTIPLAYER_NETWORK_TYPE.STEAM:
                set_active_network(steam_network_scene)
                print("Setting network type to Steam")
            _:
                print("No matching network type")

func set_active_network(active_network_scene):
    var initialized_network = active_network_scene.instantiate()
    active_network = initialized_network
    #...Player spawn node? BatteryAcidDev tutorial said: active_network._players_spawn_node = _players_spawn_node, with that at top
    #I dont think we need that but hey
    add_child(active_network)
    pass

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
    
