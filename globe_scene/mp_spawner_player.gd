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
    player_obj.layer = layer_int
    player_obj.set_multiplayer_authority(peer)
    player_obj.unpack(anchor, spawn_point)
    return player_obj
