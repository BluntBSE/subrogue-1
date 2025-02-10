extends Control

@export var progressbar:TextureProgressBar
@export var label:Label
@export var tooltip:RichTextLabel

var scene_path:String
var progress:Array



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    scene_path = SceneChangeLoader.scene_path
    ResourceLoader.load_threaded_request(scene_path, "", true) ##If true is not set, we activate a bug https://github.com/godotengine/godot/issues/102593
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    ResourceLoader.load_threaded_get_status(scene_path, progress)
    progressbar.value = progress[0]
    print(progress[0])
    label.text = str(progress[0] * 100.0)# ???
    if ResourceLoader.load_threaded_get_status(scene_path)==ResourceLoader.THREAD_LOAD_LOADED:
        get_tree().change_scene_to_packed(
            ResourceLoader.load_threaded_get(scene_path)
        )
    
    pass
