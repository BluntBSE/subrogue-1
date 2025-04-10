extends MultiplayerSpawner
class_name MPSpawnerPlayer

func _ready():
    spawn_function = custom_spawn

func custom_spawn(args):
    var anchor  = args["anchor"]
    var spawn_point = args["spawn_point"]
    var layer_int = args["layer"]
    var peer  = args["peer"]
    var player_obj:Player = preload("res://globe_scene/player/player.tscn").instantiate()
    #Can't do this in an unpack function before the player object is returned
    #BECAUSE references are encodedobjects as ID
    
    player_obj.layer = layer_int
    player_obj.set_multiplayer_authority(peer)
    player_obj.anchor = anchor
    player_obj.spawn_point = spawn_point
    return player_obj
