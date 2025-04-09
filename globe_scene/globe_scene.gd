extends Node3D
class_name GlobeRoot
@export var is_game_multiplayer = false
@onready var load_filter:ColorRect = %OnLoadFilter


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if load_filter != null:
        if is_equal_approx(load_filter.modulate.a, 0.0):
            load_filter.visible = false
            load_filter.queue_free()
            return
        load_filter.modulate.a = lerp(load_filter.modulate.a, 0.0, delta * 0.5)

    pass
    
func _unhandled_input(event: InputEvent) -> void:
    pass

func single_player_ready():
    pass
    
func multi_player_ready():
    
    var spawn_points = %PlayerSpawnLocations.get_children()
    var peers = multiplayer.get_peers()
    for i in range(peers.size()):
        var peer = peers[i]
        print("Peer is: ", peer) #Expecting 1 and onward
        var layer_string = "PLAYER_"+str(peer)
        var layer_int = GlobalConst.layers[layer_string]
        
        pass
    pass
