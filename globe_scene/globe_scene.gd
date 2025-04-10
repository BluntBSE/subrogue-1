extends Node3D
class_name GlobeRoot
var is_multiplayer:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if multiplayer.get_peers().size()>0:
        is_multiplayer = true
    else:
        single_player_start()
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    
func _unhandled_input(event: InputEvent) -> void:
    pass

func single_player_start():
    var peers = multiplayer.get_peers()
    peers.append(multiplayer.get_unique_id()) #Get peers alone doesnt return yourself
    for peer in peers:
        var player_obj = preload("res://globe_scene/player.tscn").instantiate()
        player_obj.set_multiplayer_authority(peer)
        %Players.add_child(player_obj)   
    pass
    
func multi_player_start():
    var peers = multiplayer.get_peers()
    peers.append(multiplayer.get_unique_id()) #Get peers alone doesnt return yourself
    for peer in peers:
        var player_obj = preload("res://globe_scene/player.tscn").instantiate()
        player_obj.set_multiplayer_authority(peer)
        %Players.add_child(player_obj)
    
    pass
