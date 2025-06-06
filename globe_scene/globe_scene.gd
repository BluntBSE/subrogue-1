extends Node3D
class_name GlobeRoot
var is_multiplayer:bool = false
@onready var game_root:GameRoot = get_tree().root.find_child("GameRoot", true, false)


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
    #TODO: Move this to when all players are connected, etc.
    SoundManager.stop_sound_by_id("title_ambience")
    SoundManager.stop_sound_by_id("title_theme")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    
func _unhandled_input(event: InputEvent) -> void:
    pass

func single_player_start():
    var peers = multiplayer.get_peers()
    peers.append(multiplayer.get_unique_id()) #Get peers alone doesnt return yourself
    for peer in peers:
        var player_obj = preload("res://globe_scene/player/player.tscn").instantiate()
        player_obj.set_multiplayer_authority(peer)
        player_obj.name = "player_"+str(peer)
        game_root.peers["player_1"] = peer
        game_root.players["player_1"] = player_obj
        player_obj.faction_layer = GlobalConst.layers.PLAYER_1
        %Players.add_child(player_obj)   
    pass
    
func multi_player_start():
    #This crude system assigns player slot based on the order of the peers. This should be a level above.
    var peers = []
    peers.append(multiplayer.get_unique_id()) #Get peers alone doesnt return yourself
    for peer in multiplayer.get_peers():
        peers.append(peer)
    

    for i in range(peers.size()):
        var peer = peers[i]
        var slot_str = "player_"+str(i+1) #Player 1 is 1, not 0.
        game_root.peers[slot_str]=peer
        var player_obj = preload("res://globe_scene/player/player.tscn").instantiate()
        player_obj.set_multiplayer_authority(peer)
        player_obj.name = "player_"+str(peer)
        player_obj.faction_layer = GlobalConst.layers[slot_str]
        game_root.players[slot_str] = player_obj
        %Players.add_child(player_obj)
    
    pass
