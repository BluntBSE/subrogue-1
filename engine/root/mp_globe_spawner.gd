extends MultiplayerSpawner
class_name GlobeSpawner

func _ready():
    #Maybe noneedfor custom spawner yet
    spawn_function = spawn_globe
    print("Spawn function is ", spawn_function)

func spawn_globe(_data):
    print(_data)
    print(_data["test"])
    
    #List all peers this will effect:
    var peers = multiplayer.get_peers()
    print("PEERS FOR SPAWN ARE: ", peers)
    #WARNING: Preloading here moves the load time to when the application first boots. That may or may not be okay.
    #In fact it seems preferable right now, but if it becomes an issue this is to blame.
    var globe_root:GlobeRoot = preload("res://globe_scene/globe_scene.tscn").instantiate()
    if peers.size()>1:
        globe_root.is_game_multiplayer = true
        
    
    
    var mainmenu = get_tree().root.find_child("MainMenu", true, false)
    mainmenu.queue_free()
    var game_root = get_tree().root.find_child("GameRoot", true, false)
    #game_root.add_child(globe_root)
    return globe_root
