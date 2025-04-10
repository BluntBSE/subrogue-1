extends Node3D
class_name GlobeRoot
@export var is_game_multiplayer = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if is_game_multiplayer == true:
        print("It's multiplayer!")
        multi_player_ready()
    else:
        print("It's not multiplayer!")
        single_player_ready()
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    
func _unhandled_input(event: InputEvent) -> void:
    pass

func single_player_ready():
    print("Globe Root fired single player ready")
    var spawn_point = %PlayerSpawnLocations.get_children()[0]
    var layer = GlobalConst.layers.PLAYER_1
    var player_obj:Player = preload("res://globe_scene/player/player.tscn").instantiate()
    player_obj.layer = layer
    #Any need for multiplayer authority at all?
    player_obj.unpack(%GamePlanet, spawn_point)
    %Players.add_child(player_obj)
    
#Only the server should do this, huh.
func multi_player_ready():
    print("Globe root fired multiplayer ready!")
    if multiplayer.is_server():
        print("We think we're the server alright!")
    if not multiplayer.is_server():
        return
    print("Globe root fired multiplayer ready")
    var spawn_points = %PlayerSpawnLocations.get_children()
    var peers = multiplayer.get_peers()
    for i in range(peers.size()):
        var peer = peers[i]
        print("Peer is: ", peer) #Peer is actually the full peer ID, oops.
        var layer_string = "PLAYER_"+str(i+1)
        print("Layer string was: ", layer_string)
        var layer_int = GlobalConst.layers[layer_string]
        var player_obj:Player = preload("res://globe_scene/player/player.tscn").instantiate()
        player_obj.layer = layer_int
        player_obj.set_multiplayer_authority(peer)
        #TODO: If this isn't a game being loaded...
        print("Did we even get a player obj?", player_obj)
        #Actually we gotta SPAWN!
        player_obj.unpack(%GamePlanet, spawn_points[i+1])
        %SES.spawn(player_obj) #Synchronized Entity Spawner
        #Might need to set the SES to call unpack on anything it needs to...

        pass
    pass
