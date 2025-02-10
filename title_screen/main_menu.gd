extends Node2D
class_name TitleScreen



func _on_btn_new_game_button_up() -> void:
    #Start the game
    SoundManager.play_straight("sonar_1", "ui")
    SceneChangeLoader.change_scene("res://globe_scene/globe_scene.tscn")
    pass # Replace with function body.
