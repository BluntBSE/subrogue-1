extends MultiplayerSpawner
class_name GlobeSpawner

func _ready():
    spawn_function = spawn_globe

func spawn_globe():
    #List all peers this will effect:
    var peers = multiplayer.get_peers()
    print("PEERS FOR SPAWN ARE: ", peers)
    
    #WARNING: Preloading here moves the load time to when the application first boots. That may or may not be okay.
    #In fact it seems preferable right now, but if it becomes an issue this is to blame.
    var globe_root:GlobeRoot = preload("res://globe_scene/globe_scene.tscn").instantiate()
    var mainmenu = get_tree().root.find_child("MainMenu", true, false)
    mainmenu.queue_free()
    return globe_root
