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
    SceneChangeLoader.change_scene("res://globe_scene/globe_scene.tscn")
    pass # Replace with function body.



    pass # Replace with function body.
