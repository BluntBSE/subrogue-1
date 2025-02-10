extends Camera3D
class_name TitleCamera
@onready var player:AnimationPlayer = %AnimationPlayer




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    print("ANIMATION FINISHED:", anim_name)
    if anim_name == "loading_cam_track_1":
        player.play("loading_cam_track_2")
    if anim_name == "loading_cam_track_2":
        player.play("loading_cam_track_4")
    if anim_name == "loading_cam_track_4":
        player.play("loading_cam_track_3")
    if anim_name == "loading_cam_track_3":
        player.play("loading_cam_track_1")
    pass # Replace with function body.
