extends Node3D
class_name GlobeRoot
var is_multiplayer:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #Once this enters the tree, kill the main menu UI. This should probably live elsewhere later.
    var mm = get_tree().root.find_child("MainMenu", true, false)
    if multiplayer.get_peers().size()>0:
        is_multiplayer = true
        if mm:
            mm.queue_free()
        multi_player_start()
    else:
        if mm:
            mm.queue_free()
        single_player_start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    
func _unhandled_input(event: InputEvent) -> void:
    pass

func single_player_start():
    var peers = multiplayer.get_peers()
    peers.append(multiplayer.get_unique_id()) #Get peers alone doesnt return yourself
    print("All peers for SPS, should be just us ", peers)
    for peer in peers:
        var player_obj = preload("res://globe_scene/player.tscn").instantiate()
        player_obj.set_multiplayer_authority(peer)
        %Players.add_child(player_obj)   
    pass
    
func multi_player_start():
    var peers = multiplayer.get_peers()
    peers.append(multiplayer.get_unique_id()) #Get peers alone doesnt return yourself
    print("All peers for MPS:", peers)
    for peer in peers:
        var player_obj = preload("res://globe_scene/player.tscn").instantiate()
        player_obj.set_multiplayer_authority(peer)
        %Players.add_child(player_obj)
    
    pass
