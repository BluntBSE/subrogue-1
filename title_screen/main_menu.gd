extends Node2D
class_name TitleScreen


func _ready():
    #Prepare & initialize steam since it's our only multiplayer option
    #No ENET
    #Should probably disable Multiplayer if steam doesn't init.
    pass


func _on_btn_new_game_button_up() -> void:
    #Start the game
    SoundManager.play_straight("sonar_1", "ui")
    var game_root = get_tree().root.find_child("GameRoot", true, false)
    var globe_scene = preload("res://globe_scene/globe_scene.tscn").instantiate()
    print("Peers upon hitting start button are ", multiplayer.get_peers())
    game_root.add_child(globe_scene)
    #No loading screens for now, we're preloading the world.
    #SceneChangeLoader.change_scene("res://globe_scene/globe_scene.tscn")
    pass # Replace with function body.



    pass # Replace with function body.
