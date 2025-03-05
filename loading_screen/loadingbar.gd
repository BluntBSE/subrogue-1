extends Control

@export var progressbar:TextureProgressBar
@export var debugbar:ProgressBar
@export var percent_label:Label
@export var tooltip_label:RichTextLabel

var scene_path:String
var progress:Array
var update:float = 0.0

signal game_loaded

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    scene_path = SceneChangeLoader.scene_path
    ResourceLoader.load_threaded_request(scene_path, "", true) ##If true is not set, we activate a bug https://github.com/godotengine/godot/issues/102593
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    ResourceLoader.load_threaded_get_status(scene_path, progress)
    if progress[0] > update:
        update = progress[0]
    
    var update_adjusted = snapped(update * 100,1.0)
    var lerped_str = "0%"
    if progressbar.value < update_adjusted:
         # Adjust the speed multiplier as needed
        progressbar.set_value(lerp(progressbar.value, update_adjusted, delta * 1.0) )
        lerped_str = str(snapped(lerp(progressbar.value, update_adjusted, delta * 1.0),1.0) ) + "%"

    percent_label.text = str(lerped_str)
    if progressbar.value > 99.0:
        SoundManager.stop_sound_by_id("title_theme")
        SoundManager.stop_sound_by_id("title_ambience")
        if ResourceLoader.load_threaded_get_status(scene_path)==ResourceLoader.THREAD_LOAD_LOADED:
            print("Is the material present?")
            print(ResourceLoader.has_cached("res://globe_scene/land_backup.tres"))
            get_tree().change_scene_to_packed(
                ResourceLoader.load_threaded_get(scene_path)
            )
    
    pass
